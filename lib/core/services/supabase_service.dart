import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;
  static String? get _userId => _client.auth.currentUser?.id;

  // ── PROFILE ────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getProfile() async {
    if (_userId == null) return null;
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', _userId!)
          .maybeSingle();
      return response;
    } catch (e, stack) {
      debugPrint('❌ SupabaseService.getProfile error: $e');
      debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  static Future<void> updateProfile({
    String? fullName,
    String? level,
    String? avatarUrl,
  }) async {
    if (_userId == null) return;
    try {
      await _client.from('profiles').upsert({
        'id': _userId,
        if (fullName != null) 'full_name': fullName,
        if (level != null) 'level': level,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      });
    } catch (e, stack) {
      debugPrint('❌ SupabaseService.updateProfile error: $e');
      debugPrintStack(stackTrace: stack);
    }
  }

  // ── DIAGNOSTIC RESULTS ─────────────────────────────────────

  static Future<void> saveDiagnosticResult({
    required String level,
    required int score,
    required int total,
    required int percentage,
    required Map<String, dynamic> topicScores,
  }) async {
    if (_userId == null) return;
    try {
      await _client.from('diagnostic_results').insert({
        'user_id': _userId,
        'level': level,
        'score': score,
        'total': total,
        'percentage': percentage,
        'topic_scores': topicScores,
      });
    } catch (e, stack) {
      debugPrint('❌ SupabaseService.saveDiagnosticResult error: $e');
      debugPrintStack(stackTrace: stack);
    }
  }

  static Future<Map<String, dynamic>?> getLatestDiagnosticResult() async {
    if (_userId == null) return null;
    try {
      final response = await _client
          .from('diagnostic_results')
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      return response;
    } catch (e, stack) {
      debugPrint('❌ SupabaseService.getLatestDiagnosticResult error: $e');
      debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  // ── STUDY PATHS ────────────────────────────────────────────

  static Future<void> saveStudyPath({
    required String level,
    required Map<String, dynamic> pathData,
    required int masteryPercentage,
    required int estimatedWeeks,
  }) async {
    if (_userId == null) return;
    try {
      await _client.from('study_paths').upsert({
        'user_id': _userId,
        'level': level,
        'path_data': pathData,
        'mastery_percentage': masteryPercentage,
        'estimated_weeks': estimatedWeeks,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
    } catch (e, stack) {
      debugPrint('❌ SupabaseService.saveStudyPath error: $e');
      debugPrintStack(stackTrace: stack);
    }
  }

  static Future<Map<String, dynamic>?> getStudyPath() async {
    if (_userId == null) return null;
    try {
      final response = await _client
          .from('study_paths')
          .select()
          .eq('user_id', _userId!)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (response == null) return null;
      return response['path_data'] as Map<String, dynamic>?;
    } catch (e, stack) {
      debugPrint('❌ SupabaseService.getStudyPath error: $e');
      debugPrintStack(stackTrace: stack);
      return null;
    }
  }

  // ── PROGRESS ───────────────────────────────────────────────

  static Future<void> markLessonComplete({
    required String lessonId,
    required String moduleId,
    int? score,
  }) async {
    if (_userId == null) return;
    try {
      await _client.from('progress').upsert({
        'user_id': _userId,
        'lesson_id': lessonId,
        'module_id': moduleId,
        'is_completed': true,
        if (score != null) 'score': score,
        'completed_at': DateTime.now().toIso8601String(),
      });
    } catch (e, stack) {
      debugPrint('❌ SupabaseService.markLessonComplete error: $e');
      debugPrintStack(stackTrace: stack);
    }
  }

  static Future<List<String>> getCompletedLessons() async {
    if (_userId == null) return [];
    try {
      final response = await _client
          .from('progress')
          .select('lesson_id')
          .eq('user_id', _userId!)
          .eq('is_completed', true);
      return List<Map<String, dynamic>>.from(response)
          .map((r) => r['lesson_id'] as String)
          .toList();
    } catch (e, stack) {
      debugPrint('❌ SupabaseService.getCompletedLessons error: $e');
      debugPrintStack(stackTrace: stack);
      return [];
    }
  }

  static Future<int> getCompletedLessonsCount() async {
    if (_userId == null) return 0;
    try {
      final response = await _client
          .from('progress')
          .select('id')
          .eq('user_id', _userId!)
          .eq('is_completed', true);
      return (response as List).length;
    } catch (e, stack) {
      debugPrint('❌ SupabaseService.getCompletedLessonsCount error: $e');
      debugPrintStack(stackTrace: stack);
      return 0;
    }
  }

  // ── STREAKS ────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getStreak() async {
    if (_userId == null) return {'current_streak': 0, 'longest_streak': 0};
    try {
      final response = await _client
          .from('streaks')
          .select()
          .eq('user_id', _userId!)
          .maybeSingle();

      if (response == null) {
        // Create streak record for new user
        final newStreak = {
          'user_id': _userId,
          'current_streak': 1,
          'longest_streak': 1,
          'last_active_date': DateTime.now().toIso8601String().split('T')[0],
        };
        await _client.from('streaks').insert(newStreak);
        return newStreak;
      }

      return response;
    } catch (e, stack) {
      debugPrint('❌ SupabaseService.getStreak error: $e');
      debugPrintStack(stackTrace: stack);
      return {'current_streak': 0, 'longest_streak': 0};
    }
  }

  static Future<void> updateStreak() async {
    if (_userId == null) return;
    try {
      final streak = await getStreak();
      final lastActive = streak['last_active_date'] as String?;
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (lastActive == today) return; // Already updated today

      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .split('T')[0];

      final currentStreak = lastActive == yesterday
          ? (streak['current_streak'] as int) + 1
          : 1; // Reset if missed a day

      final longestStreak = currentStreak > (streak['longest_streak'] as int)
          ? currentStreak
          : streak['longest_streak'] as int;

      await _client.from('streaks').update({
        'current_streak': currentStreak,
        'longest_streak': longestStreak,
        'last_active_date': today,
      }).eq('user_id', _userId!);
    } catch (e, stack) {
      debugPrint('❌ SupabaseService.updateStreak error: $e');
      debugPrintStack(stackTrace: stack);
    }
  }
}
