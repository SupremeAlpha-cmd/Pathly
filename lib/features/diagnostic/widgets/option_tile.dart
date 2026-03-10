import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

enum OptionState { idle, selected, correct, incorrect }

class OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final OptionState state;
  final VoidCallback? onTap;

  const OptionTile({
    super.key,
    required this.label,
    required this.text,
    required this.state,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final bgColor = _getBgColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: color, width: state == OptionState.idle ? 1.5 : 2),
        ),
        child: Row(
          children: [
            // Label bubble
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: state == OptionState.idle
                    ? AppColors.surfaceVariant
                    : color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: state == OptionState.correct
                    ? Icon(Icons.check_rounded, color: color, size: 18)
                    : state == OptionState.incorrect
                        ? Icon(Icons.close_rounded, color: color, size: 18)
                        : Text(
                            label,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: state == OptionState.selected
                                  ? color
                                  : AppColors.grey500,
                            ),
                          ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: state == OptionState.idle ? AppColors.dark : color,
                  fontWeight: state != OptionState.idle
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColor() {
    switch (state) {
      case OptionState.selected:
        return AppColors.primary;
      case OptionState.correct:
        return AppColors.success;
      case OptionState.incorrect:
        return AppColors.error;
      case OptionState.idle:
        return AppColors.grey100;
    }
  }

  Color _getBgColor() {
    switch (state) {
      case OptionState.selected:
        return AppColors.primarySurface;
      case OptionState.correct:
        return const Color(0xFFE8FAF0);
      case OptionState.incorrect:
        return const Color(0xFFFEECEC);
      case OptionState.idle:
        return AppColors.surface;
    }
  }
}
