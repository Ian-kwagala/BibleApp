import 'package:flutter/material.dart';
import '../models/bible_models.dart';
import '../state/app_state.dart';
import 'verse_art_studio_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;

  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _selectedMoodId;

  static const List<Map<String, dynamic>> _dailyVerses = [
    {
      'ref': 'Philippians 4:13',
      'book': 'Philippians',
      'chapter': 4,
      'verse': 13,
      'text': 'I can do all things through Christ who strengthens me.',
    },
    {
      'ref': 'Psalm 46:10',
      'book': 'Psalms',
      'chapter': 46,
      'verse': 10,
      'text': 'Be still, and know that I am God.',
    },
    {
      'ref': 'John 3:16',
      'book': 'John',
      'chapter': 3,
      'verse': 16,
      'text':
          'For God so loved the world, that he gave his one and only Son, that whoever believes in him should not perish, but have eternal life.',
    },
  ];

  int _dailyVerseIndex = 0;

  Color _parseHexColor(String hex) {
    final cleaned = hex.replaceAll('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final currentDaily = _dailyVerses[_dailyVerseIndex % _dailyVerses.length];
    final isDailyBookmarked = appState
            .getAnnotation(
              currentDaily['book'] as String,
              currentDaily['chapter'] as int,
              currentDaily['verse'] as int,
            )
            ?.isBookmarked ??
        false;

    final activePlan = appState.repository.readingPlans.firstWhere(
      (p) => p.id == appState.activePlanId,
      orElse: () => appState.repository.readingPlans.first,
    );
    final completedDays =
        appState.completedPlanDays[activePlan.id] ?? const <int>[];
    final nextDayNum = completedDays.length < activePlan.totalDays
        ? completedDays.length + 1
        : activePlan.totalDays;
    final nextPlanDay = activePlan.days.firstWhere(
      (d) => d.day == nextDayNum,
      orElse: () => activePlan.days.first,
    );
    final progressFraction =
        (completedDays.length / activePlan.totalDays).clamp(0.0, 1.0);
    final progressPercent = (progressFraction * 100).round();

    MoodCategory? activeMood;
    if (_selectedMoodId != null) {
      for (final m in appState.repository.moods) {
        if (m.id == _selectedMoodId) {
          activeMood = m;
          break;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top App Header matching Page 1 Mockup
          Row(
            children: [
              const Expanded(
                child: Text(
                  'LightWord Bible',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.4,
                  ),
                ),
              ),
              // Streak pill badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department_rounded,
                      color: Color(0xFFD97706),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${appState.streakDays} Day Streak',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Profile avatar button -> jumps to Versions & Cloud Backup
              InkWell(
                onTap: () => appState.setTabIndex(3),
                borderRadius: BorderRadius.circular(999),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFD97706),
                  child: Text(
                    appState.googleUserName.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Section Header: Verse of the Day
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Verse of the Day',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _dailyVerseIndex =
                        (_dailyVerseIndex + 1) % _dailyVerses.length;
                  });
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Next Verse'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFB45309),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Scenic Golden Sunset Verse of the Day Card
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFF59E0B),
                  Color(0xFFB45309),
                  Color(0xFF451A03),
                  Color(0xFF1E1B4B),
                ],
                stops: [0.0, 0.35, 0.75, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB45309).withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Subtle sun glow ornament in top-right corner
                Positioned(
                  top: -25,
                  right: -15,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFEF08A).withValues(alpha: 0.65),
                          const Color(0xFFFDE047).withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentDaily['ref'] as String,
                        style: const TextStyle(
                          color: Color(0xFFFEF3C7),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          appState.loadChapter(
                            book: currentDaily['book'] as String,
                            chapter: currentDaily['chapter'] as int,
                            highlightScrollVerse: currentDaily['verse'] as int,
                          );
                          appState.setTabIndex(1);
                        },
                        child: Text(
                          '“${currentDaily['text']}”',
                          style: const TextStyle(
                            fontFamily: 'Georgia',
                            color: Colors.white,
                            fontSize: 21,
                            height: 1.38,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          // Share Image button -> opens Verse Art Studio
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                appState.openVerseInArtStudio(
                                  verseText: currentDaily['text'] as String,
                                  reference: currentDaily['ref'] as String,
                                );
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => VerseArtStudioScreen(
                                      appState: appState,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.ios_share_rounded,
                                size: 17,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Share Image',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.45),
                                ),
                                backgroundColor:
                                    Colors.black.withValues(alpha: 0.22),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Bookmark button
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                appState.toggleVerseBookmark(
                                  book: currentDaily['book'] as String,
                                  chapter: currentDaily['chapter'] as int,
                                  verse: currentDaily['verse'] as int,
                                );
                              },
                              icon: Icon(
                                isDailyBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                size: 18,
                                color: isDailyBookmarked
                                    ? const Color(0xFFFDE047)
                                    : Colors.white,
                              ),
                              label: Text(
                                isDailyBookmarked ? 'Bookmarked' : 'Bookmark',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.45),
                                ),
                                backgroundColor:
                                    Colors.black.withValues(alpha: 0.22),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Mood Verse Finder Section matching Page 1 Mockup
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap any mood chip for comforting verses & a short prayer',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: appState.repository.moods.map((mood) {
                    final isSelected = _selectedMoodId == mood.id;
                    final chipColor = _parseHexColor(mood.colorHex);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedMoodId = isSelected ? null : mood.id;
                        });
                      },
                      borderRadius: BorderRadius.circular(999),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? chipColor
                              : chipColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isSelected
                                ? chipColor
                                : chipColor.withValues(alpha: 0.45),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              mood.emoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              mood.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Expanded Mood Verses & Prayer Card when a mood is tapped
                if (activeMood != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7F2),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _parseHexColor(activeMood.colorHex)
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${activeMood.emoji} Comfort for When You Feel ${activeMood.label}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () =>
                                  setState(() => _selectedMoodId = null),
                              icon: const Icon(Icons.close_rounded, size: 18),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7).withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.volunteer_activism_rounded,
                                size: 18,
                                color: Color(0xFFB45309),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Short Prayer: "${activeMood.prayer}"',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontStyle: FontStyle.italic,
                                    color: Color(0xFF78350F),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...activeMood.verses.map((v) {
                          final vText = appState.activeVersion == 'KJV'
                              ? v.textKjv
                              : (appState.activeVersion == 'BBE'
                                  ? v.textBbe
                                  : v.textWeb);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${v.reference} (${appState.activeVersion})',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                          color: Color(0xFFB45309),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              appState.openVerseInArtStudio(
                                                verseText: vText,
                                                reference: v.reference,
                                              );
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      VerseArtStudioScreen(
                                                    appState: appState,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              child: Text(
                                                'Art Card',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF1E3A8A),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          InkWell(
                                            onTap: () {
                                              appState.loadChapter(
                                                book: v.book,
                                                chapter: v.chapter,
                                                highlightScrollVerse: v.verse,
                                              );
                                              appState.setTabIndex(1);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              child: Text(
                                                'Open Chapter →',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: Color(0xFFB45309),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    vText,
                                    style: const TextStyle(
                                      fontFamily: 'Georgia',
                                      fontSize: 14,
                                      height: 1.45,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Continue Reading Plan Card matching Page 1 Mockup
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Continue Reading Plan',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: activePlan.id,
                        isDense: true,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309),
                        ),
                        items: appState.repository.readingPlans
                            .map(
                              (p) => DropdownMenuItem<String>(
                                value: p.id,
                                child: Text(p.title),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              appState.activePlanId = val;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${activePlan.title} (Day $nextDayNum/${activePlan.totalDays})',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    Text(
                      '$progressPercent%',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progressFraction,
                    minHeight: 9,
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Next: ${nextPlanDay.book} ${nextPlanDay.chapter} • ${nextPlanDay.title}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        appState.markPlanDayCompleted(
                          activePlan.id,
                          nextPlanDay.day,
                        );
                        appState.loadChapter(
                          book: nextPlanDay.book,
                          chapter: nextPlanDay.chapter,
                        );
                        appState.setTabIndex(1);
                      },
                      icon: const Icon(Icons.menu_book_rounded, size: 16),
                      label: const Text('Read Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Quick Actions Row: Bible Trivia Quiz + Verse Art Studio + Bookmarks
          Row(
            children: [
              Expanded(
                child: _QuickFeatureTile(
                  icon: Icons.emoji_events_rounded,
                  title: 'Bible Quiz',
                  subtitle: '${appState.xp} XP • Daily Trivia',
                  color: const Color(0xFF4F46E5),
                  onTap: () => appState.setTabIndex(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickFeatureTile(
                  icon: Icons.palette_rounded,
                  title: 'Verse Art Studio',
                  subtitle: 'Share HD Cards',
                  color: const Color(0xFF059669),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VerseArtStudioScreen(
                          appState: appState,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickFeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickFeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
