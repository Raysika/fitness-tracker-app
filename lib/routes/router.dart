// lib/routes/router.dart

import 'package:fitness_tracker/screens/auth/complete_profile_screen.dart';
import 'package:fitness_tracker/screens/auth/goal_selection_screen.dart';
import 'package:fitness_tracker/screens/auth/welcome_screen.dart';
import 'package:fitness_tracker/screens/dashboard/main_tab_view.dart';
import 'package:fitness_tracker/screens/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/screens/auth/login_screen.dart';
import 'package:fitness_tracker/screens/auth/signup_screen.dart';
import 'package:fitness_tracker/screens/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late SharedPreferences prefs;

Future<void> initRouter() async {
  prefs = await SharedPreferences.getInstance();
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: (context, state) async {
    final supabase = Supabase.instance.client;
    final isAuthenticated = supabase.auth.currentUser != null;
    final hasCompletedOnboarding =
        prefs.getBool('completed_onboarding') ?? false;

    // Current route
    final currentPath = state.matchedLocation;

    // Check if route is splash screen
    if (currentPath == AppRoutes.splash) {
      return null; // Allow access to splash screen
    }

    // Handling authentication and onboarding flow
    if (isAuthenticated) {
      // User is authenticated

      // If trying to access auth routes or onboarding when already logged in
      if (currentPath == AppRoutes.login ||
          currentPath == AppRoutes.signup ||
          currentPath == AppRoutes.onboarding) {
        return AppRoutes.home;
      }

      // Normal authenticated flow - allow access to any route
      return null;
    } else {
      // User is not authenticated

      // If hasn't completed onboarding yet, direct to onboarding
      if (!hasCompletedOnboarding) {
        if (currentPath == AppRoutes.onboarding) {
          return null; // Allow access to onboarding
        }
        return AppRoutes.onboarding;
      }

      // If has completed onboarding but not at auth screen, send to login
      if (currentPath != AppRoutes.login &&
          currentPath != AppRoutes.signup &&
          currentPath != AppRoutes.completeProfile &&
          currentPath != AppRoutes.goalSelection &&
          currentPath != AppRoutes.welcome) {
        return AppRoutes.login;
      }

      // Handle signup flow - check if at profile step or goal selection
      if (currentPath == AppRoutes.completeProfile ||
          currentPath == AppRoutes.goalSelection ||
          currentPath == AppRoutes.welcome) {
        // Only allow if user is going through signup process
        final isSigningUp = prefs.getBool('is_signing_up') ?? false;
        if (!isSigningUp) {
          return AppRoutes.login;
        }
      }

      // Allow access to current auth route
      return null;
    }
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
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup,
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.completeProfile,
      builder: (context, state) => const CompleteProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.goalSelection,
      builder: (context, state) => const GoalSelectionScreen(),
    ),
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const MainTabView(),
    ),
  ],
);
