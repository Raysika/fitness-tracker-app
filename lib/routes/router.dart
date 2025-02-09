//import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/screens/auth/login_screen.dart';
import 'package:fitness_tracker/screens/dashboard/dashboard_screen.dart';
import 'package:fitness_tracker/screens/auth/signup_screen.dart';
final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
  ],
);
