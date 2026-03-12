import 'package:flutter_test/flutter_test.dart';
import 'package:pathly/features/diagnostic/utils/diagnostic_calculator.dart';

void main() {
  group('DiagnosticCalculator Tests', () {
    final questions = [
      {'question': 'Q1', 'correct': 1, 'topic': 'math'},
      {'question': 'Q2', 'correct': 2, 'topic': 'english'},
      {'question': 'Q3', 'correct': 1, 'topic': 'math'},
    ];

    test('calculates correct score and percentage', () {
      final answers = {0: 1, 1: 0, 2: 1}; // 2 correct out of 3
      final result = DiagnosticCalculator.calculateResults(
        level: 'secondary',
        questions: questions,
        answers: answers,
      );

      expect(result['score'], 2);
      expect(result['total'], 3);
      expect(result['percentage'], 67); // (2/3 * 100).round() = 67
    });

    test('calculates topic-specific scores', () {
      final answers = {0: 1, 1: 2, 2: 0}; // math: 1/2, english: 1/1
      final result = DiagnosticCalculator.calculateResults(
        level: 'secondary',
        questions: questions,
        answers: answers,
      );

      final topicScores = result['topic_scores'] as Map<String, Map<String, int>>;
      
      expect(topicScores['math']!['correct'], 1);
      expect(topicScores['math']!['total'], 2);
      expect(topicScores['english']!['correct'], 1);
      expect(topicScores['english']!['total'], 1);
    });

    test('handles empty questions list', () {
      final result = DiagnosticCalculator.calculateResults(
        level: 'secondary',
        questions: [],
        answers: {},
      );

      expect(result['score'], 0);
      expect(result['percentage'], 0);
    });
  });
}
