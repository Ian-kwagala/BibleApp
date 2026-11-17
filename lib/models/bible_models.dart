import 'dart:convert';

class BibleVersionInfo {
  final String code;
  final String name;
  final String description;
  final bool bundled;
  final double sizeMb;
  final String downloadUrl;

  const BibleVersionInfo({
    required this.code,
    required this.name,
    required this.description,
    required this.bundled,
    required this.sizeMb,
    required this.downloadUrl,
  });

  factory BibleVersionInfo.fromJson(Map<String, dynamic> json) {
    return BibleVersionInfo(
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      bundled: json['bundled'] as bool? ?? false,
      sizeMb: (json['sizeMb'] as num?)?.toDouble() ?? 4.0,
      downloadUrl: json['downloadUrl'] as String? ?? '',
    );
  }
}

class BibleBookInfo {
  final int index;
  final String name;
  final String abbrev;
  final String testament;
  final int chaptersCount;
  final List<int> verseCounts;

  const BibleBookInfo({
    required this.index,
    required this.name,
    required this.abbrev,
    required this.testament,
    required this.chaptersCount,
    required this.verseCounts,
  });

  factory BibleBookInfo.fromJson(Map<String, dynamic> json) {
    return BibleBookInfo(
      index: json['index'] as int,
      name: json['name'] as String,
      abbrev: json['abbrev'] as String,
      testament: json['testament'] as String,
      chaptersCount: json['chaptersCount'] as int,
      verseCounts: (json['verseCounts'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
    );
  }
}

class VerseAnnotation {
  final String id; // e.g. "John:3:16"
  final String book;
  final int chapter;
  final int verse;
  final String? colorHex; // Yellow, Green, Blue, Pink
  final String? note;
  final bool isBookmarked;
  final int updatedAtMs;

  const VerseAnnotation({
    required this.id,
    required this.book,
    required this.chapter,
    required this.verse,
    this.colorHex,
    this.note,
    this.isBookmarked = false,
    required this.updatedAtMs,
  });

  bool get isEmpty =>
      (colorHex == null || colorHex!.isEmpty) &&
      (note == null || note!.trim().isEmpty) &&
      !isBookmarked;

  VerseAnnotation copyWith({
    String? colorHex,
    bool clearColor = false,
    String? note,
    bool clearNote = false,
    bool? isBookmarked,
    int? updatedAtMs,
  }) {
    return VerseAnnotation(
      id: id,
      book: book,
      chapter: chapter,
      verse: verse,
      colorHex: clearColor ? null : (colorHex ?? this.colorHex),
      note: clearNote ? null : (note ?? this.note),
      isBookmarked: isBookmarked ?? this.isBookmarked,
      updatedAtMs: updatedAtMs ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'book': book,
        'chapter': chapter,
        'verse': verse,
        'colorHex': colorHex,
        'note': note,
        'isBookmarked': isBookmarked,
        'updatedAtMs': updatedAtMs,
      };

  factory VerseAnnotation.fromJson(Map<String, dynamic> json) {
    return VerseAnnotation(
      id: json['id'] as String,
      book: json['book'] as String,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
      colorHex: json['colorHex'] as String?,
      note: json['note'] as String?,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      updatedAtMs: json['updatedAtMs'] as int? ?? 0,
    );
  }
}

class MoodVerseItem {
  final String reference;
  final String book;
  final int chapter;
  final int verse;
  final String textWeb;
  final String textKjv;
  final String textBbe;

  const MoodVerseItem({
    required this.reference,
    required this.book,
    required this.chapter,
    required this.verse,
    required this.textWeb,
    required this.textKjv,
    required this.textBbe,
  });

  factory MoodVerseItem.fromJson(Map<String, dynamic> json) {
    return MoodVerseItem(
      reference: json['reference'] as String,
      book: json['book'] as String,
      chapter: json['chapter'] as int,
      verse: json['verse'] as int,
      textWeb: json['textWeb'] as String,
      textKjv: json['textKjv'] as String,
      textBbe: json['textBbe'] as String,
    );
  }
}

class MoodCategory {
  final String id;
  final String label;
  final String emoji;
  final String colorHex;
  final String prayer;
  final List<MoodVerseItem> verses;

  const MoodCategory({
    required this.id,
    required this.label,
    required this.emoji,
    required this.colorHex,
    required this.prayer,
    required this.verses,
  });

  factory MoodCategory.fromJson(Map<String, dynamic> json) {
    return MoodCategory(
      id: json['id'] as String,
      label: json['label'] as String,
      emoji: json['emoji'] as String,
      colorHex: json['colorHex'] as String,
      prayer: json['prayer'] as String,
      verses: (json['verses'] as List<dynamic>)
          .map((e) => MoodVerseItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ReadingPlanDay {
  final int day;
  final String book;
  final int chapter;
  final String title;

  const ReadingPlanDay({
    required this.day,
    required this.book,
    required this.chapter,
    required this.title,
  });

  factory ReadingPlanDay.fromJson(Map<String, dynamic> json) {
    return ReadingPlanDay(
      day: json['day'] as int,
      book: json['book'] as String,
      chapter: json['chapter'] as int,
      title: json['title'] as String,
    );
  }
}

class ReadingPlan {
  final String id;
  final String title;
  final String subtitle;
  final int totalDays;
  final String category;
  final List<ReadingPlanDay> days;

  const ReadingPlan({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.totalDays,
    required this.category,
    required this.days,
  });

  factory ReadingPlan.fromJson(Map<String, dynamic> json) {
    return ReadingPlan(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      totalDays: json['totalDays'] as int,
      category: json['category'] as String,
      days: (json['days'] as List<dynamic>)
          .map((e) => ReadingPlanDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizQuestion {
  final String id;
  final String difficulty; // easy, medium, hard
  final int xp;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String reference;
  final String explanation;

  const QuizQuestion({
    required this.id,
    required this.difficulty,
    required this.xp,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.reference,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      difficulty: json['difficulty'] as String,
      xp: json['xp'] as int,
      question: json['question'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      correctIndex: json['correctIndex'] as int,
      reference: json['reference'] as String,
      explanation: json['explanation'] as String,
    );
  }
}

/// Represents the user's complete study state saved locally and synced to
/// Google Drive `appDataFolder/user_bible_sync.json` (< 50 KB).
/// Implements Blueprint v2.0 Fix #3: CRDT-style timestamp & set-union merging
/// so offline edits across multiple devices never overwrite each other.
class UserSyncPayload {
  final int streakDays;
  final String lastActiveDate; // YYYY-MM-DD
  final int xp;
  final String activeVersion;
  final String lastBook;
  final int lastChapter;
  final Map<String, VerseAnnotation> annotations;
  final Map<String, List<int>> completedPlanDays; // planId -> list of day ints
  final List<String> answeredQuizIds;
  final String umpConsentStatus; // "obtained", "not_required", "personalized", "non_personalized"
  final int updatedAtMs;

  const UserSyncPayload({
    required this.streakDays,
    required this.lastActiveDate,
    required this.xp,
    required this.activeVersion,
    required this.lastBook,
    required this.lastChapter,
    required this.annotations,
    required this.completedPlanDays,
    required this.answeredQuizIds,
    required this.umpConsentStatus,
    required this.updatedAtMs,
  });

  /// Merges local and remote payloads without losing data from either device.
  UserSyncPayload mergeWith(UserSyncPayload remote) {
    // 1. Merge annotations by id using latest updatedAtMs timestamp
    final mergedAnnotations = <String, VerseAnnotation>{...annotations};
    for (final entry in remote.annotations.entries) {
      final existing = mergedAnnotations[entry.key];
      if (existing == null || entry.value.updatedAtMs > existing.updatedAtMs) {
        mergedAnnotations[entry.key] = entry.value;
      }
    }

    // 2. Union completed reading plan days
    final mergedPlans = <String, List<int>>{};
    final allPlanIds = {
      ...completedPlanDays.keys,
      ...remote.completedPlanDays.keys,
    };
    for (final pid in allPlanIds) {
      final unionDays = <int>{
        ...(completedPlanDays[pid] ?? const []),
        ...(remote.completedPlanDays[pid] ?? const []),
      }.toList()
        ..sort();
      mergedPlans[pid] = unionDays;
    }

    // 3. Union answered quiz IDs
    final mergedQuizIds = <String>{
      ...answeredQuizIds,
      ...remote.answeredQuizIds,
    }.toList();

    final isRemoteNewer = remote.updatedAtMs > updatedAtMs;

    return UserSyncPayload(
      streakDays:
          streakDays > remote.streakDays ? streakDays : remote.streakDays,
      lastActiveDate: lastActiveDate.compareTo(remote.lastActiveDate) >= 0
          ? lastActiveDate
          : remote.lastActiveDate,
      xp: xp > remote.xp ? xp : remote.xp,
      activeVersion: isRemoteNewer ? remote.activeVersion : activeVersion,
      lastBook: isRemoteNewer ? remote.lastBook : lastBook,
      lastChapter: isRemoteNewer ? remote.lastChapter : lastChapter,
      annotations: mergedAnnotations,
      completedPlanDays: mergedPlans,
      answeredQuizIds: mergedQuizIds,
      umpConsentStatus:
          isRemoteNewer ? remote.umpConsentStatus : umpConsentStatus,
      updatedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': 2,
        'streakDays': streakDays,
        'lastActiveDate': lastActiveDate,
        'xp': xp,
        'activeVersion': activeVersion,
        'lastBook': lastBook,
        'lastChapter': lastChapter,
        'annotations':
            annotations.map((key, value) => MapEntry(key, value.toJson())),
        'completedPlanDays': completedPlanDays,
        'answeredQuizIds': answeredQuizIds,
        'umpConsentStatus': umpConsentStatus,
        'updatedAtMs': updatedAtMs,
      };

  String toJsonString() => jsonEncode(toJson());

  factory UserSyncPayload.fromJson(Map<String, dynamic> json) {
    final rawAnn = json['annotations'] as Map<String, dynamic>? ?? {};
    final parsedAnn = <String, VerseAnnotation>{};
    for (final entry in rawAnn.entries) {
      parsedAnn[entry.key] =
          VerseAnnotation.fromJson(entry.value as Map<String, dynamic>);
    }

    final rawPlans = json['completedPlanDays'] as Map<String, dynamic>? ?? {};
    final parsedPlans = <String, List<int>>{};
    for (final entry in rawPlans.entries) {
      parsedPlans[entry.key] =
          (entry.value as List<dynamic>).map((e) => e as int).toList();
    }

    return UserSyncPayload(
      streakDays: json['streakDays'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] as String? ?? '',
      xp: json['xp'] as int? ?? 0,
      activeVersion: json['activeVersion'] as String? ?? 'WEB',
      lastBook: json['lastBook'] as String? ?? 'John',
      lastChapter: json['lastChapter'] as int? ?? 3,
      annotations: parsedAnn,
      completedPlanDays: parsedPlans,
      answeredQuizIds: (json['answeredQuizIds'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      umpConsentStatus: json['umpConsentStatus'] as String? ?? 'personalized',
      updatedAtMs: json['updatedAtMs'] as int? ?? 0,
    );
  }
}
