import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AIService {
  static const String _model = 'gemini-1.5-flash';
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get _baseUrl =>
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey';

  /// Generate a personalised study path from diagnostic results
  static Future<Map<String, dynamic>> generateStudyPath({
    required String userName,
    required String level,
    required String subject,
    required Map<String, dynamic> diagnosticResults,
  }) async {
    final prompt = _buildStudyPathPrompt(
      userName: userName,
      level: level,
      subject: subject,
      diagnosticResults: diagnosticResults,
    );

    final response = await _sendMessage(prompt);
    final parsed = _parseJsonResponse(response);
    return parsed as Map<String, dynamic>;
  }

  /// Get an AI explanation for a lesson concept
  static Future<String> explainConcept({
    required String concept,
    required String level,
    required String subject,
  }) async {
    final prompt = '''
Explain "$concept" for a $level student studying $subject in Nigeria.
- Use simple, clear language
- Give one relatable Nigerian example (e.g., using local markets, Nigerian food, or famous landmarks like Zuma Rock)
- Keep it under 150 words
- End with one key "Nugget of Wisdom" line
''';
    return await _sendMessage(prompt);
  }

  /// Generate adaptive quiz questions based on performance
  static Future<List<Map<String, dynamic>>> generateQuizQuestions({
    required String subject,
    required String topic,
    required String level,
    required int count,
    required double masteryScore,
  }) async {
    final difficulty = masteryScore < 40
        ? 'easy'
        : masteryScore < 70
            ? 'medium'
            : 'hard';

    final prompt = '''
Generate $count multiple-choice quiz questions for:
Subject: $subject
Topic: $topic
Level: $level
Difficulty: $difficulty (based on mastery score: ${masteryScore.toStringAsFixed(0)}%)
Strictly aligned with the Nigerian NERDC/WAEC/JAMB curriculum.

Contextualise questions for Nigeria (e.g., use Naira (₦) for math, Nigerian names like Chinedu/Amina, and local geography).

Return ONLY a JSON array with no markdown or extra text:
[
  {
    "id": "q1",
    "question": "Question text",
    "options": ["A. option", "B. option", "C. option", "D. option"],
    "correct_index": 0,
    "explanation": "Brief explanation of the correct answer"
  }
]
''';

    final response = await _sendMessage(prompt);
    final parsed = _parseJsonResponse(response);
    if (parsed is List) {
      return List<Map<String, dynamic>>.from(parsed);
    }
    return [];
  }

  // ─── Private Methods ───────────────────────────────────────────────

  static Future<String> _sendMessage(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1500,
          },
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'Gemini API error: ${response.statusCode} ${response.body}');
      }

      final data = jsonDecode(response.body);
      final candidates = data['candidates'] as List;
      final content = candidates[0]['content']['parts'] as List;
      return content[0]['text'] as String;
    } catch (e) {
      debugPrint('❌ AIService._sendMessage error: $e');
      rethrow;
    }
  }

  static dynamic _parseJsonResponse(String raw) {
    try {
      // Find the first '[' or '{' and last ']' or '}'
      int firstBracket = raw.indexOf(RegExp(r'\[|\{'));
      int lastBracket = raw.lastIndexOf(RegExp(r'\]|\}'));

      if (firstBracket == -1 || lastBracket == -1) {
        throw const FormatException('No JSON structure found in response');
      }

      final jsonString = raw.substring(firstBracket, lastBracket + 1);
      return jsonDecode(jsonString);
    } catch (e) {
      debugPrint('❌ AIService._parseJsonResponse error: $e');
      debugPrint('Raw response was: $raw');
      rethrow;
    }
  }

  static String _buildStudyPathPrompt({
    required String userName,
    required String level,
    required String subject,
    required Map<String, dynamic> diagnosticResults,
  }) {
    return '''
You are Pathly's AI learning engine, an expert Nigerian tutor. Generate a personalised study path.

Student: $userName
Level: $level
Subject: $subject
Diagnostic Results: ${jsonEncode(diagnosticResults)}

Instructions:
1. Analyse the diagnostic results to identify gaps.
2. Structure the path to focus on weak areas first.
3. Use a tone that is encouraging and relatable to a Nigerian student.
4. Align with NERDC (Nigerian Educational Research and Development Council) standards.

Return ONLY this JSON structure with no markdown or extra text:
{
  "summary": "2-sentence personalised message to the student using their name. Mention specific strengths found and how we'll fix the gaps.",
  "mastery_percentage": <0-100 based on diagnostic performance>,
  "estimated_weeks": <realistic number, usually 4-12>,
  "focus_areas": ["topic1", "topic2"],
  "modules": [
    {
      "id": "module_1",
      "title": "Module title",
      "description": "What this module covers",
      "is_weak_area": <true if addressing a gap>,
      "order": 1,
      "lessons": [
        {
          "id": "lesson_1_1",
          "title": "Lesson title",
          "type": "video|reading|quiz|practice",
          "duration_minutes": <5-30>,
          "is_unlocked": <true for first lesson only, false otherwise>
        }
      ]
    }
  ]
}
''';
  }
}
