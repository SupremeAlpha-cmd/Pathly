import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class ProgressRing extends StatelessWidget {
  final int percentage;
  final String label;
  final Color color;
  final double size;

  const ProgressRing({
    super.key,
    required this.percentage,
    required this.label,
    this.color = AppColors.primary,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      radius: size / 2,
      lineWidth: 7,
      percent: (percentage / 100).clamp(0.0, 1.0),
      animation: true,
      animationDuration: 1000,
      circularStrokeCap: CircularStrokeCap.round,
      progressColor: color,
      backgroundColor: color.withOpacity(0.1),
      center: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$percentage%',
            style: AppTextStyles.h3.copyWith(color: color, fontSize: 14),
          ),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
