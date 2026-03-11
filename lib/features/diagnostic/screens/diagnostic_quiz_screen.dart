import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../widgets/question_card.dart';

// Static diagnostic questions per level
final Map<String, List<Map<String, dynamic>>> _questionBank = {
  'primary': [
    {
      'question': 'What is 24 ÷ 6?',
      'options': ['3', '4', '5', '6'],
      'correct': 1,
      'topic': 'arithmetic',
    },
    {
      'question': 'Which of these is a vowel?',
      'options': ['B', 'C', 'E', 'G'],
      'correct': 2,
      'topic': 'english',
    },
    {
      'question': 'How many sides does a triangle have?',
      'options': ['2', '3', '4', '5'],
      'correct': 1,
      'topic': 'shapes',
    },
    {
      'question': 'What is the capital of Nigeria?',
      'options': ['Lagos', 'Kano', 'Abuja', 'Ibadan'],
      'correct': 2,
      'topic': 'social_studies',
    },
    {
      'question': 'Which animal is called the king of the jungle?',
      'options': ['Elephant', 'Tiger', 'Lion', 'Gorilla'],
      'correct': 2,
      'topic': 'general_knowledge',
    },
  ],
  'secondary': [
    {
      'question': 'Simplify: 3x + 5x - 2x',
      'options': ['4x', '5x', '6x', '8x'],
      'correct': 2,
      'topic': 'algebra',
    },
    {
      'question': 'What is the chemical symbol for water?',
      'options': ['CO2', 'H2O', 'O2', 'NaCl'],
      'correct': 1,
      'topic': 'chemistry',
    },
    {
      'question': 'In which year did Nigeria gain independence?',
      'options': ['1957', '1960', '1963', '1966'],
      'correct': 1,
      'topic': 'history',
    },
    {
      'question': 'What is the value of π (pi) to 2 decimal places?',
      'options': ['3.12', '3.14', '3.16', '3.18'],
      'correct': 1,
      'topic': 'mathematics',
    },
    {
      'question':
          'Which literary device is used in "The wind whispered secrets"?',
      'options': ['Simile', 'Metaphor', 'Personification', 'Hyperbole'],
      'correct': 2,
      'topic': 'english_literature',
    },
    {
      'question': 'What is the powerhouse of the cell?',
      'options': ['Nucleus', 'Ribosome', 'Mitochondria', 'Cell membrane'],
      'correct': 2,
      'topic': 'biology',
    },
  ],
  'university': [
    {
      'question': 'What does CPU stand for?',
      'options': [
        'Central Processing Unit',
        'Computer Personal Unit',
        'Central Program Utility',
        'Core Processing Unit'
      ],
      'correct': 0,
      'topic': 'computer_science',
    },
    {
      'question': 'Which of these is NOT a programming paradigm?',
      'options': ['Object-Oriented', 'Functional', 'Relational', 'Procedural'],
      'correct': 2,
      'topic': 'programming',
    },
    {
      'question': 'What does GDP stand for in economics?',
      'options': [
        'General Domestic Product',
        'Gross Domestic Product',
        'Global Development Plan',
        'Gross Development Projection'
      ],
      'correct': 1,
      'topic': 'economics',
    },
    {
      'question':
          'In accounting, what does the equation Assets = Liabilities + _____ represent?',
      'options': ['Revenue', 'Profit', 'Equity', 'Capital'],
      'correct': 2,
      'topic': 'accounting',
    },
    {
      'question': 'What is the time complexity of binary search?',
      'options': ['O(n)', 'O(n²)', 'O(log n)', 'O(1)'],
      'correct': 2,
      'topic': 'algorithms',
    },
    {
      'question': 'Which hormone regulates blood sugar levels?',
      'options': ['Adrenaline', 'Insulin', 'Cortisol', 'Thyroxine'],
      'correct': 1,
      'topic': 'biology',
    },
  ],
  'skills': [
    {
      'question': 'In web development, what does HTML stand for?',
      'options': [
        'Hyper Text Markup Language',
        'High Tech Modern Language',
        'Hyper Transfer Markup Layer',
        'Home Tool Markup Language'
      ],
      'correct': 0,
      'topic': 'web_dev',
    },
    {
      'question': 'What is compound interest?',
      'options': [
        'Interest on the principal only',
        'Interest on principal and accumulated interest',
        'A fixed monthly bank charge',
        'Interest paid only at maturity',
      ],
      'correct': 1,
      'topic': 'financial_literacy',
    },
    {
      'question': 'In design, what does UI stand for?',
      'options': [
        'Uniform Interface',
        'User Interface',
        'Universal Integration',
        'Unique Illustration'
      ],
      'correct': 1,
      'topic': 'design',
    },
    {
      'question': 'Which of these is a version control system?',
      'options': ['Figma', 'Git', 'Slack', 'Trello'],
      'correct': 1,
      'topic': 'dev_tools',
    },
    {
      'question': 'What does ROI stand for in business?',
      'options': [
        'Rate of Income',
        'Return on Investment',
        'Revenue on Interest',
        'Record of Income'
      ],
      'correct': 1,
      'topic': 'business',
    },
  ],
};

