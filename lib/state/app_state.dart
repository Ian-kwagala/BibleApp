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
  int currentTabIndex = 0; // 0: Home, 1: Read, 2: Quiz, 3: Versions, 4: Profile/Studio

  // Reader state
  String activeVersion = 'WEB';
  String currentBook = 'John';
  int currentChapter = 3;
  List<String> currentChapterVerses = [];
  bool isLoadingChapter = false;
  int? selectedVerseNumber; // 1-indexed selected verse for toolbar/compare

  // Dwell-time tracking for Blueprint v2.0 Fix #6 (AdMob Accidental Click Prevention)
  DateTime _chapterOpenedAt = DateTime.now();
  int chaptersReadCount = 0;
  DateTime? lastInterstitialShownAt;
  bool isShowingInterstitialOverlay = false;
  String? interstitialTriggerReason;

  // Connectivity & AdMob state
  bool isPhoneOnline = true;

  // Google Sign-In & Drive appDataFolder Sync state (Blueprint v2.0 Fix #3)
  bool isSignedInWithGoogle = true;
  String googleUserEmail = 'reader@gmail.com';
  String googleUserName = 'Grace Walker';
  String lastBackupLabel = 'Just now';
  bool isSyncingDrive = false;
  int pendingSyncChanges = 0;
  Timer? _debounceSyncTimer;

  // Study & Habit state
  int streakDays = 14;
  String lastActiveDate = '';
  int xp = 450;
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

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await repository.initialize(_prefs!);

    // Load local saved state or initialize blueprint default state
    final savedJson = _prefs!.getString('lw_user_sync_payload_v2');
    if (savedJson != null && savedJson.isNotEmpty) {
      try {
        final payload = UserSyncPayload.fromJson(
          jsonDecode(savedJson) as Map<String, dynamic>,
        );
        _applyPayload(payload);
      } catch (_) {
        _seedInitialBlueprintState();
      }
    } else {
      _seedInitialBlueprintState();
      await _persistLocalState();
    }

    isPhoneOnline = _prefs!.getBool('lw_is_online') ?? true;
    isSignedInWithGoogle = _prefs!.getBool('lw_google_signed_in') ?? true;

    await loadChapter(
      book: currentBook,
      chapter: currentChapter,
      version: activeVersion,
      countForAd: false,
    );

    isInitialized = true;
    notifyListeners();
  }

  void _seedInitialBlueprintState() {
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final todayStr = _todayIsoString();
    streakDays = 14;
    lastActiveDate = todayStr;
    xp = 450;
    activeVersion = 'WEB';
    currentBook = 'John';
    currentChapter = 3;
    annotations = {
      'John:3:16': VerseAnnotation(
        id: 'John:3:16',
        book: 'John',
        chapter: 3,
        verse: 16,
        colorHex: '#FDE68A', // Warm Yellow highlight matching Page 2 mockup
        note: "God's sacrificial unconditional love for humanity",
        isBookmarked: true,
        updatedAtMs: nowMs,
      ),
      'Philippians:4:13': VerseAnnotation(
        id: 'Philippians:4:13',
        book: 'Philippians',
        chapter: 4,
        verse: 13,
        colorHex: '#BBF7D0', // Soft Green highlight
        note: 'Strength for every season through Christ',
        isBookmarked: true,
        updatedAtMs: nowMs,
      ),
      'Psalms:46:10': VerseAnnotation(
        id: 'Psalms:46:10',
        book: 'Psalms',
        chapter: 46,
        verse: 10,
        colorHex: '#BFDBFE', // Calm Blue highlight
        isBookmarked: true,
        updatedAtMs: nowMs,
      ),
    };
    completedPlanDays = {
      '30_days_of_peace': List.generate(13, (i) => i + 1), // Day 14/30 next!
      'gospels_in_30_days': [1, 2, 3, 4],
    };
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

  /// Step 1 of Sync Blueprint: Always save immediately to local storage first (100% offline-first).
  Future<void> _persistLocalState() async {
    final payload = buildSyncPayload();
    await _prefs?.setString('lw_user_sync_payload_v2', payload.toJsonString());
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

    // Read simulated/stored remote Google Drive `appDataFolder/user_bible_sync.json`
    final remoteRaw = _prefs?.getString('lw_gdrive_appdata_remote_json');
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
    await _prefs?.setString('lw_gdrive_appdata_remote_json', mergedJson);
    await _prefs?.setString('lw_user_sync_payload_v2', mergedJson);

    pendingSyncChanges = 0;
    lastBackupLabel = 'Just now';
    isSyncingDrive = false;
    notifyListeners();
  }

  void setTabIndex(int index) {
    currentTabIndex = index;
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
    await _prefs?.setBool('lw_google_signed_in', isSignedInWithGoogle);
    if (isSignedInWithGoogle && isPhoneOnline) {
      await syncNowWithGoogleDrive();
    }
    notifyListeners();
  }

  /// Implements Blueprint v2.0 Fix #6:
  /// Dwell-time + 4-minute cooldown check before showing a full-screen interstitial ad.
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

    // Blueprint v2.0 Fix #6: Only increment chaptersReadCount if user stayed >= 15s
    // (or when testing explicit chapter navigation after reading)
    if (countForAd && dwellTime.inSeconds >= 15) {
      chaptersReadCount++;
      if (chaptersReadCount % 4 == 0 && canShowInterstitialWithCooldown()) {
        _triggerInterstitialAd('Chapter Transition (Every 4th Read Chapter)');
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

  /// Allows testing or triggering the controlled full-screen interstitial ad
  /// (after saving/sharing a Verse Image OR every 4th read chapter when online).
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
    if (isCorrect) {
      xp += earnedXp;
      if (!answeredQuizIds.contains(questionId)) {
        answeredQuizIds.add(questionId);
      }
      final today = _todayIsoString();
      if (lastActiveDate != today) {
        streakDays++;
        lastActiveDate = today;
      }
      await _persistLocalState();
      notifyListeners();
    }
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

  /// Implements Blueprint v2.0 Fix #7:
  /// Google Play Mandatory In-App Account & Cloud Data Deletion.
  Future<void> deleteAllCloudAndLocalData() async {
    _debounceSyncTimer?.cancel();
    await _prefs?.remove('lw_user_sync_payload_v2');
    await _prefs?.remove('lw_gdrive_appdata_remote_json');
    annotations.clear();
    completedPlanDays.clear();
    answeredQuizIds.clear();
    streakDays = 1;
    xp = 0;
    pendingSyncChanges = 0;
    lastBackupLabel = 'Deleted';
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceSyncTimer?.cancel();
    ttsService.dispose();
    super.dispose();
  }
}
