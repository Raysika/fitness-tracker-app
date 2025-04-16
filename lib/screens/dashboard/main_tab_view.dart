import 'package:fitness_tracker/screens/dashboard/home_screen.dart';
import 'package:fitness_tracker/screens/dashboard/profile_screen.dart';
import 'package:fitness_tracker/screens/dashboard/progress_screen.dart';
import 'package:fitness_tracker/screens/dashboard/workout_screen.dart';
import 'package:flutter/material.dart';
import '../../common/color_extension.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/tab_controller_provider.dart';

class MainTabView extends StatefulWidget {
  final Map<String, dynamic>? extra;

  const MainTabView({super.key, this.extra});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  @override
  void initState() {
    super.initState();
    // Check if we should navigate to a specific tab from extra data
    if (widget.extra != null && widget.extra!.containsKey('tabIndex')) {
      final tabIndex = widget.extra!['tabIndex'] as int;
      // Set the tab index in the provider after a small delay to ensure the widget is mounted
      Future.delayed(Duration.zero, () {
        if (mounted) {
          final tabProvider =
              Provider.of<TabControllerProvider>(context, listen: false);
          tabProvider.changeTab(tabIndex);
        }
      });
    }
  }

  // This will hold your main screens - we'll create these next
  static final List<Widget> _widgetOptions = [
    const HomeScreen(),
    const WorkoutScreen(),
    const ProgressScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final tabProvider = Provider.of<TabControllerProvider>(context);

    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(tabProvider.currentIndex),
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
        currentIndex: tabProvider.currentIndex,
        selectedItemColor: TColor.primaryColor1,
        unselectedItemColor: TColor.grayColor(context),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: TColor.whiteColor(context),
        elevation: 15,
        onTap: (index) {
          tabProvider.changeTab(index);
        },
      ),
    );
  }
}
