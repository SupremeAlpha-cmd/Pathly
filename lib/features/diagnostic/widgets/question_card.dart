import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'option_tile.dart';

class QuestionCard extends StatelessWidget {
  final int questionNumber;
  final int totalQuestions;
  final String question;
  final List<String> options;
  final int? selectedIndex;
  final bool showResult;
  final int correctIndex;
  final void Function(int) onOptionSelected;

  const QuestionCard({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.question,
    required this.options,
    required this.selectedIndex,
    required this.showResult,
    required this.correctIndex,
    required this.onOptionSelected,
  });

  OptionState _getState(int index) {
    if (!showResult) {
      return selectedIndex == index ? OptionState.selected : OptionState.idle;
    }
    if (index == correctIndex) return OptionState.correct;
    if (index == selectedIndex && selectedIndex != correctIndex)
      return OptionState.incorrect;
    return OptionState.idle;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question number
        Text(
          'Question $questionNumber of $totalQuestions',
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.primary),
        ).animate().fadeIn(),

        const SizedBox(height: 16),

        // Question text
        Text(question, style: AppTextStyles.h2)
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0),

        const SizedBox(height: 32),

        // Options
        ...List.generate(options.length, (index) {
          final labels = ['A', 'B', 'C', 'D'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OptionTile(
              label: labels[index],
              text: options[index],
              state: _getState(index),
              onTap: showResult ? null : () => onOptionSelected(index),
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 80 * index))
                .slideY(begin: 0.1, end: 0),
          );
        }),
      ],
    );
  }
}
