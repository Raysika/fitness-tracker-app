// lib/screens/dashboard/workout_screen.dart
import 'package:flutter/material.dart';
import 'package:fitness_tracker/common/color_extension.dart';
import '../../services/supabase_service.dart';
import 'package:go_router/go_router.dart';
import '../../routes/routes.dart';

class WorkoutScreen extends StatefulWidget {
  final int initialTabIndex;

  const WorkoutScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  int selectedTabIndex = 0;
  final List<String> tabs = [
    "All",
    "Fullbody",
    "Upper",
    "Lower",
    "Abs",
    "Core",
    "Cardio"
  ];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _workouts = [];
  List<Map<String, dynamic>> _recommendations = [];

  @override
  void initState() {
    super.initState();
    selectedTabIndex = widget.initialTabIndex;
    _loadWorkouts();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkouts() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final workoutType = selectedTabIndex == 0 ? null : tabs[selectedTabIndex];
      final workouts = await _supabaseService.getWorkoutsByType(workoutType);

      setState(() {
        _workouts = workouts;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading workouts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      final recommendations =
          await _supabaseService.getWorkoutRecommendations();
      setState(() {
        _recommendations = recommendations;
      });
    } catch (e) {
      print('Error loading recommendations: $e');
    }
  }

  Future<void> _searchWorkouts(String query) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final results = await _supabaseService.searchWorkouts(query);

      setState(() {
        _workouts = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Error searching workouts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onTabChange(int index) {
    setState(() {
      selectedTabIndex = index;
      _isSearching = false;
      _searchController.clear();
    });
    _loadWorkouts();
  }

  void _navigateToWorkoutDetail(String workoutType) {
    context.push(
      Uri(
        path: AppRoutes.workoutDetail,
        queryParameters: {'type': workoutType},
      ).toString(),
    );
  }

  void _navigateToWorkoutHistory() {
    context.push(AppRoutes.workoutHistory);
  }

  void _navigateToAllWorkouts(int tabIndex) {
    context.push(
      Uri(
        path: AppRoutes.allWorkouts,
        queryParameters: {'tabIndex': tabIndex.toString()},
      ).toString(),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _loadWorkouts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Workouts",
                    style: TextStyle(
                      color: TColor.textColor(context),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleSearch,
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: TColor.lightGrayColor(context),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        _isSearching ? Icons.close : Icons.search,
                        color: TColor.grayColor(context),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            if (_isSearching)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search workouts...',
                    hintStyle: TextStyle(color: TColor.grayColor(context)),
                    filled: true,
                    fillColor: TColor.lightGrayColor(context),
                    prefixIcon: Icon(
                      Icons.search,
                      color: TColor.grayColor(context),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      _searchWorkouts(value);
                    }
                  },
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    if (value.isEmpty) {
                      _loadWorkouts();
                    }
                  },
                ),
              ),

            // Workout Category Tabs
            SizedBox(height: 20),
            SizedBox(
              height: 35,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                itemCount: tabs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => _onTabChange(index),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: selectedTabIndex == index
                              ? LinearGradient(colors: TColor.primaryG)
                              : null,
                          color: selectedTabIndex == index
                              ? null
                              : TColor.lightGrayColor(context),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: selectedTabIndex == index
                                ? TColor.white
                                : TColor.grayColor(context),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Section title - Pre-defined Workouts
            if (!_isSearching)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Pre-defined Workouts",
                      style: TextStyle(
                        color: TColor.textColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _navigateToAllWorkouts(selectedTabIndex),
                      child: Text(
                        "See All",
                        style: TextStyle(
                          color: TColor.primaryColor1,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Workout List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                          color: TColor.primaryColor1))
                  : _workouts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center_outlined,
                                color: TColor.grayColor(context),
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isSearching
                                    ? 'No results found'
                                    : 'No workouts found',
                                style: TextStyle(
                                  color: TColor.textColor(context),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          children: [
                            ..._workouts
                                .map((workout) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 15),
                                      child: _buildWorkoutItem(
                                        title: workout['title'] ?? 'Workout',
                                        exercises:
                                            '${workout['exercises_count'] ?? 0} Exercises',
                                        time:
                                            '${workout['duration_minutes'] ?? 0} minutes',
                                        level: workout['difficulty_level'] ??
                                            'Beginner',
                                        image: _getWorkoutIcon(
                                            workout['title'] ?? ''),
                                        color: _getGradientColors(
                                            workout['title'] ?? ''),
                                        onTap: () => _navigateToWorkoutDetail(
                                          _getWorkoutType(
                                              workout['title'] ?? ''),
                                        ),
                                      ),
                                    ))
                                .toList(),

                            // Recommendations Section if not searching
                            if (!_isSearching &&
                                _recommendations.isNotEmpty) ...[
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 15),
                                child: Text(
                                  "AI-Powered Recommendations For You",
                                  style: TextStyle(
                                    color: TColor.textColor(context),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              ..._recommendations
                                  .map((rec) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15),
                                        child: _buildRecommendationItem(
                                          title:
                                              rec['title'] ?? 'Recommendation',
                                          subtitle: rec['reason'] ??
                                              'Personalized for you',
                                          image: _getWorkoutIcon(
                                              rec['title'] ?? ''),
                                          color: _getGradientColors(
                                              rec['title'] ?? ''),
                                          onTap: () => _navigateToWorkoutDetail(
                                            _getWorkoutType(rec['title'] ?? ''),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutItem({
    required String title,
    required String exercises,
    required String time,
    required String level,
    required IconData image,
    required List<Color> color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TColor.lightGrayColor(context),
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: color),
              ),
              alignment: Alignment.center,
              child: Icon(
                image,
                color: Colors.white,
                size: 40,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: TColor.textColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: TColor.grayColor(context),
                          size: 12,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          exercises,
                          style: TextStyle(
                            color: TColor.grayColor(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          color: TColor.grayColor(context),
                          size: 12,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          time,
                          style: TextStyle(
                            color: TColor.grayColor(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.bar_chart_rounded,
                          color: TColor.grayColor(context),
                          size: 12,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          level,
                          style: TextStyle(
                            color: TColor.grayColor(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 120,
              width: 40,
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_right,
                color: TColor.primaryColor1,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem({
    required String title,
    required String subtitle,
    required IconData image,
    required List<Color> color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: TColor.lightGrayColor(context),
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 80,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: color),
              ),
              alignment: Alignment.center,
              child: Icon(
                image,
                color: Colors.white,
                size: 30,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: TColor.textColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: TColor.grayColor(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 90,
              width: 40,
              alignment: Alignment.center,
              child: Icon(
                Icons.chevron_right,
                color: TColor.primaryColor1,
                size: 25,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWorkoutIcon(String title) {
    if (title.toLowerCase().contains('fullbody')) {
      return Icons.fitness_center;
    } else if (title.toLowerCase().contains('upper')) {
      return Icons.accessibility_new;
    } else if (title.toLowerCase().contains('lower')) {
      return Icons.airline_seat_legroom_extra_outlined;
    } else if (title.toLowerCase().contains('abs')) {
      return Icons.sports_gymnastics;
    } else if (title.toLowerCase().contains('core')) {
      return Icons.speed;
    } else if (title.toLowerCase().contains('cardio')) {
      return Icons.directions_run;
    }
    return Icons.fitness_center;
  }

  List<Color> _getGradientColors(String title) {
    if (title.toLowerCase().contains('fullbody')) {
      return TColor.primaryG;
    } else if (title.toLowerCase().contains('upper')) {
      return TColor.secondaryG;
    } else if (title.toLowerCase().contains('lower')) {
      return [
        TColor.primaryColor2.withOpacity(0.5),
        TColor.secondaryColor2.withOpacity(0.5),
      ];
    } else if (title.toLowerCase().contains('abs')) {
      return [
        TColor.primaryColor1,
        TColor.secondaryColor1,
      ];
    } else if (title.toLowerCase().contains('core')) {
      return [
        TColor.secondaryColor2,
        TColor.secondaryColor1,
      ];
    } else if (title.toLowerCase().contains('cardio')) {
      return [
        Colors.orange,
        Colors.deepOrangeAccent,
      ];
    }
    return TColor.primaryG;
  }

  String _getWorkoutType(String title) {
    if (title.toLowerCase().contains('fullbody')) {
      return 'Fullbody';
    } else if (title.toLowerCase().contains('upper')) {
      return 'Upper';
    } else if (title.toLowerCase().contains('lower')) {
      return 'Lower';
    } else if (title.toLowerCase().contains('abs')) {
      return 'Abs';
    } else if (title.toLowerCase().contains('core')) {
      return 'Core';
    } else if (title.toLowerCase().contains('cardio')) {
      return 'Cardio';
    }
    return 'Fullbody';
  }
}
