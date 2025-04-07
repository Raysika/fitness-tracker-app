// lib/screens/dashboard/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:fitness_tracker/common/color_extension.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // Selected time range for charts
  String selectedRange = "Weekly";
  List<String> timeRanges = ["Weekly", "Monthly", "3 Months", "Yearly"];

  // Selected metric for main chart
  String selectedMetric = "Weight";
  List<String> metrics = ["Weight", "Steps", "Calories", "Workouts"];

  @override
  Widget build(BuildContext context) {
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

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Progress",
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
                        Icons.calendar_today_outlined,
                        color: TColor.gray,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Current Stats Overview
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: TColor.primaryG),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Current Stats",
                            style: TextStyle(
                              color: TColor.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Last Updated: ",
                                  style: TextStyle(
                                    color: TColor.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "Today",
                                  style: TextStyle(
                                    color: TColor.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          statItem(
                            title: "Weight",
                            value: "65.5 kg",
                            subtitle: "↓ 1.2 kg this month",
                            icon: Icons.monitor_weight_outlined,
                          ),
                          SizedBox(width: 15),
                          statItem(
                            title: "Height",
                            value: "170 cm",
                            subtitle: "Last updated: 1 week ago",
                            icon: Icons.height,
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          statItem(
                            title: "BMI",
                            value: "20.1",
                            subtitle: "Normal weight",
                            icon: Icons.speed_outlined,
                          ),
                          SizedBox(width: 15),
                          statItem(
                            title: "Body Fat",
                            value: "16%",
                            subtitle: "↓ 2% this month",
                            icon: Icons.pie_chart_outline,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Measurement Tracking Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Measurements",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Navigate to measurement entry screen
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: TColor.primaryColor1,
                            size: 18,
                          ),
                          SizedBox(width: 5),
                          Text(
                            "Add New",
                            style: TextStyle(
                              color: TColor.primaryColor1,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Horizontal measurement cards
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      measurementCard(
                        title: "Chest",
                        value: "92 cm",
                        progress: "+1.5 cm",
                        isPositive: true,
                      ),
                      measurementCard(
                        title: "Waist",
                        value: "76 cm",
                        progress: "-2.5 cm",
                        isPositive: true,
                      ),
                      measurementCard(
                        title: "Arms",
                        value: "34 cm",
                        progress: "+0.8 cm",
                        isPositive: true,
                      ),
                      measurementCard(
                        title: "Thighs",
                        value: "55 cm",
                        progress: "-1.2 cm",
                        isPositive: true,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Chart Section
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: TColor.lightGray,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Metric selector dropdown
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              color: TColor.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: TColor.gray.withOpacity(0.3)),
                            ),
                            child: DropdownButton<String>(
                              value: selectedMetric,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: TColor.gray,
                              ),
                              underline: SizedBox(),
                              items: metrics.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedMetric = newValue;
                                  });
                                }
                              },
                            ),
                          ),

                          // Time range selector
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 5),
                            decoration: BoxDecoration(
                              color: TColor.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: TColor.gray.withOpacity(0.3)),
                            ),
                            child: DropdownButton<String>(
                              value: selectedRange,
                              icon: Icon(
                                Icons.keyboard_arrow_down,
                                color: TColor.gray,
                              ),
                              underline: SizedBox(),
                              items: timeRanges.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 14,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    selectedRange = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Line Chart
                      // Replace the LineChart section with this corrected version
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(
                              show: true,
                              drawHorizontalLine: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: TColor.gray.withOpacity(0.15),
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: leftTitleWidgets,
                                  reservedSize: 40,
                                ),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: bottomTitleWidgets,
                                  reservedSize: 30,
                                ),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                spots: [
                                  FlSpot(0, 65.8),
                                  FlSpot(1, 66.2),
                                  FlSpot(2, 65.9),
                                  FlSpot(3, 65.7),
                                  FlSpot(4, 65.5),
                                  FlSpot(5, 65.3),
                                  FlSpot(6, 65.5),
                                ],
                                isCurved: true,
                                color: TColor.primaryColor1,
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (spot, percent, barData, index) {
                                    return FlDotCirclePainter(
                                      radius: 4,
                                      color: TColor.primaryColor1,
                                      strokeWidth: 2,
                                      strokeColor: TColor.white,
                                    );
                                  },
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: TColor.primaryColor1.withOpacity(0.2),
                                ),
                              ),
                            ],
                            lineTouchData: LineTouchData(
                              touchTooltipData: LineTouchTooltipData(
                                getTooltipColor: (LineBarSpot touchedSpot) =>
                                    TColor.black.withOpacity(0.8),
                                getTooltipItems:
                                    (List<LineBarSpot> touchedBarSpots) {
                                  return touchedBarSpots.map((barSpot) {
                                    return LineTooltipItem(
                                      '${barSpot.y.toStringAsFixed(1)} kg',
                                      TextStyle(
                                        color: TColor.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Achievements Section
                Text(
                  "Achievement Badges",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                SizedBox(height: 15),

                // Achievement badges grid
                GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    achievementBadge(
                      icon: Icons.emoji_events,
                      title: "10K Steps",
                      isUnlocked: true,
                    ),
                    achievementBadge(
                      icon: Icons.calendar_month,
                      title: "7 Day Streak",
                      isUnlocked: true,
                    ),
                    achievementBadge(
                      icon: Icons.fitness_center,
                      title: "First Workout",
                      isUnlocked: true,
                    ),
                    achievementBadge(
                      icon: Icons.speed,
                      title: "Goal Crusher",
                      isUnlocked: true,
                    ),
                    achievementBadge(
                      icon: Icons.local_fire_department,
                      title: "Calorie Master",
                      isUnlocked: false,
                    ),
                    achievementBadge(
                      icon: Icons.run_circle_outlined,
                      title: "Marathon",
                      isUnlocked: false,
                    ),
                    achievementBadge(
                      icon: Icons.timer,
                      title: "Early Bird",
                      isUnlocked: false,
                    ),
                    achievementBadge(
                      icon: Icons.star,
                      title: "30 Day Pro",
                      isUnlocked: false,
                    ),
                  ],
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Stat Item Widget
  Widget statItem({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    color: TColor.white,
                    size: 18,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: TColor.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
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
              subtitle,
              style: TextStyle(
                color: TColor.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Measurement Card Widget
  Widget measurementCard({
    required String title,
    required String value,
    required String progress,
    required bool isPositive,
  }) {
    return Container(
      width: 120,
      margin: EdgeInsets.only(right: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 13,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: TColor.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                color: isPositive
                    ? (title == "Waist" || title == "Thighs"
                        ? TColor.primaryColor1
                        : TColor.secondaryColor1)
                    : TColor.gray,
                size: 18,
              ),
              Text(
                progress,
                style: TextStyle(
                  color: isPositive
                      ? (title == "Waist" || title == "Thighs"
                          ? TColor.primaryColor1
                          : TColor.secondaryColor1)
                      : TColor.gray,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Achievement Badge Widget
  Widget achievementBadge({
    required IconData icon,
    required String title,
    required bool isUnlocked,
  }) {
    return Column(
      children: [
        Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isUnlocked
                ? LinearGradient(
                    colors: title.contains("Day") || title.contains("Step")
                        ? TColor.primaryG
                        : TColor.secondaryG,
                  )
                : null,
            color: isUnlocked ? null : TColor.lightGray,
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: isUnlocked ? TColor.white : TColor.gray,
            size: 28,
          ),
        ),
        SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: isUnlocked ? TColor.black : TColor.gray,
            fontSize: 12,
            fontWeight: isUnlocked ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Chart Title Widgets
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    return Text(
      '${value.toInt()} kg',
      style: TextStyle(
        color: TColor.gray,
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Mon';
        break;
      case 1:
        text = 'Tue';
        break;
      case 2:
        text = 'Wed';
        break;
      case 3:
        text = 'Thu';
        break;
      case 4:
        text = 'Fri';
        break;
      case 5:
        text = 'Sat';
        break;
      case 6:
        text = 'Sun';
        break;
      default:
        text = '';
        break;
    }

    return Text(text, style: style);
  }
}
