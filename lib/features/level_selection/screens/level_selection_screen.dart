import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../widgets/level_card.dart';

class LevelData {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const LevelData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

const _levels = [
  LevelData(
    id: 'primary',
    title: 'Primary School',
    subtitle: 'Basic 1 – 6 • Foundational learning',
    icon: Icons.auto_stories_rounded,
    color: Color(0xFF3B82F6),
  ),
  LevelData(
    id: 'secondary',
    title: 'Secondary School',
    subtitle: 'JSS1 – SS3 • WAEC & JAMB prep',
    icon: Icons.school_rounded,
    color: Color(0xFF1A7F5A),
  ),
  LevelData(
    id: 'university',
    title: 'University',
    subtitle: 'Undergraduate & postgraduate courses',
    icon: Icons.account_balance_rounded,
    color: Color(0xFF8B5CF6),
  ),
  LevelData(
    id: 'skills',
    title: 'Skills & Career',
    subtitle: 'Tech, design, finance & life skills',
    icon: Icons.rocket_launch_rounded,
    color: Color(0xFFFFB830),
  ),
];

class LevelSelectionScreen extends StatefulWidget {
  const LevelSelectionScreen({super.key});

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen> {
  String? _selectedLevel;

  void _continue() {
    if (_selectedLevel == null) return;
    context.go(
      AppRoutes.diagnosticIntro,
      extra: _selectedLevel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Header
              Text(AppStrings.chooseLevelTitle,
                      style: AppTextStyles.displayMedium)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 12),

              Text(AppStrings.chooseLevelSubtitle,
                      style: AppTextStyles.bodyLarge)
                  .animate()
                  .fadeIn(delay: 100.ms),

              const SizedBox(height: 40),

              // Level cards
              Expanded(
                child: ListView.separated(
                  itemCount: _levels.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final level = _levels[index];
                    return LevelCard(
                      title: level.title,
                      subtitle: level.subtitle,
                      icon: level.icon,
                      color: level.color,
                      isSelected: _selectedLevel == level.id,
                      onTap: () => setState(() => _selectedLevel = level.id),
                      animationIndex: index + 1,
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _selectedLevel != null ? 1.0 : 0.4,
                child: ElevatedButton(
                  onPressed: _selectedLevel != null ? _continue : null,
                  child: const Text('Continue'),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
