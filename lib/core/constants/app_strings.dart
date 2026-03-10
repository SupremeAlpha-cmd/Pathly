class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'Pathly';
  static const String appTagline = 'Your personalised path to learning & growth.';

  // Onboarding
  static const List<Map<String, String>> onboardingPages = [
    {
      'title': 'Learn at your own pace',
      'subtitle':
          'Pathly adapts to your level and builds a study plan made just for you — not anyone else.',
    },
    {
      'title': 'Know exactly where you stand',
      'subtitle':
          'A quick diagnostic test shows us your strengths and weak spots so we can focus on what matters.',
    },
    {
      'title': 'From school subjects to real skills',
      'subtitle':
          'Whether you\'re prepping for WAEC or learning to code, Pathly has a path for you.',
    },
  ];

  // Auth
  static const String signUp = 'Create Account';
  static const String logIn = 'Log In';
  static const String fullName = 'Full Name';
  static const String email = 'Email Address';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String orContinueWith = 'Or continue with';

  // Level Selection
  static const String chooseLevelTitle = 'What level are you?';
  static const String chooseLevelSubtitle =
      'This helps us personalise your learning path from the start.';

  // Diagnostic
  static const String diagnosticTitle = 'Quick Knowledge Check';
  static const String diagnosticSubtitle =
      'Answer a few questions so we can understand where you are. No pressure — there are no wrong answers here.';
  static const String diagnosticCta = 'Start Diagnostic';
  static const String questionOf = 'Question';
  static const String of = 'of';

  // Path Generation
  static const String generatingPath = 'Building your path...';
  static const String generatingSubtitle =
      'Our AI is analysing your results and crafting a personalised learning journey just for you.';

  // Dashboard
  static const String goodMorning = 'Good morning';
  static const String goodAfternoon = 'Good afternoon';
  static const String goodEvening = 'Good evening';
  static const String continuelearning = 'Continue Learning';
  static const String yourProgress = 'Your Progress';
  static const String streak = 'Day Streak';
  static const String lessonsCompleted = 'Lessons Done';
  static const String masteryLevel = 'Mastery';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Check your internet connection.';
  static const String authError = 'Invalid email or password.';
  static const String emailInUse = 'This email is already registered.';
  static const String weakPassword = 'Password must be at least 8 characters.';
  static const String passwordMismatch = 'Passwords do not match.';

  // Claude Prompts
  static String studyPathPrompt({
    required String userName,
    required String level,
    required String subject,
    required Map<String, dynamic> diagnosticResults,
  }) {
    return '''
You are Pathly's AI learning engine. Based on the diagnostic results below, generate a personalised study path for this student.

Student: $userName
Level: $level
Subject: $subject
Diagnostic Results: ${diagnosticResults.toString()}

Generate a structured JSON study path with this exact format:
{
  "summary": "2-sentence personalised summary of the student's current level and what the path will focus on",
  "mastery_percentage": <number 0-100 based on diagnostic>,
  "estimated_weeks": <number>,
  "modules": [
    {
      "id": "module_1",
      "title": "Module title",
      "description": "Brief description",
      "is_weak_area": <true if this addresses a gap>,
      "lessons": [
        {
          "id": "lesson_1_1",
          "title": "Lesson title",
          "type": "video|reading|quiz|practice",
          "duration_minutes": <number>,
          "is_unlocked": <true for first lesson only>
        }
      ]
    }
  ]
}

Return ONLY the JSON. No markdown, no explanation.
''';
  }
}