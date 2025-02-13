//import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/screens/auth/login_screen.dart';
import 'package:fitness_tracker/screens/dashboard/dashboard_screen.dart';
import 'package:fitness_tracker/screens/auth/signup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => DashboardScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen()
    ),
       GoRoute(
      path: '/dashboard',
      builder: (context, state) {
        final user = Supabase.instance.client.auth.currentUser;
        return user != null ? DashboardScreen() : LoginScreen();
      },
    ),
  ],
);
