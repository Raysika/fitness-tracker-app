import 'package:fitness_tracker/screens/dashboard/home_screen.dart';
import 'package:fitness_tracker/screens/dashboard/profile_screen.dart';
import 'package:fitness_tracker/screens/dashboard/progress_screen.dart';
import 'package:fitness_tracker/screens/dashboard/workout_screen.dart';
import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class MainTabView extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const MainTabView({super.key, this.extra});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    // Check if we should navigate to a specific tab from extra data
    if (widget.extra != null && widget.extra!.containsKey('tabIndex')) {
      _selectedIndex = widget.extra!['tabIndex'] as int;
    } else {
      _selectedIndex = 0;
    }
  }

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
    final themeProvider = Provider.of<ThemeProvider>(context);

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
        unselectedItemColor: TColor.grayColor(context),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: TColor.whiteColor(context),
        elevation: 15,
        onTap: _onItemTapped,
      ),
    );
  }
}
