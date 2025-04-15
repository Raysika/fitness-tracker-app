import 'package:flutter/material.dart';
import 'package:fitness_tracker/common/color_extension.dart';
import '../../services/supabase_service.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../routes/routes.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({Key? key}) : super(key: key);

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  List<Map<String, dynamic>> _workoutHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutHistory();
  }

  Future<void> _loadWorkoutHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final history = await _supabaseService.getWorkoutHistory();
      setState(() {
        _workoutHistory = history;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading workout history: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Unknown date';

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM d, yyyy - h:mm a').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: TColor.textColor(context),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Workout History',
          style: TextStyle(
            color: TColor.textColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: TColor.textColor(context),
            ),
            onPressed: _loadWorkoutHistory,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: TColor.primaryColor1))
          : _workoutHistory.isEmpty
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
                        'No workout history found',
                        style: TextStyle(
                          color: TColor.textColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Complete your first workout to see it here!',
                        style: TextStyle(
                          color: TColor.grayColor(context),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: _workoutHistory.length,
                  itemBuilder: (context, index) {
                    final workout = _workoutHistory[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Container(
                        decoration: BoxDecoration(
                          color: TColor.lightGrayColor(context),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    _getGradientColors(workout['workout_type']),
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getWorkoutIcon(workout['workout_type']),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          title: Text(
                            workout['title'] ?? 'Unknown Workout',
                            style: TextStyle(
                              color: TColor.textColor(context),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(workout['date_completed']),
                                style: TextStyle(
                                  color: TColor.grayColor(context),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer_outlined,
                                    color: TColor.primaryColor1,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${workout['duration_minutes'] ?? 0} min',
                                    style: TextStyle(
                                      color: TColor.grayColor(context),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(
                                    Icons.local_fire_department_outlined,
                                    color: TColor.primaryColor1,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${workout['calories_burned'] ?? 0} cal',
                                    style: TextStyle(
                                      color: TColor.grayColor(context),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(
                            Icons.chevron_right,
                            color: TColor.primaryColor1,
                          ),
                          onTap: () {
                            // Navigate to workout detail
                            context.push(
                              Uri(
                                path: AppRoutes.workoutDetail,
                                queryParameters: {
                                  'type': workout['workout_type'] ?? 'Fullbody'
                                },
                              ).toString(),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  List<Color> _getGradientColors(String? workoutType) {
    if (workoutType == null) return TColor.primaryG;

    switch (workoutType.toLowerCase()) {
      case 'fullbody':
        return TColor.primaryG;
      case 'upper':
        return TColor.secondaryG;
      case 'lower':
        return [
          TColor.primaryColor2.withOpacity(0.5),
          TColor.secondaryColor2.withOpacity(0.5),
        ];
      case 'abs':
        return [
          TColor.primaryColor1,
          TColor.secondaryColor1,
        ];
      case 'core':
        return [
          TColor.secondaryColor2,
          TColor.secondaryColor1,
        ];
      case 'cardio':
        return [
          Colors.orange,
          Colors.deepOrangeAccent,
        ];
      default:
        return TColor.primaryG;
    }
  }

  IconData _getWorkoutIcon(String? workoutType) {
    if (workoutType == null) return Icons.fitness_center;

    switch (workoutType.toLowerCase()) {
      case 'fullbody':
        return Icons.fitness_center;
      case 'upper':
        return Icons.accessibility_new;
      case 'lower':
        return Icons.airline_seat_legroom_extra_outlined;
      case 'abs':
        return Icons.sports_gymnastics;
      case 'core':
        return Icons.speed;
      case 'cardio':
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }
}
