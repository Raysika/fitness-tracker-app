import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/screens/auth/login_screen.dart';
import 'package:fitness_tracker/screens/auth/signup_screen.dart';
import 'package:fitness_tracker/screens/dashboard/home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes.dart'; // Import the routes.dart file

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.login, // Use named constant
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.signup, // Use named constant
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: AppRoutes.home, // Use named constant
      builder: (context, state) {
        final user = Supabase.instance.client.auth.currentUser;
        return user != null ? HomeScreen() : LoginScreen();
      },
    ),
  ],
);
