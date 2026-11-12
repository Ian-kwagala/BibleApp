import 'package:flutter_test/flutter_test.dart';
import 'package:lightword_bible/models/bible_models.dart';

void main() {
  group('LightWord Bible v2.0 Blueprint Fixes Verification', () {
    test('Fix #3: UserSyncPayload CRDT merge preserves multi-device offline edits', () {
      const deviceA = UserSyncPayload(
        streakDays: 14,
        lastActiveDate: '2026-11-11',
        xp: 450,
        activeVersion: 'WEB',
        lastBook: 'John',
        lastChapter: 3,
        annotations: {
          'John:3:16': VerseAnnotation(
            id: 'John:3:16',
            book: 'John',
            chapter: 3,
            verse: 16,
            colorHex: '#FDE68A',
            note: 'Note from Device A',
            isBookmarked: true,
            updatedAtMs: 1000,
          ),
        },
        completedPlanDays: {
          '30_days_of_peace': [1, 2, 3],
        },
        answeredQuizIds: ['q1', 'q2'],
        umpConsentStatus: 'personalized',
        updatedAtMs: 1000,
      );

      const deviceB = UserSyncPayload(
        streakDays: 16,
        lastActiveDate: '2026-11-12',
        xp: 520,
        activeVersion: 'KJV',
        lastBook: 'Psalms',
        lastChapter: 23,
        annotations: {
          'Psalms:23:1': VerseAnnotation(
            id: 'Psalms:23:1',
            book: 'Psalms',
            chapter: 23,
            verse: 1,
            colorHex: '#BBF7D0',
            note: 'Note from Device B',
            isBookmarked: true,
            updatedAtMs: 2000,
          ),
        },
        completedPlanDays: {
          '30_days_of_peace': [3, 4, 5],
        },
        answeredQuizIds: ['q2', 'q3'],
        umpConsentStatus: 'non_personalized',
        updatedAtMs: 2000,
      );

      final merged = deviceA.mergeWith(deviceB);

      expect(merged.streakDays, 16);
      expect(merged.xp, 520);
      expect(merged.annotations.containsKey('John:3:16'), isTrue);
      expect(merged.annotations.containsKey('Psalms:23:1'), isTrue);
      expect(merged.completedPlanDays['30_days_of_peace'], [1, 2, 3, 4, 5]);
      expect(merged.answeredQuizIds.toSet(), {'q1', 'q2', 'q3'});
      expect(merged.umpConsentStatus, 'non_personalized');
    });
  });
}
