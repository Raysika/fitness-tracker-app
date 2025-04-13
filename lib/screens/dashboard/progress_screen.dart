// lib/screens/dashboard/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:fitness_tracker/common/color_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/supabase_service.dart';

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

  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _measurements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    try {
      final measurements = await _supabaseService.getBodyMeasurements();
      setState(() {
        _measurements = measurements;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading measurements: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add helper methods to get latest measurements
  double? _getLatestMeasurement(String field) {
    if (_measurements.isEmpty) return null;
    return _measurements.first[field]?.toDouble();
  }

  double? _getPreviousMeasurement(String field) {
    if (_measurements.length < 2) return null;
    return _measurements[1][field]?.toDouble();
  }

  String _formatChange(double? current, double? previous) {
    if (current == null || previous == null) return "";
    double change = current - previous;
    return "${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}";
  }

  List<FlSpot> _getChartData() {
    if (_measurements.isEmpty) {
      return [
        FlSpot(0, 65.5), // Default data
        FlSpot(1, 65.3),
        FlSpot(2, 65.0),
        FlSpot(3, 65.7),
        FlSpot(4, 65.5),
        FlSpot(5, 65.3),
        FlSpot(6, 65.5),
      ];
    }

    // Sort measurements by date (most recent first)
    _measurements.sort((a, b) => DateTime.parse(b['date_recorded'])
        .compareTo(DateTime.parse(a['date_recorded'])));

    // Get the last 7 measurements (or less if fewer exist)
    final recentMeasurements = _measurements.take(7).toList().reversed.toList();

    // Create spots for the chart
    List<FlSpot> spots = [];
    for (int i = 0; i < recentMeasurements.length; i++) {
      double value = 0;
      switch (selectedMetric) {
        case "Weight":
          value = recentMeasurements[i]['weight']?.toDouble() ?? 0;
          break;
        case "Body Fat":
          value = recentMeasurements[i]['body_fat_percentage']?.toDouble() ?? 0;
          break;
        // Add other metrics as needed
        default:
          value = recentMeasurements[i]['weight']?.toDouble() ?? 0;
      }
      spots.add(FlSpot(i.toDouble(), value));
    }

    return spots;
  }

  // Calculate BMI from measurements
  String _calculateBMI() {
    double? height = _getLatestMeasurement('height');
    double? weight = _getLatestMeasurement('weight');

    if (height == null || weight == null || height == 0) return "N/A";

    // Convert height from cm to meters
    double heightInMeters = height / 100;
    double bmi = weight / (heightInMeters * heightInMeters);

    return bmi.toStringAsFixed(1);
  }

  // Get BMI category
  String _getBMICategory(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal weight";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  @override
  Widget build(BuildContext context) {
    // Calculate BMI only once
    String bmiValue = _calculateBMI();
    String bmiCategory =
        bmiValue != "N/A" ? _getBMICategory(double.parse(bmiValue)) : "Unknown";

    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: TColor.primaryColor1))
            : SingleChildScrollView(
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
                                        _measurements.isNotEmpty
                                            ? "Today"
                                            : "Never",
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
                                  value:
                                      "${_getLatestMeasurement('weight')?.toStringAsFixed(1) ?? '--'} kg",
                                  subtitle:
                                      "${_formatChange(_getLatestMeasurement('weight'), _getPreviousMeasurement('weight'))} kg this month",
                                  icon: Icons.monitor_weight_outlined,
                                ),
                                SizedBox(width: 15),
                                statItem(
                                  title: "Height",
                                  value:
                                      "${_getLatestMeasurement('height')?.toStringAsFixed(1) ?? '--'} cm",
                                  subtitle:
                                      "Last updated: ${_measurements.isNotEmpty ? 'Today' : '--'}",
                                  icon: Icons.height,
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                statItem(
                                  title: "BMI",
                                  value: bmiValue,
                                  subtitle: bmiCategory,
                                  icon: Icons.speed_outlined,
                                ),
                                SizedBox(width: 15),
                                statItem(
                                  title: "Body Fat",
                                  value:
                                      "${_getLatestMeasurement('body_fat_percentage')?.toStringAsFixed(1) ?? '--'}%",
                                  subtitle:
                                      "${_formatChange(_getLatestMeasurement('body_fat_percentage'), _getPreviousMeasurement('body_fat_percentage'))}% this month",
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
                            onPressed: () async {
                              // Show dialog to add new measurement
                              bool? result = await _showAddMeasurementDialog();
                              if (result == true) {
                                _loadMeasurements(); // Reload measurements after adding
                              }
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
                              value:
                                  "${_getLatestMeasurement('chest')?.toStringAsFixed(1) ?? '--'} cm",
                              progress: _formatChange(
                                  _getLatestMeasurement('chest'),
                                  _getPreviousMeasurement('chest')),
                              isPositive:
                                  (_getLatestMeasurement('chest') ?? 0) >=
                                      (_getPreviousMeasurement('chest') ?? 0),
                            ),
                            measurementCard(
                              title: "Waist",
                              value:
                                  "${_getLatestMeasurement('waist')?.toStringAsFixed(1) ?? '--'} cm",
                              progress: _formatChange(
                                  _getLatestMeasurement('waist'),
                                  _getPreviousMeasurement('waist')),
                              isPositive:
                                  (_getLatestMeasurement('waist') ?? 0) <=
                                      (_getPreviousMeasurement('waist') ?? 0),
                            ),
                            measurementCard(
                              title: "Arms",
                              value:
                                  "${_getLatestMeasurement('arms')?.toStringAsFixed(1) ?? '--'} cm",
                              progress: _formatChange(
                                  _getLatestMeasurement('arms'),
                                  _getPreviousMeasurement('arms')),
                              isPositive:
                                  (_getLatestMeasurement('arms') ?? 0) >=
                                      (_getPreviousMeasurement('arms') ?? 0),
                            ),
                            measurementCard(
                              title: "Thighs",
                              value:
                                  "${_getLatestMeasurement('thighs')?.toStringAsFixed(1) ?? '--'} cm",
                              progress: _formatChange(
                                  _getLatestMeasurement('thighs'),
                                  _getPreviousMeasurement('thighs')),
                              isPositive:
                                  (_getLatestMeasurement('thighs') ?? 0) >=
                                      (_getPreviousMeasurement('thighs') ?? 0),
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

                            // Line Chart with actual data
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
                                      spots: _getChartData(),
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
                                        color: TColor.primaryColor1
                                            .withOpacity(0.2),
                                      ),
                                    ),
                                  ],
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipColor:
                                          (LineBarSpot touchedSpot) =>
                                              TColor.black.withOpacity(0.8),
                                      getTooltipItems:
                                          (List<LineBarSpot> touchedBarSpots) {
                                        return touchedBarSpots.map((barSpot) {
                                          String unit =
                                              selectedMetric == "Weight"
                                                  ? "kg"
                                                  : "%";
                                          return LineTooltipItem(
                                            '${barSpot.y.toStringAsFixed(1)} $unit',
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

  // Add measurement dialog
  Future<bool?> _showAddMeasurementDialog() async {
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final chestController = TextEditingController();
    final waistController = TextEditingController();
    final armsController = TextEditingController();
    final thighsController = TextEditingController();
    final bodyFatController = TextEditingController();

    // Pre-fill with latest measurements if available
    if (_measurements.isNotEmpty) {
      weightController.text = _getLatestMeasurement('weight')?.toString() ?? '';
      heightController.text = _getLatestMeasurement('height')?.toString() ?? '';
      chestController.text = _getLatestMeasurement('chest')?.toString() ?? '';
      waistController.text = _getLatestMeasurement('waist')?.toString() ?? '';
      armsController.text = _getLatestMeasurement('arms')?.toString() ?? '';
      thighsController.text = _getLatestMeasurement('thighs')?.toString() ?? '';
      bodyFatController.text =
          _getLatestMeasurement('body_fat_percentage')?.toString() ?? '';
    }

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Add New Measurement"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Weight (kg) *",
                  hintText: "Enter your weight",
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: heightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Height (cm)",
                  hintText: "Enter your height",
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: chestController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Chest (cm)",
                  hintText: "Enter chest measurement",
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: waistController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Waist (cm)",
                  hintText: "Enter waist measurement",
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: armsController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Arms (cm)",
                  hintText: "Enter arms measurement",
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: thighsController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Thighs (cm)",
                  hintText: "Enter thighs measurement",
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: bodyFatController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Body Fat (%)",
                  hintText: "Enter body fat percentage",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (weightController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Weight is required")),
                );
                return;
              }

              try {
                await _supabaseService.addBodyMeasurement(
                  weight: double.parse(weightController.text),
                  height: heightController.text.isNotEmpty
                      ? double.parse(heightController.text)
                      : null,
                  chest: chestController.text.isNotEmpty
                      ? double.parse(chestController.text)
                      : null,
                  waist: waistController.text.isNotEmpty
                      ? double.parse(waistController.text)
                      : null,
                  arms: armsController.text.isNotEmpty
                      ? double.parse(armsController.text)
                      : null,
                  thighs: thighsController.text.isNotEmpty
                      ? double.parse(thighsController.text)
                      : null,
                  bodyFatPercentage: bodyFatController.text.isNotEmpty
                      ? double.parse(bodyFatController.text)
                      : null,
                );

                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Measurement added successfully")),
                );
              } catch (e) {
                Navigator.pop(context, false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error adding measurement: $e")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primaryColor1,
            ),
            child: Text("Save"),
          ),
        ],
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
          progress.isEmpty
              ? SizedBox()
              : Row(
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
    String unit = selectedMetric == "Weight" ? "kg" : "%";
    return Text(
      '${value.toInt()} $unit',
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
