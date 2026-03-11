import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../services/claude_service.dart';
import '../../../services/supabase_service.dart';
import '../../../providers/auth_provider.dart';

class PathGeneratingScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  const PathGeneratingScreen({super.key, required this.data});

  @override
  ConsumerState<PathGeneratingScreen> createState() =>
      _PathGeneratingScreenState();
}

class _PathGeneratingScreenState extends ConsumerState<PathGeneratingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  String _statusMessage = 'Analysing your results...';
  int _step = 0;

  final List<String> _steps = [
    'Analysing your results...',
    'Identifying your strengths...',
    'Mapping your weak areas...',
    'Crafting your personalised path...',
    'Almost ready...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _generatePath();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _generatePath() async {
    // Cycle through status messages
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      setState(() {
        _step = i;
        _statusMessage = _steps[i];
      });
    }

    try {
      final user = ref.read(currentUserProvider);
      final userName = user?.userMetadata?['full_name'] as String? ?? 'there';

      final studyPath = await AIService.generateStudyPath(
  userName: userName,
  level: widget.data['level'] as String,
  subject: widget.data['subject'] as String, // separate subject later
  diagnosticResults: widget.data,
);

      // Save to Supabase
      await SupabaseService.saveStudyPath(
        level: widget.data['level'] as String,
        pathData: studyPath,
        masteryPercentage:
            (studyPath['mastery_percentage'] as num?)?.toInt() ?? 0,
        estimatedWeeks: (studyPath['estimated_weeks'] as num?)?.toInt() ?? 4,
      );

      // Update streak
      await SupabaseService.updateStreak();

      if (!mounted) return;
      context.go(AppRoutes.studyPath, extra: studyPath);
    } catch (e) {
      if (!mounted) return;
      // On error, navigate with empty path so app doesn't get stuck
      context.go(AppRoutes.studyPath, extra: <String, dynamic>{});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated orb
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1.0 + (_pulseController.value * 0.08);
                  return Transform.scale(
                    scale: scale,
                    child: child,
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withOpacity(0.12),
                  ),
                  child: Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white.withOpacity(0.18),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.white,
                        size: 44,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 56),

              Text(
                AppStrings.generatingPath,
                style: AppTextStyles.displayMedium
                    .copyWith(color: AppColors.white),
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 16),

              Text(
                AppStrings.generatingSubtitle,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 56),

              // Step indicators
              Column(
                children: List.generate(_steps.length, (index) {
                  final isDone = index < _step;
                  final isCurrent = index == _step;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      opacity: index <= _step ? 1.0 : 0.25,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? AppColors.white
                                  : isCurrent
                                      ? AppColors.white.withOpacity(0.3)
                                      : Colors.transparent,
                              border: Border.all(
                                color: AppColors.white.withOpacity(0.5),
                                width: 1.5,
                              ),
                            ),
                            child: isDone
                                ? const Icon(Icons.check_rounded,
                                    color: AppColors.primary, size: 12)
                                : isCurrent
                                    ? const SizedBox(
                                        width: 10,
                                        height: 10,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor: AlwaysStoppedAnimation(
                                              AppColors.white),
                                        ),
                                      )
                                    : null,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _steps[index],
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                              fontWeight:
                                  isCurrent ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

              const Spacer(),

              Text(
                'This usually takes about 10 seconds',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.white.withOpacity(0.4),
                ),
              ).animate().fadeIn(delay: 1000.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
