// lib/screens/dashboard/workout_screen.dart
import 'package:flutter/material.dart';
import 'package:fitness_tracker/common/color_extension.dart';
import '../../services/supabase_service.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  int selectedTabIndex = 0;
  final List<String> tabs = ["All", "Fullbody", "Upper", "Lower", "Abs"];

  Future<void> _logCompletedWorkout({
    required String title,
    required int durationMinutes,
    required int caloriesBurned,
    required String workoutType,
    required String difficultyLevel,
  }) async {
    try {
      await _supabaseService.logWorkout(
        title: title,
        durationMinutes: durationMinutes,
        caloriesBurned: caloriesBurned,
        workoutType: workoutType,
        difficultyLevel: difficultyLevel,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Workout logged successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging workout: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
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
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: TColor.lightGray,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.search,
                      color: TColor.gray,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Custom Workout Builder Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                height: 60,
                width: double.maxFinite,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: TColor.secondaryG),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    // Navigate to custom workout builder
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: TColor.white,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Create Custom Workout",
                        style: TextStyle(
                          color: TColor.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
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
                      onTap: () {
                        setState(() {
                          selectedTabIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: selectedTabIndex == index
                              ? LinearGradient(colors: TColor.primaryG)
                              : null,
                          color: selectedTabIndex == index
                              ? null
                              : TColor.lightGray,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: selectedTabIndex == index
                                ? TColor.white
                                : TColor.gray,
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

            // Section title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Pre-defined Workouts",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                children: [
                  workoutItem(
                    title: "Fullbody Workout",
                    exercises: "12 Exercises",
                    time: "40 minutes",
                    level: "Beginner",
                    image: Icons.fitness_center,
                    color: TColor.primaryG,
                  ),
                  SizedBox(height: 15),
                  workoutItem(
                    title: "Upper Body Workout",
                    exercises: "10 Exercises",
                    time: "30 minutes",
                    level: "Intermediate",
                    image: Icons.accessibility_new,
                    color: TColor.secondaryG,
                  ),
                  SizedBox(height: 15),
                  workoutItem(
                    title: "Lower Body Workout",
                    exercises: "8 Exercises",
                    time: "25 minutes",
                    level: "Beginner",
                    image: Icons.airline_seat_legroom_extra_outlined,
                    color: [
                      TColor.primaryColor2.withOpacity(0.5),
                      TColor.secondaryColor2.withOpacity(0.5),
                    ],
                  ),
                  SizedBox(height: 15),

                  // Recommendations Section
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 15),
                    child: Text(
                      "Recommendations For You",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  recommendationItem(
                    title: "Core & Abs Builder",
                    subtitle: "Based on your recent activity",
                    image: Icons.speed,
                    color: TColor.primaryG,
                  ),
                  SizedBox(height: 15),
                  recommendationItem(
                    title: "HIIT Fat Burner",
                    subtitle: "Recommended for your fitness goals",
                    image: Icons.local_fire_department_outlined,
                    color: TColor.secondaryG,
                  ),
                  SizedBox(height: 15),

                  // Recent Workouts Section
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recently Completed",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "See History",
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
                  historyItem(
                    title: "Upper Body Workout",
                    date: "Today, 9:30 AM",
                    calories: "300 kcal",
                    duration: "45 min",
                    image: Icons.accessibility_new,
                    color: TColor.primaryColor1,
                  ),
                  SizedBox(height: 15),
                  historyItem(
                    title: "Fullbody Workout",
                    date: "Yesterday, 10:00 AM",
                    calories: "420 kcal",
                    duration: "60 min",
                    image: Icons.fitness_center,
                    color: TColor.secondaryColor1,
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Workout Item Widget
  Widget workoutItem({
    required String title,
    required String exercises,
    required String time,
    required String level,
    required IconData image,
    required List<Color> color,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: color),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 100,
                height: 120,
                alignment: Alignment.center,
                child: Icon(
                  image,
                  size: 45,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: TColor.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            exercises,
                            style: TextStyle(
                              color: TColor.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            time,
                            style: TextStyle(
                              color: TColor.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.signal_cellular_alt,
                          color: TColor.white,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          level,
                          style: TextStyle(
                            color: TColor.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 120,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(
                      Icons.play_circle_filled,
                      size: 30,
                      color: Colors.white,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _logCompletedWorkout(
                          title: title,
                          durationMinutes: int.parse(time.split(' ')[0]),
                          caloriesBurned: 200, // Default value
                          workoutType: title.contains('Full')
                              ? 'full_body'
                              : title.contains('Upper')
                                  ? 'upper_body'
                                  : title.contains('Lower')
                                      ? 'lower_body'
                                      : 'other',
                          difficultyLevel: level.toLowerCase(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: color[0],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Complete",
                        style: TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                // Navigate to workout details
              },
              child: Container(
                width: double.maxFinite,
                height: 120,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Recommendation Item Widget
  Widget recommendationItem({
    required String title,
    required String subtitle,
    required IconData image,
    required List<Color> color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: color),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              image,
              color: TColor.white,
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
                    color: TColor.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          Icon(
            Icons.chevron_right,
            color: TColor.gray,
            size: 20,
          ),
        ],
      ),
    );
  }

  // History Item Widget
  Widget historyItem({
    required String title,
    required String date,
    required String calories,
    required String duration,
    required IconData image,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(
              image,
              color: color,
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
                    color: TColor.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: TColor.gray,
                      size: 12,
                    ),
                    SizedBox(width: 5),
                    Text(
                      date,
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                calories,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 5),
              Text(
                duration,
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
