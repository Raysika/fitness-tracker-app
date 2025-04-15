import 'package:flutter/material.dart';
import 'package:fitness_tracker/common/color_extension.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/supabase_service.dart';
import '../../services/step_tracking_service.dart';
import '../../widgets/water_intake_widget.dart';
import '../../routes/routes.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  final StepTrackingService _stepTrackingService = StepTrackingService();

  String? _profileImageUrl;
  String _userName = '';
  bool _isLoading = true;

  // Activity metrics
  Map<String, dynamic> _activityData = {
    'steps': 0,
    'step_goal': 10000,
    'calories': 0,
    'calorie_goal': 1200,
    'workout_minutes': 0,
    'workout_minute_goal': 60,
    'water_intake': 0,
    'water_goal': 4000, // 4 liters in ml
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadActivityData();
    _initStepTracking();
  }

  Future<void> _initStepTracking() async {
    await _stepTrackingService.initialize();
    await _stepTrackingService.startTracking();
  }

  Future<void> _loadUserData() async {
    try {
      final profile = await _supabaseService.getUserProfile();
      if (profile != null) {
        setState(() {
          _userName =
              '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}';
          _profileImageUrl = profile['profile_image_url'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadActivityData() async {
    try {
      final activityData = await _supabaseService.getDailyActivitySummary();
      setState(() {
        _activityData = activityData;
      });
    } catch (e) {
      print('Error loading activity data: $e');
    }
  }

  void _updateWaterIntake(int amount) {
    setState(() {
      _activityData['water_intake'] =
          (_activityData['water_intake'] ?? 0) + amount;
    });
  }

  void _navigateToProfile() {
    // Using GoRouter to navigate with extra data for the tab index
    context.go(AppRoutes.home, extra: {'tabIndex': 3});
  }

  void _showGoalCompletionDialog() {
    final stepProgress = _activityData['steps'] / _activityData['step_goal'];
    final waterProgress =
        _activityData['water_intake'] / _activityData['water_goal'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Today's Progress",
            style: TextStyle(
              color: TColor.textColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildProgressItem(
                context,
                "Steps",
                "${_activityData['steps']} / ${_activityData['step_goal']}",
                stepProgress,
                TColor.primaryColor1,
              ),
              SizedBox(height: 15),
              _buildProgressItem(
                context,
                "Water Intake",
                "${(_activityData['water_intake'] / 1000).toStringAsFixed(1)} / ${(_activityData['water_goal'] / 1000).toStringAsFixed(1)} L",
                waterProgress,
                TColor.secondaryColor1,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Close",
                style: TextStyle(color: TColor.primaryColor1),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressItem(BuildContext context, String title, String value,
      double progress, Color progressColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: TColor.textColor(context),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: TColor.grayColor(context),
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        LinearPercentIndicator(
          lineHeight: 10,
          percent: progress > 1.0 ? 1.0 : progress,
          backgroundColor: TColor.lightGrayColor(context),
          progressColor: progressColor,
          barRadius: Radius.circular(5),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  void _showEditGoalsDialog() {
    int tempStepGoal = _activityData['step_goal'];
    int tempWaterGoal = _activityData['water_goal'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Edit Goals",
            style: TextStyle(
              color: TColor.textColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Step Goal
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Step Goal",
                  hintText: "E.g. 10000",
                ),
                controller:
                    TextEditingController(text: tempStepGoal.toString()),
                onChanged: (value) {
                  tempStepGoal = int.tryParse(value) ?? tempStepGoal;
                },
              ),
              SizedBox(height: 15),
              // Water Goal (in ml)
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Water Goal (ml)",
                  hintText: "E.g. 4000 (4 liters)",
                ),
                controller:
                    TextEditingController(text: tempWaterGoal.toString()),
                onChanged: (value) {
                  tempWaterGoal = int.tryParse(value) ?? tempWaterGoal;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: TColor.grayColor(context)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Save goals to Supabase
                try {
                  await _supabaseService.updateUserProfile(
                    stepGoal: tempStepGoal,
                    waterGoal: tempWaterGoal,
                  );

                  // Update local state
                  setState(() {
                    _activityData['step_goal'] = tempStepGoal;
                    _activityData['water_goal'] = tempWaterGoal;
                  });

                  // Update step tracking service goal
                  await _stepTrackingService.updateStepGoal(tempStepGoal);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Goals updated successfully!")),
                  );
                } catch (e) {
                  print('Error updating goals: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("Error updating goals. Please try again.")),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primaryColor1,
              ),
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to create initials avatar when no profile image is available
  Widget _buildInitialsAvatar() {
    String initials = '';
    if (_userName.isNotEmpty) {
      final nameParts = _userName.split(' ');
      if (nameParts.isNotEmpty) {
        initials += nameParts[0][0];
        if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
          initials += nameParts[1][0];
        }
      }
    } else {
      initials = 'U';
    }

    return Container(
      decoration: BoxDecoration(
        color: TColor.primaryColor2.withOpacity(0.7),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.backgroundColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),

                // Welcome Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome Back,",
                          style: TextStyle(
                            color: TColor.grayColor(context),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          _isLoading ? "Loading..." : _userName,
                          style: TextStyle(
                            color: TColor.textColor(context),
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _navigateToProfile,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: TColor.primaryColor1,
                            width: 2,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _profileImageUrl != null
                            ? Image.network(
                                _profileImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildInitialsAvatar();
                                },
                              )
                            : _buildInitialsAvatar(),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15),

                // Daily Activity Summary Card
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: TColor.primaryG,
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Daily Activity",
                        style: TextStyle(
                          color: TColor.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Steps
                          activityCard(
                            title: "Steps",
                            value: _activityData['steps'].toString(),
                            goal: _activityData['step_goal'].toString(),
                            progress: _activityData['steps'] /
                                _activityData['step_goal'],
                            icon: Icons.directions_walk,
                          ),

                          // Calories
                          activityCard(
                            title: "Calories",
                            value: _activityData['calories'].toString(),
                            goal: _activityData['calorie_goal'].toString(),
                            progress: _activityData['calories'] /
                                _activityData['calorie_goal'],
                            icon: Icons.local_fire_department_outlined,
                          ),

                          // Workout Minutes
                          activityCard(
                            title: "Minutes",
                            value: _activityData['workout_minutes'].toString(),
                            goal:
                                _activityData['workout_minute_goal'].toString(),
                            progress: _activityData['workout_minutes'] /
                                _activityData['workout_minute_goal'],
                            icon: Icons.timer_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25),

                // Today's Goals Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Goals",
                      style: TextStyle(
                        color: TColor.textColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: _showGoalCompletionDialog,
                          child: Text(
                            "Check",
                            style: TextStyle(
                              color: TColor.primaryColor1,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _showEditGoalsDialog,
                          child: Text(
                            "Edit",
                            style: TextStyle(
                              color: TColor.primaryColor1,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Water intake widget with updated design
                WaterIntakeWidget(
                  waterIntake: _activityData['water_intake'],
                  waterGoal: _activityData['water_goal'],
                  onAddWater: _updateWaterIntake,
                ),

                SizedBox(height: 25),

                // Quick-start Workout Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Quick Start",
                      style: TextStyle(
                        color: TColor.textColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15),

                Row(
                  children: [
                    quickStartButton(
                      title: "Full Body Workout",
                      duration: "20 mins",
                      color: TColor.primaryG,
                      icon: Icons.fitness_center,
                      onPressed: () {
                        context.push(
                          Uri(
                            path: AppRoutes.workoutDetail,
                            queryParameters: {'type': 'Fullbody'},
                          ).toString(),
                        );
                      },
                    ),
                    SizedBox(width: 15),
                    quickStartButton(
                      title: "HIIT Cardio",
                      duration: "15 mins",
                      color: TColor.secondaryG,
                      icon: Icons.favorite_border,
                      onPressed: () {
                        context.push(
                          Uri(
                            path: AppRoutes.workoutDetail,
                            queryParameters: {'type': 'Cardio'},
                          ).toString(),
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: 15),

                // Recent Workout History
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Workouts",
                      style: TextStyle(
                        color: TColor.textColor(context),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(AppRoutes.workoutHistory);
                      },
                      child: Text(
                        "See more",
                        style: TextStyle(
                          color: TColor.primaryColor1,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 15),

                // Workout history items
                GestureDetector(
                  onTap: () {
                    context.push(
                      Uri(
                        path: AppRoutes.workoutDetail,
                        queryParameters: {'type': 'Fullbody'},
                      ).toString(),
                    );
                  },
                  child: workoutHistoryItem(
                    title: "Fullbody Workout",
                    calories: "180",
                    duration: "20 minutes",
                    progress: 1.0,
                    date: "Fri, 20 May",
                  ),
                ),

                SizedBox(height: 15),

                GestureDetector(
                  onTap: () {
                    context.push(
                      Uri(
                        path: AppRoutes.workoutDetail,
                        queryParameters: {'type': 'Lower'},
                      ).toString(),
                    );
                  },
                  child: workoutHistoryItem(
                    title: "Lowerbody Workout",
                    calories: "200",
                    duration: "30 minutes",
                    progress: 0.8,
                    date: "Thu, 19 May",
                  ),
                ),

                SizedBox(height: 15),

                GestureDetector(
                  onTap: () {
                    context.push(
                      Uri(
                        path: AppRoutes.workoutDetail,
                        queryParameters: {'type': 'Abs'},
                      ).toString(),
                    );
                  },
                  child: workoutHistoryItem(
                    title: "Ab Workout",
                    calories: "120",
                    duration: "15 minutes",
                    progress: 0.9,
                    date: "Wed, 18 May",
                  ),
                ),

                SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Activity Card Widget
  Widget activityCard({
    required String title,
    required String value,
    required String goal,
    required double progress,
    required IconData icon,
  }) {
    // Ensure progress is between 0 and 1
    final displayProgress =
        progress > 1.0 ? 1.0 : (progress < 0 ? 0.0 : progress);

    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: TColor.white,
            size: 24,
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: TColor.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            title,
            style: TextStyle(
              color: TColor.white,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 10),
          LinearPercentIndicator(
            width: 80,
            lineHeight: 6,
            percent: displayProgress,
            backgroundColor: Colors.white.withOpacity(0.3),
            progressColor: Colors.white,
            barRadius: Radius.circular(3),
            padding: EdgeInsets.zero,
          ),
          SizedBox(height: 5),
          Text(
            "Goal: $goal",
            style: TextStyle(
              color: TColor.white.withOpacity(0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // Quick Start Button Widget
  Widget quickStartButton({
    required String title,
    required String duration,
    required List<Color> color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: color,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: color[0],
                  size: 20,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: TColor.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      duration,
                      style: TextStyle(
                        color: TColor.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Workout History Item
  Widget workoutHistoryItem({
    required String title,
    required String calories,
    required String duration,
    required double progress,
    required String date,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: TColor.lightGrayColor(context),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: TColor.whiteColor(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: TColor.gray.withOpacity(0.3),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.fitness_center,
              color: TColor.primaryColor1,
              size: 24,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: TColor.textColor(context),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "$calories Calories Burn | $duration",
                  style: TextStyle(
                    color: TColor.grayColor(context),
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 8),
                LinearPercentIndicator(
                  percent: progress,
                  lineHeight: 6,
                  backgroundColor: TColor.whiteColor(context),
                  progressColor: TColor.primaryColor1,
                  barRadius: Radius.circular(3),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: TColor.grayColor(context),
                    size: 14,
                  ),
                  SizedBox(width: 5),
                  Text(
                    date,
                    style: TextStyle(
                      color: TColor.grayColor(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Icon(
                Icons.chevron_right,
                color: TColor.grayColor(context),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
