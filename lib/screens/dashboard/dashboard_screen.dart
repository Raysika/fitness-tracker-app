import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: const Center(
        child: Text('Welcome to your fitness dashboard!',
            style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
