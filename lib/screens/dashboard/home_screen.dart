import 'package:flutter/material.dart';
import 'package:fitness_tracker/common/color_extension.dart';
import 'package:percent_indicator/percent_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.white,
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
                            color: TColor.gray,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Stefani Wong",
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
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
                        Icons.notifications_outlined,
                        color: TColor.gray,
                        size: 22,
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
                            value: "8,430",
                            goal: "10,000",
                            progress: 0.84,
                            icon: Icons.directions_walk,
                          ),

                          // Calories
                          activityCard(
                            title: "Calories",
                            value: "760",
                            goal: "1,200",
                            progress: 0.63,
                            icon: Icons.local_fire_department_outlined,
                          ),

                          // Workout Minutes
                          activityCard(
                            title: "Minutes",
                            value: "45",
                            goal: "60",
                            progress: 0.75,
                            icon: Icons.timer_outlined,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25),

                // Goal Progress Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Goals",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Check",
                        style: TextStyle(
                          color: TColor.primaryColor1,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: TColor.lightGray,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Water Intake",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                "4 Liters",
                                style: TextStyle(
                                  color: TColor.primaryColor1,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                " / 4 Liters",
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      LinearPercentIndicator(
                        width: media.width * 0.4,
                        lineHeight: 10,
                        percent: 1.0,
                        backgroundColor: Colors.white,
                        progressColor: TColor.primaryColor1,
                        barRadius: Radius.circular(5),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15),

                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    color: TColor.lightGray,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sleep Duration",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                "8h 20m",
                                style: TextStyle(
                                  color: TColor.secondaryColor1,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                " / 8h",
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      LinearPercentIndicator(
                        width: media.width * 0.4,
                        lineHeight: 10,
                        percent: 1.0,
                        backgroundColor: Colors.white,
                        progressColor: TColor.secondaryColor1,
                        barRadius: Radius.circular(5),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 25),

                // Quick-start Workout Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Quick Start",
                      style: TextStyle(
                        color: TColor.black,
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
                      onPressed: () {},
                    ),
                    SizedBox(width: 15),
                    quickStartButton(
                      title: "HIIT Cardio",
                      duration: "15 mins",
                      color: TColor.secondaryG,
                      icon: Icons.favorite_border,
                      onPressed: () {},
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
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
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
                workoutHistoryItem(
                  title: "Fullbody Workout",
                  calories: "180",
                  duration: "20 minutes",
                  progress: 1.0,
                  date: "Fri, 20 May",
                ),

                SizedBox(height: 15),

                workoutHistoryItem(
                  title: "Lowerbody Workout",
                  calories: "200",
                  duration: "30 minutes",
                  progress: 0.8,
                  date: "Thu, 19 May",
                ),

                SizedBox(height: 15),

                workoutHistoryItem(
                  title: "Ab Workout",
                  calories: "120",
                  duration: "15 minutes",
                  progress: 0.9,
                  date: "Wed, 18 May",
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
            percent: progress,
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
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: TColor.white,
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
                    color: TColor.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "$calories Calories Burn | $duration",
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 8),
                LinearPercentIndicator(
                  percent: progress,
                  lineHeight: 6,
                  backgroundColor: Colors.white,
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
                    color: TColor.gray,
                    size: 14,
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
              SizedBox(height: 10),
              Icon(
                Icons.chevron_right,
                color: TColor.gray,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
