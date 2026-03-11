import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';

class DiagnosticIntroScreen extends StatelessWidget {
  final String subject;

  const DiagnosticIntroScreen({super.key, required this.subject});

  String get _levelLabel {
    switch (subject) {
      case 'primary':
        return 'Primary School';
      case 'secondary':
        return 'Secondary School';
      case 'university':
        return 'University';
      case 'skills':
        return 'Skills & Career';
      default:
        return subject;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.levelSelection),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Illustration
            Center(
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      size: 42,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 500.ms).scale(
                  begin: const Offset(0.8, 0.8),
                  curve: Curves.easeOutBack,
                ),

            const SizedBox(height: 32),

            // Level chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _levelLabel,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.primary),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            Text(AppStrings.diagnosticTitle, style: AppTextStyles.displayMedium)
                .animate()
                .fadeIn(delay: 250.ms)
                .slideY(begin: 0.2, end: 0),

            const SizedBox(height: 12),

            Text(AppStrings.diagnosticSubtitle, style: AppTextStyles.bodyLarge)
                .animate()
                .fadeIn(delay: 300.ms),

            const SizedBox(height: 32),

            _buildExpectationItem(
              icon: Icons.timer_outlined,
              title: '5–8 minutes',
              subtitle: 'Quick, focused questions',
              delay: 350,
            ),
            const SizedBox(height: 12),
            _buildExpectationItem(
              icon: Icons.lightbulb_outline_rounded,
              title: 'No wrong answers',
              subtitle: 'This helps us understand you better',
              delay: 400,
            ),
            const SizedBox(height: 12),
            _buildExpectationItem(
              icon: Icons.auto_awesome_rounded,
              title: 'AI builds your path',
              subtitle: 'A personalised plan generated just for you',
              delay: 450,
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () =>
                  context.push(AppRoutes.diagnosticQuiz, extra: subject),
              child: const Text('Start Diagnostic'),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildExpectationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required int delay,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.labelLarge),
            Text(subtitle, style: AppTextStyles.bodySmall),
          ],
        ),
      ],
    )
        .animate()
        .fadeIn(delay: Duration(milliseconds: delay))
        .slideX(begin: 0.2, end: 0);
  }
}
