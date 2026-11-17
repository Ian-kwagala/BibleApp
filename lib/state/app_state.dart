import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bible_models.dart';
import '../services/bible_repository.dart';
import '../services/tts_service.dart';

class AppState extends ChangeNotifier {
  final BibleRepository repository = BibleRepository();
  late final TtsService ttsService;
  SharedPreferences? _prefs;

  bool isInitialized = false;
  int currentTabIndex = 0; // 0: Home, 1: Read, 2: Quiz, 3: Versions, 4: Art Studio

  // Reader state
  String activeVersion = 'WEB';
  String currentBook = 'John';
  int currentChapter = 1;
  List<String> currentChapterVerses = [];
  bool isLoadingChapter = false;
  int? selectedVerseNumber;
  double readerFontSize = 16.5;
  String readerThemeMode = 'parchment'; // parchment, daylight, midnight

  // Dwell-time tracking for Blueprint v2.0 Fix #6 (AdMob Accidental Click Prevention)
  DateTime _chapterOpenedAt = DateTime.now();
  int chaptersReadCount = 0;
  DateTime? lastInterstitialShownAt;
  bool isShowingInterstitialOverlay = false;
  String? interstitialTriggerReason;

  // Connectivity & AdMob state
  bool isPhoneOnline = true;

  // Google Sign-In & Drive appDataFolder Sync state (starts unsigned-in, local-first)
  bool isSignedInWithGoogle = false;
  String googleUserEmail = 'reader@gmail.com';
  String googleUserName = 'Bible Reader';
  String lastBackupLabel = 'Not synced yet';
  bool isSyncingDrive = false;
  int pendingSyncChanges = 0;
  Timer? _debounceSyncTimer;

  // Study & Habit state — starts cleanly from ZERO for new users
  int streakDays = 0;
  String lastActiveDate = '';
  int xp = 0;
  int quizTotalAttempted = 0;
  int quizTotalCorrect = 0;
  int currentQuizStreak = 0;
  Map<String, VerseAnnotation> annotations = {};
  Map<String, List<int>> completedPlanDays = {};
  List<String> answeredQuizIds = [];
  String activePlanId = '30_days_of_peace';
  String umpConsentStatus = 'personalized';

  // Version download progress map (versionCode -> 0.0..1.0)
  final Map<String, double> downloadProgress = {};

  // Verse Art Studio state
  String studioVerseText =
      'I can do all things through Christ who strengthens me.';
  String studioVerseRef = 'Philippians 4:13';
  int studioThemeIndex = 0;
  String studioFontFamily = 'Serif'; // Serif, Modern, Calligraphy

  AppState() {
    ttsService = TtsService(onStateChanged: notifyListeners);
  }

  int get userLevel => (xp ~/ 100) + 1;
  int get xpIntoCurrentLevel => xp % 100;
  double get levelProgressFraction => (xp % 100) / 100.0;

  int get highlightsCount => annotations.values
      .where((a) => a.colorHex != null && a.colorHex!.isNotEmpty)
      .length;
  int get notesCount => annotations.values
      .where((a) => a.note != null && a.note!.trim().isNotEmpty)
      .length;
  int get bookmarksCount =>
      annotations.values.where((a) => a.isBookmarked).length;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await repository.initialize(_prefs!);

    // Load local saved state or initialize clean zero-state
    final savedJson = _prefs!.getString('lw_user_sync_payload_v3');
    if (savedJson != null && savedJson.isNotEmpty) {
      try {
        final payload = UserSyncPayload.fromJson(
          jsonDecode(savedJson) as Map<String, dynamic>,
        );
        _applyPayload(payload);
      } catch (_) {
        _resetToZeroState();
      }
    } else {
      _resetToZeroState();
      await _persistLocalState();
    }

    isPhoneOnline = _prefs!.getBool('lw_is_online') ?? true;
    isSignedInWithGoogle = _prefs!.getBool('lw_google_signed_in_v3') ?? false;
    readerFontSize = _prefs!.getDouble('lw_reader_font_size') ?? 16.5;
    readerThemeMode = _prefs!.getString('lw_reader_theme') ?? 'parchment';
    quizTotalAttempted = _prefs!.getInt('lw_quiz_attempted') ?? 0;
    quizTotalCorrect = _prefs!.getInt('lw_quiz_correct') ?? 0;

