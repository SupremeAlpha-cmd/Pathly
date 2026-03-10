import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class LessonTile extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final int index;

  const LessonTile({super.key, required this.lesson, required this.index});

  bool get _isUnlocked => lesson['is_unlocked'] == true;
  String get _type => lesson['type'] as String? ?? 'reading';
  int get _duration => lesson['duration_minutes'] as int? ?? 10;

  IconData get _typeIcon {
    switch (_type) {
      case 'video': return Icons.play_circle_outline_rounded;
      case 'quiz': return Icons.quiz_outlined;
      case 'practice': return Icons.edit_note_rounded;
      default: return Icons.menu_book_rounded;
    }
  }

  Color get _typeColor {
    switch (_type) {
      case 'video': return AppColors.info;
      case 'quiz': return AppColors.accent;
      case 'practice': return AppColors.success;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isUnlocked ? 1.0 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Type icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _isUnlocked
                    ? _typeColor.withOpacity(0.1)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _isUnlocked ? _typeIcon : Icons.lock_outline_rounded,
                color: _isUnlocked ? _typeColor : AppColors.grey300,
                size: 18,
              ),
            ),

            const SizedBox(width: 12),

            // Title + duration
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson['title'] as String? ?? 'Lesson',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: _isUnlocked ? AppColors.dark : AppColors.grey500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_duration min · ${_type[0].toUpperCase()}${_type.substring(1)}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),

            if (_isUnlocked)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.grey300,
              ),
          ],
        ),
      ),
    );
  }
}