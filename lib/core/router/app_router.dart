import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/level_selection/screens/level_selection_screen.dart';
import '../../features/diagnostic/screens/diagnostic_intro_screen.dart';
import '../../features/diagnostic/screens/diagnostic_quiz_screen.dart';
import '../../features/diagnostic/screens/diagnostic_result_screen.dart';
import '../../features/study_path/screens/path_generating_screen.dart';
import '../../features/study_path/screens/study_path_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import 'package:pathly/features/auth/providers/auth_provider.dart';

// Route names
class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String levelSelection = '/level-selection';
  static const String diagnosticIntro = '/diagnostic/intro';
  static const String diagnosticQuiz = '/diagnostic/quiz';
  static const String diagnosticResult = '/diagnostic/result';
  static const String pathGenerating = '/path/generating';
  static const String studyPath = '/path';
  static const String dashboard = '/dashboard';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.signup;
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isOnboarding = state.matchedLocation == AppRoutes.onboarding;

      if (isSplash || isOnboarding) return null;
      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn && isAuthRoute) return AppRoutes.dashboard;

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _fadeTransition(
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.levelSelection,
        pageBuilder: (context, state) => _slideTransition(
          state: state,
          child: const LevelSelectionScreen(),
        ),
      ),

      GoRoute(
        path: AppRoutes.diagnosticIntro,
        builder: (context, state) {
          final subject = (state.extra is String ? state.extra as String : null)
              ?? state.pathParameters['subject']
              ?? state.uri.queryParameters['subject']
              ?? 'secondary';
          return DiagnosticIntroScreen(subject: subject);
        },
      ),
      GoRoute(
        path: AppRoutes.diagnosticQuiz,
        builder: (context, state) {
          final subject = (state.extra is String ? state.extra as String : null)
              ?? state.pathParameters['subject']
              ?? state.uri.queryParameters['subject']
              ?? 'secondary';
          return DiagnosticQuizScreen(subject: subject);
        },
      ),
      GoRoute(
        path: AppRoutes.diagnosticResult,
        builder: (context, state) {
          final results = (state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null) ?? {};
          return DiagnosticResultScreen(results: results);
        },
      ),
      GoRoute(
        path: AppRoutes.pathGenerating,
        builder: (context, state) {
          final data = (state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null) ?? {};
          return PathGeneratingScreen(data: data);
        },
      ),
      GoRoute(
        path: AppRoutes.studyPath,
        builder: (context, state) {
          final pathData = state.extra is Map<String, dynamic> ? state.extra as Map<String, dynamic> : null;
          return StudyPathScreen(pathData: pathData);
        },
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});

CustomTransitionPage<void> _fadeTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<void> _slideTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}