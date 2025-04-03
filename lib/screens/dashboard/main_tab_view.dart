// lib/screens/dashboard/main_tab_view.dart
import 'package:fitness_tracker/screens/dashboard/home_screen.dart';
import 'package:fitness_tracker/screens/dashboard/profile_screen.dart';
import 'package:fitness_tracker/screens/dashboard/progress_screen.dart';
import 'package:fitness_tracker/screens/dashboard/workout_screen.dart';
import 'package:flutter/material.dart';
import '../../common/color_extension.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _selectedIndex = 0;

  // This will hold your main screens - we'll create these next
  static final List<Widget> _widgetOptions = [
    const HomeScreen(),
    const WorkoutScreen(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart_outlined),
            activeIcon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: TColor.primaryColor1,
        unselectedItemColor: TColor.gray,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: TColor.white,
        elevation: 15,
        onTap: _onItemTapped,
      ),
    );
  }
}