class DiagnosticQuizScreen extends StatefulWidget {
  final String subject;
  const DiagnosticQuizScreen({super.key, required this.subject});

  @override
  State<DiagnosticQuizScreen> createState() => _DiagnosticQuizScreenState();
}

class _DiagnosticQuizScreenState extends State<DiagnosticQuizScreen> {
  late List<Map<String, dynamic>> _questions;
  int _currentIndex = 0;
  int? _selectedOption;
  bool _showResult = false;
  final Map<int, int?> _answers = {};
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _questions = _questionBank[widget.subject] ?? _questionBank['secondary']!;
  }

  void _selectOption(int index) {
    if (_showResult || _isAnimating) return;
    setState(() {
      _selectedOption = index;
      _showResult = true;
      _answers[_currentIndex] = index;
    });
  }

  Future<void> _next() async {
    if (_isAnimating) return;
    setState(() => _isAnimating = true);

    await Future.delayed(const Duration(milliseconds: 300));

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = _answers[_currentIndex];
        _showResult = _answers.containsKey(_currentIndex);
        _isAnimating = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    // Calculate results
    int correct = 0;
    final topicScores = <String, Map<String, int>>{};

    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      final topic = q['topic'] as String;
      topicScores[topic] ??= {'correct': 0, 'total': 0};
      topicScores[topic]!['total'] = topicScores[topic]!['total']! + 1;

      if (_answers[i] == q['correct']) {
        correct++;
        topicScores[topic]!['correct'] = topicScores[topic]!['correct']! + 1;
      }
    }

    final results = {
      'level': widget.subject,
      'score': correct,
      'total': _questions.length,
      'percentage': (correct / _questions.length * 100).round(),
      'topic_scores': topicScores,
      'answers': _answers,
    };

    context.push(AppRoutes.diagnosticResult, extra: results);
  }

  @override
  Widget build(BuildContext context) {
    final q = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.go(AppRoutes.levelSelection),
        ),
        title: Text(
          '${_currentIndex + 1} of ${_questions.length}',
          style: AppTextStyles.labelLarge,
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${(progress * 100).round()}%',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.grey100,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 4,
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: QuestionCard(
                key: ValueKey(_currentIndex),
                questionNumber: _currentIndex + 1,
                totalQuestions: _questions.length,
                question: q['question'] as String,
                options: List<String>.from(q['options'] as List),
                selectedIndex: _selectedOption,
                showResult: _showResult,
                correctIndex: q['correct'] as int,
                onOptionSelected: _selectOption,
              ),
            ),
          ),

          // Bottom button
          if (_showResult)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: ElevatedButton(
                onPressed: _next,
                child: Text(
                  _currentIndex < _questions.length - 1
                      ? 'Next Question'
                      : 'See My Results',
                ),
              ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.3, end: 0),
            ),
        ],
      ),
    );
  }
}
