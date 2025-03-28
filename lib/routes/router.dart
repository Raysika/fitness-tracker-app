import 'package:fitness_tracker/screens/auth/complete_profile_screen.dart';
import 'package:fitness_tracker/screens/auth/goal_selection_screen.dart';
import 'package:fitness_tracker/screens/auth/welcome_screen.dart';
import 'package:fitness_tracker/screens/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/screens/auth/login_screen.dart';
import 'package:fitness_tracker/screens/auth/signup_screen.dart';
import 'package:fitness_tracker/screens/dashboard/home_screen.dart';
import 'package:fitness_tracker/screens/onboarding/onboarding_screen.dart';
import 'routes.dart'; // Import the routes.dart file

final GoRouter appRouter = GoRouter(
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
      path: AppRoutes.login, // Use named constant
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup, // Use named constant
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
      path: AppRoutes.home, // Use named constant
      builder: (context, state) => const HomeScreen(),
      // {
      //   return const HomeScreen(); // Always navigate to HomeScreen
      //   // final user = Supabase.instance.client.auth.currentUser;
      //   // return user != null ? HomeScreen() : LoginScreen();
      // },
    ),
  ],
);
