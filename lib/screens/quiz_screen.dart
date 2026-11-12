import 'dart:async';
import 'package:flutter/material.dart';
import '../models/bible_models.dart';
import '../state/app_state.dart';

class QuizScreen extends StatefulWidget {
  final AppState appState;

  const QuizScreen({super.key, required this.appState});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String _selectedDifficulty = 'all'; // all, easy, medium, hard
  int _questionCursor = 0;
  int? _selectedOptionIndex;
  final Set<int> _hiddenOptionIndices = {};
  bool _isWatchingRewardedAd = false;
  int _rewardedCountdown = 3;

  List<QuizQuestion> _filteredQuestions() {
    final all = widget.appState.repository.quizQuestions;
    if (_selectedDifficulty == 'all') return all;
    return all.where((q) => q.difficulty == _selectedDifficulty).toList();
  }

  void _nextQuestion(int totalCount) {
    setState(() {
      _questionCursor = (_questionCursor + 1) % totalCount;
      _selectedOptionIndex = null;
      _hiddenOptionIndices.clear();
    });
  }

  Future<void> _watchAdFor5050Hint(QuizQuestion currentQ) async {
    if (!widget.appState.isPhoneOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connect to internet for free ad hint.'),
        ),
      );
      return;
    }
    if (_hiddenOptionIndices.isNotEmpty || _selectedOptionIndex != null) return;

    setState(() {
      _isWatchingRewardedAd = true;
      _rewardedCountdown = 3;
    });

    for (var i = 3; i > 0; i--) {
      if (!mounted) return;
      setState(() => _rewardedCountdown = i);
      await Future<void>.delayed(const Duration(milliseconds: 700));
    }

    if (!mounted) return;
    // Eliminate 2 wrong options
    final wrongIndices = <int>[];
    for (var i = 0; i < currentQ.options.length; i++) {
      if (i != currentQ.correctIndex) {
        wrongIndices.add(i);
      }
    }
    wrongIndices.shuffle();

    setState(() {
      _isWatchingRewardedAd = false;
      _hiddenOptionIndices.addAll(wrongIndices.take(2));
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final questions = _filteredQuestions();
    if (questions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final currentQ = questions[_questionCursor % questions.length];
    final levelNum = (appState.xp ~/ 150) + 1;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E1B4B),
            Color(0xFF0F172A),
          ],
        ),
      ),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header matching Page 3 Left Mockup
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Bible Trivia • Level $levelNum',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    // Glowing XP Circle Badge
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF4F46E5)],
                        ),
                        border: Border.all(
                          color: const Color(0xFFC4B5FD),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF8B5CF6).withValues(alpha: 0.45),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${appState.xp}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                              height: 1.0,
                            ),
                          ),
                          const Text(
                            'XP',
                            style: TextStyle(
                              color: Color(0xFFDDD6FE),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Difficulty Filter Chips
                Row(
                  children: ['all', 'easy', 'medium', 'hard'].map((diff) {
                    final active = _selectedDifficulty == diff;
                    final label =
                        diff[0].toUpperCase() + diff.substring(1);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: active,
                        selectedColor: const Color(0xFFD97706),
                        backgroundColor: const Color(0xFF1E293B),
                        labelStyle: TextStyle(
                          color: active ? Colors.white : const Color(0xFFCBD5E1),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedDifficulty = diff;
                            _questionCursor = 0;
                            _selectedOptionIndex = null;
                            _hiddenOptionIndices.clear();
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // White Question Card matching Page 3 Left Mockup
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${currentQ.difficulty.toUpperCase()} • +${currentQ.xp} XP',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentQ.question,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // 4 Multiple Choice Option Buttons
                ...List.generate(currentQ.options.length, (optIdx) {
                  if (_hiddenOptionIndices.contains(optIdx)) {
                    return const SizedBox.shrink();
                  }
                  final optionText = currentQ.options[optIdx];
                  final hasAnswered = _selectedOptionIndex != null;
                  final isCorrect = optIdx == currentQ.correctIndex;
                  final isChosen = _selectedOptionIndex == optIdx;

                  Color bgColor = Colors.white;
                  Color textColor = const Color(0xFF0F172A);
                  IconData? trailingIcon;

                  if (hasAnswered) {
                    if (isCorrect) {
                      bgColor = const Color(0xFF10B981); // Emerald Green
                      textColor = Colors.white;
                      trailingIcon = Icons.check_rounded;
                    } else if (isChosen) {
                      bgColor = const Color(0xFFEF4444); // Red
                      textColor = Colors.white;
                      trailingIcon = Icons.close_rounded;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: hasAnswered
                          ? null
                          : () {
                              setState(() {
                                _selectedOptionIndex = optIdx;
                              });
                              appState.recordQuizAnswer(
                                questionId: currentQ.id,
                                isCorrect: isCorrect,
                                earnedXp: currentQ.xp,
                              );
                            },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.16),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 22),
                            Expanded(
                              child: Text(
                                optionText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 22,
                              child: trailingIcon != null
                                  ? Icon(
                                      trailingIcon,
                                      color: Colors.white,
                                      size: 22,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                // Explanation & Next Question Card after answering
                if (_selectedOptionIndex != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF475569)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _selectedOptionIndex == currentQ.correctIndex
                                  ? Icons.check_circle_rounded
                                  : Icons.info_rounded,
                              color: _selectedOptionIndex == currentQ.correctIndex
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFFFBBF24),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Scripture Reference: ${currentQ.reference}',
                              style: const TextStyle(
                                color: Color(0xFFFDE047),
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentQ.explanation,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _nextQuestion(questions.length),
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('Next Trivia Question'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Gold Rewarded Video Ad Button matching Page 3 Left Mockup & Offline Rule
                InkWell(
                  onTap: () => _watchAdFor5050Hint(currentQ),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: appState.isPhoneOnline
                            ? const [Color(0xFFF59E0B), Color(0xFFD97706)]
                            : const [Color(0xFF475569), Color(0xFF334155)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'AD',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            appState.isPhoneOnline
                                ? (_hiddenOptionIndices.isNotEmpty
                                    ? '50/50 Hint Applied (2 Wrong Options Hidden)'
                                    : 'Watch Short Ad for 50/50 Hint')
                                : 'Connect to internet for free ad hint',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Simulated Rewarded Ad Overlay
          if (_isWatchingRewardedAd)
            Container(
              color: Colors.black.withValues(alpha: 0.85),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.ondemand_video_rounded,
                      color: Color(0xFFF59E0B),
                      size: 42,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Google AdMob Rewarded Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unlocking 50/50 Quiz Hint in $_rewardedCountdown s...',
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
