import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/routes/routes.dart'; // Import routes.dart

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome to Fitness Tracker',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Navigate to Home Screen
                context.go(AppRoutes.home); // Use named constant
              },
              child: const Text('Login with Google'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to Signup Screen
                context.go(AppRoutes.signup); // Use named constant
              },
              child: const Text('Don’t have an account? Sign up'),
            ),
          ],
        ),
      ),
    );
  }
}