    await loadChapter(
      book: currentBook,
      chapter: currentChapter,
      version: activeVersion,
      countForAd: false,
    );

    isInitialized = true;
    notifyListeners();
  }

  void _resetToZeroState() {
    streakDays = 0;
    lastActiveDate = '';
    xp = 0;
    quizTotalAttempted = 0;
    quizTotalCorrect = 0;
    currentQuizStreak = 0;
    activeVersion = 'WEB';
    currentBook = 'John';
    currentChapter = 1;
    annotations = {};
    completedPlanDays = {};
    answeredQuizIds = [];
    umpConsentStatus = 'personalized';
  }

  void _applyPayload(UserSyncPayload payload) {
    streakDays = payload.streakDays;
    lastActiveDate = payload.lastActiveDate;
    xp = payload.xp;
    activeVersion = payload.activeVersion;
    currentBook = payload.lastBook;
    currentChapter = payload.lastChapter;
    annotations = Map<String, VerseAnnotation>.from(payload.annotations);
    completedPlanDays = payload.completedPlanDays.map(
      (k, v) => MapEntry(k, List<int>.from(v)),
    );
    answeredQuizIds = List<String>.from(payload.answeredQuizIds);
    umpConsentStatus = payload.umpConsentStatus;
  }

  UserSyncPayload buildSyncPayload() {
    return UserSyncPayload(
      streakDays: streakDays,
      lastActiveDate: lastActiveDate,
      xp: xp,
      activeVersion: activeVersion,
      lastBook: currentBook,
      lastChapter: currentChapter,
      annotations: annotations,
      completedPlanDays: completedPlanDays,
      answeredQuizIds: answeredQuizIds,
      umpConsentStatus: umpConsentStatus,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  String _todayIsoString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _recordDailyActivity() {
    final today = _todayIsoString();
    if (lastActiveDate != today) {
      streakDays++;
      lastActiveDate = today;
    }
  }

  /// Step 1 of Sync Blueprint: Always save immediately to local storage first (100% offline-first).
  Future<void> _persistLocalState() async {
    final payload = buildSyncPayload();
    await _prefs?.setString('lw_user_sync_payload_v3', payload.toJsonString());
    await _prefs?.setInt('lw_quiz_attempted', quizTotalAttempted);
    await _prefs?.setInt('lw_quiz_correct', quizTotalCorrect);
    pendingSyncChanges++;
    _scheduleDebouncedGoogleDriveSync();
  }

  /// Implements Blueprint v2.0 Fix #3:
  /// Debounces Google Drive `appDataFolder` uploads (every 3 minutes instead of every tap)
  /// and performs conflict-free timestamp/set-union merging.
  void _scheduleDebouncedGoogleDriveSync() {
    if (!isSignedInWithGoogle || !isPhoneOnline) return;
    _debounceSyncTimer?.cancel();
    _debounceSyncTimer = Timer(const Duration(minutes: 3), () {
      syncNowWithGoogleDrive();
    });
  }

  Future<void> syncNowWithGoogleDrive() async {
    if (!isSignedInWithGoogle || !isPhoneOnline) return;
    isSyncingDrive = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 650));

    final remoteRaw = _prefs?.getString('lw_gdrive_appdata_remote_v3');
    final localPayload = buildSyncPayload();
    UserSyncPayload mergedPayload = localPayload;

    if (remoteRaw != null && remoteRaw.isNotEmpty) {
      try {
        final remotePayload = UserSyncPayload.fromJson(
          jsonDecode(remoteRaw) as Map<String, dynamic>,
        );
        mergedPayload = localPayload.mergeWith(remotePayload);
        _applyPayload(mergedPayload);
      } catch (_) {}
    }

    final mergedJson = mergedPayload.toJsonString();
    await _prefs?.setString('lw_gdrive_appdata_remote_v3', mergedJson);
    await _prefs?.setString('lw_user_sync_payload_v3', mergedJson);

    pendingSyncChanges = 0;
    lastBackupLabel = 'Synced just now';
    isSyncingDrive = false;
    notifyListeners();
  }

  void setTabIndex(int index) {
    currentTabIndex = index;
    notifyListeners();
  }

  Future<void> adjustReaderFontSize(double delta) async {
    readerFontSize = (readerFontSize + delta).clamp(13.0, 24.0);
    await _prefs?.setDouble('lw_reader_font_size', readerFontSize);
    notifyListeners();
  }

  Future<void> setReaderThemeMode(String mode) async {
    readerThemeMode = mode;
    await _prefs?.setString('lw_reader_theme', mode);
    notifyListeners();
  }

  Future<void> toggleOnlineMode(bool value) async {
    isPhoneOnline = value;
    await _prefs?.setBool('lw_is_online', value);
    if (isPhoneOnline && isSignedInWithGoogle && pendingSyncChanges > 0) {
      await syncNowWithGoogleDrive();
    }
    notifyListeners();
  }

  Future<void> toggleGoogleSignIn() async {
    isSignedInWithGoogle = !isSignedInWithGoogle;
    await _prefs?.setBool('lw_google_signed_in_v3', isSignedInWithGoogle);
    if (isSignedInWithGoogle && isPhoneOnline) {
      await syncNowWithGoogleDrive();
    } else if (!isSignedInWithGoogle) {
      lastBackupLabel = 'Signed out (Local storage active)';
    }
    notifyListeners();
  }

  bool canShowInterstitialWithCooldown() {
    if (!isPhoneOnline) return false;
    if (lastInterstitialShownAt == null) return true;
    return DateTime.now().difference(lastInterstitialShownAt!).inMinutes >= 4;
  }

  Future<void> loadChapter({
    required String book,
    required int chapter,
    String? version,
    int? highlightScrollVerse,
    bool countForAd = true,
  }) async {
    final dwellTime = DateTime.now().difference(_chapterOpenedAt);
    final targetVersion = version ?? activeVersion;
    final bookInfo = repository.getBookInfo(book);
    final safeChapter = chapter.clamp(1, bookInfo.chaptersCount);

    if (ttsService.isPlaying) {
      await ttsService.stop();
    }

    isLoadingChapter = true;
    notifyListeners();

    if (countForAd) {
      _recordDailyActivity();
      if (dwellTime.inSeconds >= 15) {
        chaptersReadCount++;
        xp += 5;
        if (chaptersReadCount % 4 == 0 && canShowInterstitialWithCooldown()) {
          _triggerInterstitialAd('Chapter Transition (Every 4th Read Chapter)');
        }
      }
    }

    currentBook = bookInfo.name;
    currentChapter = safeChapter;
    activeVersion = targetVersion;
    selectedVerseNumber = highlightScrollVerse;

    currentChapterVerses = await repository.getChapterVerses(
      versionCode: activeVersion,
      bookName: currentBook,
      chapterNumber: currentChapter,
    );

    _chapterOpenedAt = DateTime.now();
    isLoadingChapter = false;
    await _persistLocalState();
    notifyListeners();
  }

  void _triggerInterstitialAd(String reason) {
    if (!isPhoneOnline) return;
    lastInterstitialShownAt = DateTime.now();
    interstitialTriggerReason = reason;
    isShowingInterstitialOverlay = true;
    notifyListeners();
  }

  void dismissInterstitialAd() {
    isShowingInterstitialOverlay = false;
    interstitialTriggerReason = null;
    notifyListeners();
  }

  void selectVerse(int? verseNumber) {
    if (selectedVerseNumber == verseNumber) {
      selectedVerseNumber = null;
    } else {
      selectedVerseNumber = verseNumber;
    }
    notifyListeners();
  }

  String _annotationKey(String book, int chapter, int verse) =>
      '$book:$chapter:$verse';

  VerseAnnotation? getAnnotation(String book, int chapter, int verse) {
    return annotations[_annotationKey(book, chapter, verse)];
  }

  Future<void> setVerseHighlightColor({
    required String book,
    required int chapter,
    required int verse,
    required String? colorHex,
  }) async {
    _recordDailyActivity();
    final key = _annotationKey(book, chapter, verse);
    final existing = annotations[key];
    final updated = (existing ??
            VerseAnnotation(
              id: key,
              book: book,
              chapter: chapter,
              verse: verse,
              updatedAtMs: DateTime.now().millisecondsSinceEpoch,
            ))
        .copyWith(
      colorHex: colorHex,
      clearColor: colorHex == null,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    if (updated.isEmpty) {
      annotations.remove(key);
    } else {
      annotations[key] = updated;
    }
    await _persistLocalState();
    notifyListeners();
  }

  Future<void> toggleVerseBookmark({
    required String book,
    required int chapter,
    required int verse,
  }) async {
    _recordDailyActivity();
    final key = _annotationKey(book, chapter, verse);
    final existing = annotations[key];
    final nextBookmarked = !(existing?.isBookmarked ?? false);
    final updated = (existing ??
            VerseAnnotation(
              id: key,
              book: book,
              chapter: chapter,
              verse: verse,
              updatedAtMs: DateTime.now().millisecondsSinceEpoch,
            ))
        .copyWith(
      isBookmarked: nextBookmarked,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    if (updated.isEmpty) {
      annotations.remove(key);
    } else {
      annotations[key] = updated;
    }
    await _persistLocalState();
    notifyListeners();
  }

  Future<void> saveVerseNote({
    required String book,
    required int chapter,
    required int verse,
    required String noteText,
  }) async {
    _recordDailyActivity();
    final key = _annotationKey(book, chapter, verse);
    final existing = annotations[key];
    final cleaned = noteText.trim();
    final updated = (existing ??
            VerseAnnotation(
              id: key,
              book: book,
              chapter: chapter,
              verse: verse,
              updatedAtMs: DateTime.now().millisecondsSinceEpoch,
            ))
        .copyWith(
      note: cleaned.isEmpty ? null : cleaned,
      clearNote: cleaned.isEmpty,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    if (updated.isEmpty) {
      annotations.remove(key);
    } else {
      annotations[key] = updated;
    }
    await _persistLocalState();
    notifyListeners();
  }

  Future<void> markPlanDayCompleted(String planId, int day) async {
    _recordDailyActivity();
    final list = List<int>.from(completedPlanDays[planId] ?? const []);
    if (list.contains(day)) {
      list.remove(day);
    } else {
      list.add(day);
      list.sort();
      xp += 20;
    }
    completedPlanDays[planId] = list;
    await _persistLocalState();
    notifyListeners();
  }

  Future<void> recordQuizAnswer({
    required String questionId,
    required bool isCorrect,
    required int earnedXp,
  }) async {
    _recordDailyActivity();
    quizTotalAttempted++;
    if (isCorrect) {
      quizTotalCorrect++;
      currentQuizStreak++;
      xp += earnedXp;
      if (!answeredQuizIds.contains(questionId)) {
        answeredQuizIds.add(questionId);
      }
    } else {
      currentQuizStreak = 0;
    }
    await _persistLocalState();
    notifyListeners();
  }

  Future<void> downloadBibleVersion(String versionCode) async {
    if (repository.downloadedVersions.contains(versionCode)) return;
    downloadProgress[versionCode] = 0.05;
    notifyListeners();

    await repository.downloadVersionForOffline(
      versionCode: versionCode,
      prefs: _prefs!,
      onProgress: (p) {
        downloadProgress[versionCode] = p;
        notifyListeners();
      },
    );

    downloadProgress.remove(versionCode);
    notifyListeners();
  }

  void openVerseInArtStudio({
    required String verseText,
    required String reference,
  }) {
    studioVerseText = verseText;
    studioVerseRef = reference;
    notifyListeners();
  }

  void onVerseImageSharedOrSaved() {
    if (isPhoneOnline && canShowInterstitialWithCooldown()) {
      _triggerInterstitialAd('After Sharing / Saving Verse Art Card');
    }
  }

  Future<void> updateUmpConsent(String status) async {
    umpConsentStatus = status;
    await _persistLocalState();
    notifyListeners();
  }

  Future<void> deleteAllCloudAndLocalData() async {
    _debounceSyncTimer?.cancel();
    await _prefs?.remove('lw_user_sync_payload_v3');
    await _prefs?.remove('lw_gdrive_appdata_remote_v3');
    await _prefs?.remove('lw_quiz_attempted');
    await _prefs?.remove('lw_quiz_correct');
    _resetToZeroState();
    pendingSyncChanges = 0;
    lastBackupLabel = 'All data reset to 0';
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceSyncTimer?.cancel();
    ttsService.dispose();
    super.dispose();
  }
}
