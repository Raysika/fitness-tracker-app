// lib/screens/dashboard/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:fitness_tracker/common/color_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../services/supabase_service.dart';
import '../../services/body_fat_calculator.dart';
import '../../providers/theme_provider.dart';
import 'dart:math' as math;
import '../../providers/auth_provider.dart';

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
  List<String> metrics = [
    "Weight",
    "Body Fat",
    "Workouts",
    "Steps",
    "Calories"
  ];

  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _measurements = [];
  List<Map<String, dynamic>> _workoutData = [];
  List<Map<String, dynamic>> _stepData = [];
  Map<String, int> _cachedStepData =
      {}; // Cache for step data to avoid repeated queries
  bool _isLoading = true;
  String _userGender = 'male'; // Default gender
  DateTime _lastDataRefresh = DateTime(2000); // Track last data refresh

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final profile = await _supabaseService.getUserProfile();
      if (profile != null) {
        _userGender = profile['gender'] ?? 'male';
      }

      // Get body measurements
      final measurements = await _supabaseService.getBodyMeasurements();

      // Get workout history for workouts chart
      final workouts = await _supabaseService.getWorkoutHistory();

      // Get step data for steps chart - use optimized batch loading
      final stepData = await _getStepDataOptimized();

      // Update cache time
      _lastDataRefresh = now;

      setState(() {
        _measurements = measurements;
        _workoutData = workouts;
        _stepData = stepData;
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Optimized method to fetch step data
  Future<List<Map<String, dynamic>>> _getStepDataOptimized() async {
    List<Map<String, dynamic>> stepData = [];

    try {
      final today = DateTime.now();
      final daysToFetch = _getDaysToFetch();

      // Only fetch data for the actual days we need to display
      // Calculate start date
      final startDate = today.subtract(Duration(days: daysToFetch));

      // For yearly, use a more efficient batched query if available
      if (selectedRange == "Yearly" || selectedRange == "3 Months") {
        // Check if the Supabase service has a batch query method
        try {
          // Get aggregate data in a single query if possible
          final batchedStepData = await _supabaseService.getStepDataRange(
              _formatDate(startDate), _formatDate(today));

          if (batchedStepData.isNotEmpty) {
            // If successful, use that data
            return batchedStepData;
          }
        } catch (e) {
          print("Batch step data query not available: $e");
          // Fall back to regular method below
        }
      }

      // For shorter ranges or if batch query failed, use individual dates but with caching
      for (int i = 0; i < daysToFetch; i++) {
        final date = today.subtract(Duration(days: i));
        final dateString = _formatDate(date);

        int steps;
        // Check cache first
        if (_cachedStepData.containsKey(dateString)) {
          steps = _cachedStepData[dateString]!;
        } else {
          // Only fetch from database if not in cache
          steps = await _supabaseService.getDailyStepCount(dateString) ?? 0;
          // Update cache
          _cachedStepData[dateString] = steps;
        }

        // Estimate calories based on steps (simple calculation)
        final calories = (steps * 0.04).round();

        stepData.add({
          'date': dateString,
          'steps': steps,
          'calories': calories,
        });
      }

      return stepData;
    } catch (e) {
      print("Error fetching step data: $e");
      return [];
    }
  }

  // Helper method to format date consistently
  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // Get number of days to fetch data for based on selected range
  int _getDaysToFetch() {
    switch (selectedRange) {
      case "Weekly":
        return 7;
      case "Monthly":
        return 30;
      case "3 Months":
        return 90;
      case "Yearly":
        return 365;
      default:
        return 7;
    }
  }

  // Refresh data on range change, but avoid full reload for metric change
  void _refreshData() {
    // Calculate how long since last refresh
    final timeSinceRefresh =
        DateTime.now().difference(_lastDataRefresh).inMinutes;

    // Only reload data every 5 minutes or when range changes
    if (timeSinceRefresh > 5) {
      _loadUserData();
    } else {
      // For metric changes, just refresh the UI
      setState(() {});
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
    // Filter data based on selected range
    final daysToShow = _getDaysToFetch();

    switch (selectedMetric) {
      case "Weight":
        return _getWeightChartData(daysToShow);
      case "Body Fat":
        return _getBodyFatChartData(daysToShow);
      case "Workouts":
        return _getWorkoutsChartData(daysToShow);
      case "Steps":
        return _getStepsChartData(daysToShow);
      case "Calories":
        return _getCaloriesChartData(daysToShow);
      default:
        return _getWeightChartData(daysToShow);
    }
  }

  // Weight chart data
  List<FlSpot> _getWeightChartData(int daysToShow) {
    if (_measurements.isEmpty) {
      return _generateDefaultSpots(65.0);
    }

    // Filter by date range
    final startDate = DateTime.now().subtract(Duration(days: daysToShow));
    final filteredMeasurements = _measurements.where((measurement) {
      final measurementDate = DateTime.parse(measurement['date_recorded']);
      return measurementDate.isAfter(startDate);
    }).toList();

    if (filteredMeasurements.isEmpty) {
      return _generateDefaultSpots(65.0);
    }

    // Sort by date (oldest first)
    filteredMeasurements.sort((a, b) => DateTime.parse(a['date_recorded'])
        .compareTo(DateTime.parse(b['date_recorded'])));

    // Get the spacing between points
    final spacing = daysToShow /
        (filteredMeasurements.length > 1 ? filteredMeasurements.length - 1 : 1);

    // Create spots for the chart
    List<FlSpot> spots = [];
    for (int i = 0; i < filteredMeasurements.length; i++) {
      double value = filteredMeasurements[i]['weight']?.toDouble() ?? 0;
      spots.add(FlSpot(i * spacing, value));
    }

    return spots;
  }

  // Body fat chart data
  List<FlSpot> _getBodyFatChartData(int daysToShow) {
    if (_measurements.isEmpty) {
      return _generateDefaultSpots(20.0);
    }

    // Filter by date range
    final startDate = DateTime.now().subtract(Duration(days: daysToShow));
    final filteredMeasurements = _measurements.where((measurement) {
      final measurementDate = DateTime.parse(measurement['date_recorded']);
      return measurementDate.isAfter(startDate);
    }).toList();

    if (filteredMeasurements.isEmpty) {
      return _generateDefaultSpots(20.0);
    }

    // Sort by date (oldest first)
    filteredMeasurements.sort((a, b) => DateTime.parse(a['date_recorded'])
        .compareTo(DateTime.parse(b['date_recorded'])));

    // Get the spacing between points
    final spacing = daysToShow /
        (filteredMeasurements.length > 1 ? filteredMeasurements.length - 1 : 1);

    // Create spots for the chart
    List<FlSpot> spots = [];
    for (int i = 0; i < filteredMeasurements.length; i++) {
      double value =
          filteredMeasurements[i]['body_fat_percentage']?.toDouble() ?? 0;
      spots.add(FlSpot(i * spacing, value));
    }

    return spots;
  }

  // Workouts chart data - shows workout minutes per day
  List<FlSpot> _getWorkoutsChartData(int daysToShow) {
    if (_workoutData.isEmpty) {
      return _generateDefaultSpots(30.0);
    }

    // Filter by date range and group by date
    final startDate = DateTime.now().subtract(Duration(days: daysToShow));

    // Map to store workout minutes by date
    Map<String, double> workoutMinutesByDate = {};

    // Initialize all dates in range with 0 minutes
    for (int i = 0; i < daysToShow; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateString =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      workoutMinutesByDate[dateString] = 0;
    }

    // Sum up workout minutes for each date
    for (var workout in _workoutData) {
      if (workout['date_completed'] != null) {
        final workoutDate = DateTime.parse(workout['date_completed']);
        if (workoutDate.isAfter(startDate)) {
          final dateString =
              "${workoutDate.year}-${workoutDate.month.toString().padLeft(2, '0')}-${workoutDate.day.toString().padLeft(2, '0')}";
          double minutes = workout['duration_minutes']?.toDouble() ?? 0;
          workoutMinutesByDate[dateString] =
              (workoutMinutesByDate[dateString] ?? 0) + minutes;
        }
      }
    }

    // Sort dates
    List<String> sortedDates = workoutMinutesByDate.keys.toList()..sort();

    // Create spots for the chart (reverse order to show oldest to newest)
    List<FlSpot> spots = [];
    double xValue = 0;
    final spacing =
        daysToShow / (sortedDates.length > 1 ? sortedDates.length - 1 : 1);

    for (int i = sortedDates.length - 1; i >= 0; i--) {
      String date = sortedDates[i];
      double minutes = workoutMinutesByDate[date] ?? 0;
      spots.add(FlSpot(xValue, minutes));
      xValue += spacing;
    }

    return spots.isEmpty ? _generateDefaultSpots(30.0) : spots;
  }

  // Steps chart data
  List<FlSpot> _getStepsChartData(int daysToShow) {
    if (_stepData.isEmpty) {
      return _generateDefaultSpots(8000.0);
    }

    // Only use the data for the requested days
    final filteredStepData = _stepData.take(daysToShow).toList();

    // For large datasets (yearly), aggregate the data to improve performance
    if (daysToShow > 90) {
      return _getAggregatedStepData(filteredStepData, daysToShow);
    }

    // Sort by date (oldest first)
    filteredStepData.sort((a, b) => a['date'].compareTo(b['date']));

    // Get the spacing between points
    final spacing = daysToShow /
        (filteredStepData.length > 1 ? filteredStepData.length - 1 : 1);

    // Create spots for the chart
    List<FlSpot> spots = [];
    for (int i = 0; i < filteredStepData.length; i++) {
      int steps = filteredStepData[i]['steps'] ?? 0;
      spots.add(FlSpot(i * spacing, steps.toDouble()));
    }

    return spots.isEmpty ? _generateDefaultSpots(8000.0) : spots;
  }

  // Helper method to aggregate step data for better performance
  List<FlSpot> _getAggregatedStepData(
      List<Map<String, dynamic>> data, int daysToShow) {
    // For yearly view, aggregate by weeks (52 points instead of 365)
    final int aggregationFactor =
        daysToShow > 300 ? 7 : (daysToShow > 60 ? 3 : 1);

    // Group the data
    Map<int, List<Map<String, dynamic>>> groupedData = {};

    for (var i = 0; i < data.length; i++) {
      final groupIndex = i ~/ aggregationFactor;
      if (!groupedData.containsKey(groupIndex)) {
        groupedData[groupIndex] = [];
      }
      groupedData[groupIndex]!.add(data[i]);
    }

    // Aggregate each group
    List<FlSpot> spots = [];
    final keys = groupedData.keys.toList()..sort();

    for (var i = 0; i < keys.length; i++) {
      final group = groupedData[keys[i]]!;
      double total = 0;
      for (var item in group) {
        total += (item['steps'] ?? 0).toDouble();
      }
      // Average the values
      final average = group.isEmpty ? 0.0 : total / group.length;
      spots.add(FlSpot(i.toDouble(), average));
    }

    return spots;
  }

  // Calories chart data
  List<FlSpot> _getCaloriesChartData(int daysToShow) {
    if (_stepData.isEmpty) {
      return _generateDefaultSpots(300.0);
    }

    // Only use the data for the requested days
    final filteredStepData = _stepData.take(daysToShow).toList();

    // For large datasets (yearly), aggregate the data to improve performance
    if (daysToShow > 90) {
      return _getAggregatedCalorieData(filteredStepData, daysToShow);
    }

    // Sort by date (oldest first)
    filteredStepData.sort((a, b) => a['date'].compareTo(b['date']));

    // Get the spacing between points
    final spacing = daysToShow /
        (filteredStepData.length > 1 ? filteredStepData.length - 1 : 1);

    // Create spots for the chart
    List<FlSpot> spots = [];
    for (int i = 0; i < filteredStepData.length; i++) {
      int calories = filteredStepData[i]['calories'] ?? 0;
      spots.add(FlSpot(i * spacing, calories.toDouble()));
    }

    return spots.isEmpty ? _generateDefaultSpots(300.0) : spots;
  }

  // Helper method to aggregate calorie data for better performance
  List<FlSpot> _getAggregatedCalorieData(
      List<Map<String, dynamic>> data, int daysToShow) {
    // For yearly view, aggregate by weeks (52 points instead of 365)
    final int aggregationFactor =
        daysToShow > 300 ? 7 : (daysToShow > 60 ? 3 : 1);

    // Group the data
    Map<int, List<Map<String, dynamic>>> groupedData = {};

    for (var i = 0; i < data.length; i++) {
      final groupIndex = i ~/ aggregationFactor;
      if (!groupedData.containsKey(groupIndex)) {
        groupedData[groupIndex] = [];
      }
      groupedData[groupIndex]!.add(data[i]);
    }

    // Aggregate each group
    List<FlSpot> spots = [];
    final keys = groupedData.keys.toList()..sort();

    for (var i = 0; i < keys.length; i++) {
      final group = groupedData[keys[i]]!;
      double total = 0;
      for (var item in group) {
        total += (item['calories'] ?? 0).toDouble();
      }
      // Average the values
      final average = group.isEmpty ? 0.0 : total / group.length;
      spots.add(FlSpot(i.toDouble(), average));
    }

    return spots;
  }

  // Generate default chart data for empty datasets
  List<FlSpot> _generateDefaultSpots(double baseValue) {
    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      // Create some random variation
      double variation = (i % 3 == 0)
          ? 0.2
          : (i % 2 == 0)
              ? -0.3
              : 0.1;
      spots.add(FlSpot(i.toDouble(), baseValue + (baseValue * variation)));
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

  // Get body fat category
  String _getBodyFatCategory(double bodyFat) {
    return BodyFatCalculator.getBodyFatCategory(_userGender, bodyFat);
  }

  @override
  Widget build(BuildContext context) {
    // Check if dark mode is enabled
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Calculate BMI only once
    String bmiValue = _calculateBMI();
    String bmiCategory =
        bmiValue != "N/A" ? _getBMICategory(double.parse(bmiValue)) : "Unknown";

    // Get latest body fat percentage
    double? bodyFatPercentage = _getLatestMeasurement('body_fat_percentage');
    String bodyFatCategory = bodyFatPercentage != null
        ? _getBodyFatCategory(bodyFatPercentage)
        : "Unknown";

    return Scaffold(
      backgroundColor: TColor.backgroundColor(context),
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

                      // Header - removed the top right icon
                      Text(
                        "Progress",
                        style: TextStyle(
                          color: TColor.textColor(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
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
                                // Body fat with tooltip
                                Expanded(
                                  child: Tooltip(
                                    message: bodyFatPercentage != null
                                        ? "Estimated using ${_measurements.first['waist'] != null ? 'U.S. Navy formula' : 'BMI-based calculation'}"
                                        : "No body fat data available",
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 30,
                                                width: 30,
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.pie_chart_outline,
                                                  color: TColor.white,
                                                  size: 18,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                "Body Fat",
                                                style: TextStyle(
                                                  color: TColor.white
                                                      .withOpacity(0.7),
                                                  fontSize: 13,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(
                                                Icons.info_outline,
                                                color: TColor.white
                                                    .withOpacity(0.7),
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "${bodyFatPercentage?.toStringAsFixed(1) ?? '--'}%",
                                            style: TextStyle(
                                              color: TColor.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  bodyFatCategory,
                                                  style: TextStyle(
                                                    color: TColor.white
                                                        .withOpacity(0.7),
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "Estimated value",
                                            style: TextStyle(
                                              color:
                                                  TColor.white.withOpacity(0.5),
                                              fontSize: 9,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Measurement Tracking Section - header only (removed cards)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Measurements",
                            style: TextStyle(
                              color: TColor.textColor(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              // Show dialog to add new measurement
                              bool? result = await _showAddMeasurementDialog();
                              if (result == true) {
                                _loadUserData(); // Reload measurements after adding
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

                      SizedBox(height: 20),

                      // Chart Section
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: TColor.lightGrayColor(context),
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
                                    color: TColor.whiteColor(context),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: TColor.grayColor(context)
                                            .withOpacity(0.3)),
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedMetric,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: TColor.grayColor(context),
                                    ),
                                    underline: SizedBox(),
                                    items: metrics.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            color: TColor.textColor(context),
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
                                    color: TColor.whiteColor(context),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: TColor.grayColor(context)
                                            .withOpacity(0.3)),
                                  ),
                                  child: DropdownButton<String>(
                                    value: selectedRange,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      color: TColor.grayColor(context),
                                    ),
                                    underline: SizedBox(),
                                    items: timeRanges.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value,
                                          style: TextStyle(
                                            color: TColor.textColor(context),
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
                                        // Reload data when range changes
                                        _refreshData();
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
                                    // Reduce number of grid lines for better performance
                                    horizontalInterval:
                                        selectedMetric == "Steps"
                                            ? 5000
                                            : selectedMetric == "Calories"
                                                ? 200
                                                : 5,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: TColor.grayColor(context)
                                            .withOpacity(0.15),
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        // Show fewer labels for better performance
                                        interval: selectedMetric == "Steps"
                                            ? 5000
                                            : selectedMetric == "Calories"
                                                ? 200
                                                : selectedMetric == "Body Fat"
                                                    ? 5
                                                    : null,
                                        getTitlesWidget: (value, meta) =>
                                            leftTitleWidgets(
                                                value, meta, context),
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
                                        // Show fewer x-axis labels for yearly view
                                        interval: selectedRange == "Yearly"
                                            ? 30
                                            : selectedRange == "3 Months"
                                                ? 10
                                                : null,
                                        getTitlesWidget: (value, meta) =>
                                            bottomTitleWidgets(
                                                value, meta, context),
                                        reservedSize: 30,
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  // Set min and max Y values based on the selected metric
                                  minY: _getChartMinY(),
                                  maxY: _getChartMaxY(),
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
                                            strokeColor:
                                                TColor.whiteColor(context),
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
                                              TColor.textColor(context)
                                                  .withOpacity(0.8),
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
                                              color: TColor.whiteColor(context),
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
    final neckController = TextEditingController();
    final waistController = TextEditingController();
    final hipController = TextEditingController();

    // Pre-fill with latest measurements if available
    if (_measurements.isNotEmpty) {
      weightController.text = _getLatestMeasurement('weight')?.toString() ?? '';
      heightController.text = _getLatestMeasurement('height')?.toString() ?? '';
      waistController.text = _getLatestMeasurement('waist')?.toString() ?? '';
      neckController.text = _getLatestMeasurement('neck')?.toString() ?? '';
      hipController.text = _getLatestMeasurement('hip')?.toString() ?? '';
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
              SizedBox(height: 15),
              Text(
                "For accurate body fat calculation (optional):",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: neckController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Neck (cm)",
                  hintText: "Circumference at narrowest point",
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: waistController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: "Waist (cm)",
                  hintText: "Circumference at navel",
                ),
              ),
              if (_userGender.toLowerCase() == 'female')
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextField(
                    controller: hipController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: "Hip (cm)",
                      hintText: "Circumference at widest point",
                    ),
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
                // Calculate age from date of birth in the user profile
                int? age = _calculateAgeFromDateOfBirth();

                await _supabaseService.addBodyMeasurement(
                  weight: double.parse(weightController.text),
                  height: heightController.text.isNotEmpty
                      ? double.parse(heightController.text)
                      : null,
                  waist: waistController.text.isNotEmpty
                      ? double.parse(waistController.text)
                      : null,
                  neck: neckController.text.isNotEmpty
                      ? double.parse(neckController.text)
                      : null,
                  hip: hipController.text.isNotEmpty
                      ? double.parse(hipController.text)
                      : null,
                  age: age,
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

  // Calculate age from the user's date of birth stored in the profile
  int? _calculateAgeFromDateOfBirth() {
    try {
      // Get the user's profile to retrieve date of birth
      final profile =
          Provider.of<AuthProvider>(context, listen: false).userProfile;

      // Check if there's a date of birth in the profile
      if (profile != null && profile['date_of_birth'] != null) {
        final dob = DateTime.parse(profile['date_of_birth']);
        final now = DateTime.now();

        // Calculate the age
        int age = now.year - dob.year;

        // Adjust age if birthday hasn't occurred this year yet
        if (now.month < dob.month ||
            (now.month == dob.month && now.day < dob.day)) {
          age--;
        }

        return age;
      }

      // If there's no date of birth in the profile, use a default adult age
      return 30; // Default to 30 if no DOB is available
    } catch (e) {
      print("Error calculating age: $e");
      return 30; // Default to 30 if there's an error
    }
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

  // Chart Title Widgets
  Widget leftTitleWidgets(double value, TitleMeta meta, BuildContext context) {
    String unit;
    // Show appropriate unit based on metric
    switch (selectedMetric) {
      case "Weight":
        unit = "kg";
        break;
      case "Body Fat":
        unit = "%";
        break;
      case "Workouts":
        unit = "min";
        break;
      case "Steps":
        // For steps, show abbreviated thousands (k)
        return Text(
          '${(value / 1000).toStringAsFixed(1)}k',
          style: TextStyle(
            color: TColor.grayColor(context),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        );
      case "Calories":
        unit = "cal";
        break;
      default:
        unit = "";
    }

    return Text(
      '${value.toInt()} $unit',
      style: TextStyle(
        color: TColor.grayColor(context),
        fontSize: 10,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget bottomTitleWidgets(
      double value, TitleMeta meta, BuildContext context) {
    final style = TextStyle(
      color: TColor.grayColor(context),
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    // Determine label format based on selected range
    switch (selectedRange) {
      case "Weekly":
        // For weekly, show days of week
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final index = value.toInt() % days.length;
        if (index >= 0 && index < days.length) {
          return Text(days[index], style: style);
        }
        return Text('', style: style);

      case "Monthly":
        // For monthly, show day numbers every 5 days
        if (value.toInt() % 5 == 0) {
          int dayNum = value.toInt() + 1;
          return Text('$dayNum', style: style);
        }
        return Text('', style: style);

      case "3 Months":
        // For 3 months, show month/week indicators
        if (value.toInt() % 10 == 0) {
          int weekNum = (value.toInt() / 7).round();
          return Text('W$weekNum', style: style);
        }
        return Text('', style: style);

      case "Yearly":
        // For yearly, show month abbreviations
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec'
        ];
        int monthIndex = (value.toInt() * 12 / 365).floor();
        if (value.toInt() % 30 == 0 && monthIndex < months.length) {
          return Text(months[monthIndex], style: style);
        }
        return Text('', style: style);

      default:
        // Fallback to simple numbering
        if (value.toInt() % 2 == 0) {
          return Text(value.toInt().toString(), style: style);
        }
        return Text('', style: style);
    }
  }

  double _getChartMinY() {
    switch (selectedMetric) {
      case "Weight":
        // For weight, set a reasonable minimum based on actual data or fallback to 50
        if (_measurements.isNotEmpty) {
          final weights = _measurements
              .map((m) => m['weight']?.toDouble() ?? 0)
              .where((w) => w > 0)
              .toList();
          if (weights.isNotEmpty) {
            return (weights.reduce((a, b) => a < b ? a : b) * 0.9)
                .roundToDouble();
          }
        }
        return 50.0;

      case "Body Fat":
        // For body fat, minimum is usually 5%
        return 5.0;

      case "Workouts":
        // For workouts, minimum is 0 minutes
        return 0.0;

      case "Steps":
        // For steps, minimum is 0
        return 0.0;

      case "Calories":
        // For calories, minimum is 0
        return 0.0;

      default:
        return 0.0;
    }
  }

  double _getChartMaxY() {
    switch (selectedMetric) {
      case "Weight":
        // For weight, set a reasonable maximum based on actual data or fallback to 100
        if (_measurements.isNotEmpty) {
          final weights = _measurements
              .map((m) => m['weight']?.toDouble() ?? 0)
              .where((w) => w > 0)
              .toList();
          if (weights.isNotEmpty) {
            return (weights.reduce((a, b) => a > b ? a : b) * 1.1)
                .roundToDouble();
          }
        }
        return 100.0;

      case "Body Fat":
        // For body fat, maximum is usually 40%
        return 40.0;

      case "Workouts":
        // For workouts, maximum is around 120 minutes (2 hours)
        final data = _getWorkoutsChartData(_getDaysToFetch());
        final maxValue = data.isEmpty
            ? 120.0
            : data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
        return math.max(120.0, (maxValue * 1.2).roundToDouble());

      case "Steps":
        // For steps, maximum is around 20,000 or higher based on data
        final data = _getStepsChartData(_getDaysToFetch());
        final maxValue = data.isEmpty
            ? 20000.0
            : data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
        return math.max(20000.0, (maxValue * 1.2).roundToDouble());

      case "Calories":
        // For calories, maximum is around 1000 or higher based on data
        final data = _getCaloriesChartData(_getDaysToFetch());
        final maxValue = data.isEmpty
            ? 1000.0
            : data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
        return math.max(1000.0, (maxValue * 1.2).roundToDouble());

      default:
        return 100.0;
    }
  }
}
