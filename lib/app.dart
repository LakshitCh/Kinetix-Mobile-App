import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/workout_selection/workout_selection_screen.dart';
import 'screens/active_workout/active_workout_screen.dart';
import 'screens/workout_summary/workout_summary_screen.dart';
import 'screens/stats/stats_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'widgets/bottom_nav.dart';
import 'core/theme/app_colors.dart';

/// GoRouter configuration — maps React routes to Flutter screens.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Onboarding (standalone — no bottom nav)
    GoRoute(
      path: '/',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // Auth (standalone — no bottom nav)
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),

    // Main shell with BottomNav
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              child,
              const BottomNav(),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const HomeScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/stats',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const StatsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const CalendarScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => CustomTransitionPage(
            child: const ProfileScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
      ],
    ),

    // Workout Selection (standalone with back button)
    GoRoute(
      path: '/workout-select',
      builder: (context, state) {
        final category = state.extra as String?;
        return WorkoutSelectionScreen(initialCategory: category);
      },
    ),

    // Active Workout (standalone — full-screen camera)
    GoRoute(
      path: '/active-workout',
      builder: (context, state) {
        final params = state.uri.queryParameters;
        return ActiveWorkoutScreen(
          exercise: params['exercise'] ?? 'Squats',
          targetReps: int.tryParse(params['reps'] ?? '10') ?? 10,
        );
      },
    ),

    // Workout Summary (standalone)
    GoRoute(
      path: '/summary',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return WorkoutSummaryScreen(
          reps: data?['reps'] ?? 0,
          time: data?['time'] ?? 0,
          exercise: data?['exercise'] ?? 'Workout',
        );
      },
    ),
  ],
);
