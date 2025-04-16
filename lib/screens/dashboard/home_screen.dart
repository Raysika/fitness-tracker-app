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
import '../../providers/tab_controller_provider.dart';

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

  // Workout history data
  List<Map<String, dynamic>> _recentWorkouts = [];
  bool _isWorkoutHistoryLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadActivityData();
    _loadWorkoutHistory();
    _initStepTracking();
  }

  Future<void> _initStepTracking() async {
    await _stepTrackingService.initialize();
  }

  Future<void> _loadUserData() async {
    try {
      if (!mounted) return; // Early return if widget is no longer mounted

      final profile = await _supabaseService.getUserProfile();

      if (mounted) {
        // Check again after async operation
        setState(() {
          _userName =
              '${profile?['first_name'] ?? ''} ${profile?['last_name'] ?? ''}';
          _profileImageUrl = profile?['profile_image_url'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadActivityData() async {
    try {
      if (!mounted) return; // Early return if widget is no longer mounted

      final activityData = await _supabaseService.getDailyActivitySummary();

      // Load recent workouts to calculate total calories if needed
      if (_recentWorkouts.isEmpty) {
        await _loadWorkoutHistory();
      }

      // Calculate additional calories from today's workouts if they exist
      int workoutCalories = 0;
      int workoutMinutes = 0;
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      for (var workout in _recentWorkouts) {
        // Only count today's workouts
        if (workout['date_completed'] != null &&
            workout['date_completed'].toString().startsWith(today)) {
          workoutCalories += (workout['calories_burned'] ?? 0) as int;
          workoutMinutes += (workout['duration_minutes'] ?? 0) as int;
        }
      }

      // Update activity data with workout information
      if (workoutCalories > 0) {
        activityData['calories'] =
            (activityData['calories'] ?? 0) + workoutCalories;
      }

      if (workoutMinutes > 0) {
        activityData['workout_minutes'] =
            (activityData['workout_minutes'] ?? 0) + workoutMinutes;
      }

      if (mounted) {
        // Check again after async operation
        setState(() {
          _activityData = activityData;
        });
      }
    } catch (e) {
      print('Error loading activity data: $e');
    }
  }

  Future<void> _loadWorkoutHistory() async {
    try {
      if (!mounted) return; // Early return if widget is no longer mounted

      setState(() {
        _isWorkoutHistoryLoading = true;
      });

      final workoutHistory = await _supabaseService.getWorkoutHistory();

      // Get most recent 3 workouts
      final recentWorkouts = workoutHistory.length > 3
          ? workoutHistory.sublist(0, 3)
          : workoutHistory;

      if (mounted) {
        setState(() {
          _recentWorkouts = recentWorkouts;
          _isWorkoutHistoryLoading = false;
        });
      }
    } catch (e) {
      print('Error loading workout history: $e');
      if (mounted) {
        setState(() {
          _isWorkoutHistoryLoading = false;
        });
      }
    }
  }

  void _updateWaterIntake(int amount) {
    setState(() {
      _activityData['water_intake'] =
          (_activityData['water_intake'] ?? 0) + amount;
    });
  }

  void _updateSteps(int steps) async {
    try {
      await _stepTrackingService.addSteps(steps);
      // Reload activity data to reflect the changes
      if (mounted) {
        await _loadActivityData();
      }
    } catch (e) {
      print('Error updating steps: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating steps. Please try again.")),
        );
      }
    }
  }

  void _showAddStepsDialog() {
    int stepsToAdd = 0;

    showDialog(
      context: context,
      builder: (context) {
        // Using a simple dialog structure instead of AlertDialog with complex content
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Add Steps",
                    style: TextStyle(
                      color: TColor.textColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Today's Steps",
                      hintText: "E.g. 5000",
                    ),
                    onChanged: (value) {
                      stepsToAdd = int.tryParse(value) ?? 0;
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Enter your total steps for today",
                    style: TextStyle(
                      color: TColor.grayColor(context),
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Current Steps:",
                        style: TextStyle(
                          color: TColor.grayColor(context),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "${_activityData['steps']}",
                        style: TextStyle(
                          color: TColor.textColor(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: TColor.grayColor(context)),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (stepsToAdd > 0) {
                            _updateSteps(stepsToAdd);
                            Navigator.pop(context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Please enter a valid number of steps")),
                            );
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToProfile() {
    // Use the TabControllerProvider to navigate to profile tab (index 3)
    final tabProvider =
        Provider.of<TabControllerProvider>(context, listen: false);
    tabProvider.changeTab(3);
  }

  void _showGoalCompletionDialog() {
    final stepProgress = _activityData['steps'] / _activityData['step_goal'];
    final waterProgress =
        _activityData['water_intake'] / _activityData['water_goal'];
    final calorieProgress =
        _activityData['calories'] / _activityData['calorie_goal'];
    final workoutProgress =
        _activityData['workout_minutes'] / _activityData['workout_minute_goal'];

    showDialog(
      context: context,
      builder: (context) {
        // Using a simple dialog structure instead of AlertDialog with complex content
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Progress",
                    style: TextStyle(
                      color: TColor.textColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Steps Progress
                  _buildSimpleProgressItem(
                    context,
                    "Steps",
                    "${_activityData['steps']} / ${_activityData['step_goal']}",
                    stepProgress,
                    TColor.primaryColor1,
                  ),
                  SizedBox(height: 15),

                  // Water Intake Progress
                  _buildSimpleProgressItem(
                    context,
                    "Water Intake",
                    "${(_activityData['water_intake'] / 1000).toStringAsFixed(1)} / ${(_activityData['water_goal'] / 1000).toStringAsFixed(1)} L",
                    waterProgress,
                    TColor.secondaryColor1,
                  ),
                  SizedBox(height: 15),

                  // Calories Progress
                  _buildSimpleProgressItem(
                    context,
                    "Calories Burned",
                    "${_activityData['calories']} / ${_activityData['calorie_goal']}",
                    calorieProgress,
                    TColor.primaryColor2,
                  ),
                  SizedBox(height: 15),

                  // Workout Minutes Progress
                  _buildSimpleProgressItem(
                    context,
                    "Workout Minutes",
                    "${_activityData['workout_minutes']} / ${_activityData['workout_minute_goal']}",
                    workoutProgress,
                    TColor.secondaryColor2,
                  ),

                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Close",
                        style: TextStyle(color: TColor.primaryColor1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Simpler version of progress item without LinearPercentIndicator
  Widget _buildSimpleProgressItem(BuildContext context, String title,
      String value, double progress, Color progressColor) {
    final displayProgress = progress > 1.0 ? 1.0 : progress;

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
        Container(
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(
            color: TColor.lightGrayColor(context),
            borderRadius: BorderRadius.circular(5),
          ),
          child: FractionallySizedBox(
            widthFactor: displayProgress,
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditGoalsDialog() {
    int tempStepGoal = _activityData['step_goal'];
    int tempWaterGoal = _activityData['water_goal'];
    int tempCalorieGoal = _activityData['calorie_goal'];
    int tempWorkoutMinuteGoal = _activityData['workout_minute_goal'];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit Goals",
                    style: TextStyle(
                      color: TColor.textColor(context),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),

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
                  SizedBox(height: 15),

                  // Calorie Goal
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Daily Calorie Goal",
                      hintText: "E.g. 1200",
                    ),
                    controller:
                        TextEditingController(text: tempCalorieGoal.toString()),
                    onChanged: (value) {
                      tempCalorieGoal = int.tryParse(value) ?? tempCalorieGoal;
                    },
                  ),
                  SizedBox(height: 15),

                  // Workout Minute Goal
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Daily Workout Minutes Goal",
                      hintText: "E.g. 60",
                    ),
                    controller: TextEditingController(
                        text: tempWorkoutMinuteGoal.toString()),
                    onChanged: (value) {
                      tempWorkoutMinuteGoal =
                          int.tryParse(value) ?? tempWorkoutMinuteGoal;
                    },
                  ),

                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: TColor.grayColor(context)),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          // Save step and water goals to Supabase
                          try {
                            await _supabaseService.updateUserProfile(
                              stepGoal: tempStepGoal,
                              waterGoal: tempWaterGoal,
                              // We pass these but they won't be saved to database
                              calorieGoal: tempCalorieGoal,
                              workoutMinuteGoal: tempWorkoutMinuteGoal,
                            );

                            // Update local state
                            setState(() {
                              _activityData['step_goal'] = tempStepGoal;
                              _activityData['water_goal'] = tempWaterGoal;
                              _activityData['calorie_goal'] = tempCalorieGoal;
                              _activityData['workout_minute_goal'] =
                                  tempWorkoutMinuteGoal;
                            });

                            // Update step tracking service goal
                            await _stepTrackingService
                                .updateStepGoal(tempStepGoal);

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Goals updated successfully!")),
                            );
                          } catch (e) {
                            print('Error updating goals: $e');

                            // Even if database update fails, we'll still update local state for calorie and workout goals
                            setState(() {
                              _activityData['calorie_goal'] = tempCalorieGoal;
                              _activityData['workout_minute_goal'] =
                                  tempWorkoutMinuteGoal;
                            });

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      "Some goals could not be saved to the server, but are stored locally.")),
                            );
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
                  ),
                ],
              ),
            ),
          ),
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
                            onPressed: _showAddStepsDialog,
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

                // Display recent workout history
                _isWorkoutHistoryLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: TColor.primaryColor1,
                        ),
                      )
                    : _recentWorkouts.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.fitness_center_outlined,
                                    color: TColor.grayColor(context),
                                    size: 50,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "No workout history yet",
                                    style: TextStyle(
                                      color: TColor.grayColor(context),
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Access the tab controller provider and change to workout tab
                                      final tabProvider =
                                          Provider.of<TabControllerProvider>(
                                              context,
                                              listen: false);
                                      tabProvider.changeTab(
                                          1); // 1 is the index for workout tab
                                      print(
                                          "Navigated to workout tab via TabControllerProvider");
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: TColor.primaryColor1,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: Text(
                                      "Start a workout",
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: _recentWorkouts.map((workout) {
                              // Format the date
                              String formattedDate = "Unknown date";
                              try {
                                if (workout['date_completed'] != null) {
                                  final date =
                                      DateTime.parse(workout['date_completed']);
                                  formattedDate =
                                      DateFormat('EEE, d MMM').format(date);
                                }
                              } catch (e) {
                                print('Error formatting date: $e');
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: GestureDetector(
                                  onTap: () {
                                    if (workout['workout_type'] != null) {
                                      context.push(
                                        Uri(
                                          path: AppRoutes.workoutDetail,
                                          queryParameters: {
                                            'type': workout['workout_type']
                                          },
                                        ).toString(),
                                      );
                                    }
                                  },
                                  child: workoutHistoryItem(
                                    title:
                                        workout['title'] ?? 'Unknown Workout',
                                    calories:
                                        '${workout['calories_burned'] ?? 0}',
                                    duration:
                                        '${workout['duration_minutes'] ?? 0} minutes',
                                    progress:
                                        1.0, // Completed workouts are always 100%
                                    date: formattedDate,
                                    workoutType: workout['workout_type'] ?? '',
                                  ),
                                ),
                              );
                            }).toList(),
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
    VoidCallback? onPressed,
  }) {
    // Ensure progress is between 0 and 1
    final displayProgress =
        progress > 1.0 ? 1.0 : (progress < 0 ? 0.0 : progress);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
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
            if (onPressed != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Icon(
                  Icons.add_circle_outline,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
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
    required String workoutType,
  }) {
    // Get the appropriate icon based on workout type
    IconData workoutIcon = Icons.fitness_center;

    switch (workoutType.toLowerCase()) {
      case 'fullbody':
        workoutIcon = Icons.fitness_center;
        break;
      case 'upper':
        workoutIcon = Icons.accessibility_new;
        break;
      case 'lower':
        workoutIcon = Icons.airline_seat_legroom_extra_outlined;
        break;
      case 'abs':
        workoutIcon = Icons.sports_gymnastics;
        break;
      case 'core':
        workoutIcon = Icons.speed;
        break;
      case 'cardio':
        workoutIcon = Icons.directions_run;
        break;
      default:
        workoutIcon = Icons.fitness_center;
    }

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
              workoutIcon,
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

  @override
  void dispose() {
    // Clean up resources
    // No need to call dispose on _stepTrackingService as it doesn't have a dispose method
    super.dispose();
  }
}
