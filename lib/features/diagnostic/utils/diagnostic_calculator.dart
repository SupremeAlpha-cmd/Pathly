class DiagnosticCalculator {
  static Map<String, dynamic> calculateResults({
    required String level,
    required List<Map<String, dynamic>> questions,
    required Map<int, int?> answers,
  }) {
    int correct = 0;
    final topicScores = <String, Map<String, int>>{};

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final topic = q['topic'] as String? ?? 'general';
      
      topicScores[topic] ??= {'correct': 0, 'total': 0};
      topicScores[topic]!['total'] = topicScores[topic]!['total']! + 1;

      if (answers[i] == q['correct']) {
        correct++;
        topicScores[topic]!['correct'] = topicScores[topic]!['correct']! + 1;
      }
    }

    final percentage = questions.isEmpty 
        ? 0 
        : (correct / questions.length * 100).round();

    return {
      'level': level,
      'score': correct,
      'total': questions.length,
      'percentage': percentage,
      'topic_scores': topicScores,
      'answers': answers,
    };
  }
}
