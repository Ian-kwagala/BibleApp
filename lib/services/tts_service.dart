import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Implements Blueprint v2.0 Fix #5:
/// Verse-by-Verse Utterance Queue for Offline Audio Bible so the reader
/// reliably highlights and scrolls to the exact active verse on screen.
class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  bool isPlaying = false;
  int activeVerseIndex = 0; // 0-indexed verse in current chapter
  double playbackRate = 1.0;
  List<String> _currentVerses = [];
  String _currentBook = 'John';
  int _currentChapter = 3;

  Timer? _fallbackCadenceTimer;
  final VoidCallback onStateChanged;

  TtsService({required this.onStateChanged}) {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      _flutterTts.setCompletionHandler(() {
        if (isPlaying) {
          _advanceToNextVerse();
        }
      });
      _flutterTts.setErrorHandler((_) {
        // Fallback cadence timer keeps verse highlighting working even if
        // a browser or emulator has no audio output device attached.
      });
    } catch (_) {
      // Safe fallback on platforms without native TTS engine initialized
    }
  }

  Future<void> startReadingChapter({
    required String book,
    required int chapter,
    required List<String> verses,
    int startVerseIndex = 0,
  }) async {
    _currentBook = book;
    _currentChapter = chapter;
    _currentVerses = verses;
    activeVerseIndex = startVerseIndex.clamp(0, verses.length - 1);
    isPlaying = true;
    onStateChanged();
    await _speakCurrentVerse();
  }

  String get currentReferenceLabel =>
      '$_currentBook $_currentChapter:${activeVerseIndex + 1}';

  Future<void> togglePlayPause({
    required String book,
    required int chapter,
    required List<String> verses,
  }) async {
    if (isPlaying) {
      await pause();
    } else {
      if (_currentBook != book ||
          _currentChapter != chapter ||
          _currentVerses.isEmpty) {
        await startReadingChapter(
          book: book,
          chapter: chapter,
          verses: verses,
          startVerseIndex: activeVerseIndex,
        );
      } else {
        isPlaying = true;
        onStateChanged();
        await _speakCurrentVerse();
      }
    }
  }

  Future<void> pause() async {
    isPlaying = false;
    _fallbackCadenceTimer?.cancel();
    try {
      await _flutterTts.stop();
    } catch (_) {}
    onStateChanged();
  }

  Future<void> stop() async {
    isPlaying = false;
    activeVerseIndex = 0;
    _fallbackCadenceTimer?.cancel();
    try {
      await _flutterTts.stop();
    } catch (_) {}
    onStateChanged();
  }

  Future<void> skipPrevious() async {
    if (_currentVerses.isEmpty) return;
    activeVerseIndex = (activeVerseIndex - 1).clamp(0, _currentVerses.length - 1);
    onStateChanged();
    if (isPlaying) {
      await _speakCurrentVerse();
    }
  }

  Future<void> skipNext() async {
    if (_currentVerses.isEmpty) return;
    if (activeVerseIndex < _currentVerses.length - 1) {
      activeVerseIndex++;
      onStateChanged();
      if (isPlaying) {
        await _speakCurrentVerse();
      }
    } else {
      await stop();
    }
  }

  Future<void> cycleSpeed() async {
    final speeds = [0.75, 1.0, 1.25, 1.5];
    final currentIdx = speeds.indexOf(playbackRate);
    playbackRate = speeds[(currentIdx + 1) % speeds.length];
    try {
      await _flutterTts.setSpeechRate((0.5 * playbackRate).clamp(0.25, 1.0));
    } catch (_) {}
    onStateChanged();
    if (isPlaying) {
      await _speakCurrentVerse();
    }
  }

  Future<void> _speakCurrentVerse() async {
    _fallbackCadenceTimer?.cancel();
    if (!isPlaying ||
        _currentVerses.isEmpty ||
        activeVerseIndex >= _currentVerses.length) {
      await stop();
      return;
    }

    final text = _currentVerses[activeVerseIndex];
    final wordCount = text.split(RegExp(r'\s+')).length;
    final estimatedSeconds =
        ((wordCount / 2.6) / playbackRate).clamp(2.5, 12.0);

    // Schedule a safety cadence timer so if native TTS is muted/unavailable in
    // web preview or headless testing, verse-by-verse highlighting still advances smoothly.
    _fallbackCadenceTimer = Timer(
      Duration(milliseconds: (estimatedSeconds * 1000).round()),
      () {
        if (isPlaying) {
          _advanceToNextVerse();
        }
      },
    );

    try {
      await _flutterTts.stop();
      await _flutterTts.speak('Verse ${activeVerseIndex + 1}. $text');
    } catch (_) {}
  }

  void _advanceToNextVerse() {
    _fallbackCadenceTimer?.cancel();
    if (!isPlaying) return;
    if (activeVerseIndex < _currentVerses.length - 1) {
      activeVerseIndex++;
      onStateChanged();
      _speakCurrentVerse();
    } else {
      stop();
    }
  }

  void dispose() {
    _fallbackCadenceTimer?.cancel();
    try {
      _flutterTts.stop();
    } catch (_) {}
  }
}
