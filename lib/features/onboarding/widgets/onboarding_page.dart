import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final int pageIndex;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration placeholder
          _buildIllustration(pageIndex),
          const SizedBox(height: 48),

          Text(
            title,
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          Text(
            subtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.grey500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(int index) {
    final configs = [
      {'icon': Icons.auto_awesome_rounded, 'color': AppColors.primary},
      {'icon': Icons.track_changes_rounded, 'color': AppColors.accent},
      {'icon': Icons.rocket_launch_rounded, 'color': AppColors.info},
    ];

    final config = configs[index % configs.length];

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: (config['color'] as Color).withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: (config['color'] as Color).withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            config['icon'] as IconData,
            size: 56,
            color: config['color'] as Color,
          ),
        ),
      ),
    );
  }
}
