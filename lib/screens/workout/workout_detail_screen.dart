import 'package:flutter/material.dart';
import 'package:fitness_tracker/common/color_extension.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_service.dart';
import 'package:lottie/lottie.dart';
import '../../widgets/video_player_widget.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final String workoutType;

  const WorkoutDetailScreen({
    Key? key,
    required this.workoutType,
  }) : super(key: key);

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  bool _isError = false;
  bool _isCompleting = false;
  bool _isCompleted = false;
  Map<String, dynamic> _workoutDetails = {};
  String? _videoUrl;

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get workout details
      _workoutDetails =
          await _supabaseService.getWorkoutDetails(widget.workoutType);

      // Get video URL
      _videoUrl = await _supabaseService.getWorkoutVideoUrl(widget.workoutType);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading workout data: $e');
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  Future<void> _completeWorkout() async {
    try {
      setState(() {
        _isCompleting = true;
      });

      await _supabaseService.logWorkout(
        title: _workoutDetails['title'],
        description: _workoutDetails['description'],
        durationMinutes: _workoutDetails['duration_minutes'],
        caloriesBurned: _workoutDetails['calories'],
        workoutType: widget.workoutType,
        difficultyLevel: _workoutDetails['difficulty_level'],
      );

      setState(() {
        _isCompleting = false;
        _isCompleted = true;
      });

      // Show success animation for 2 seconds then navigate back
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.pop();
        }
      });
    } catch (e) {
      setState(() {
        _isCompleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error completing workout: ${e.toString()}")),
      );
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
          _isLoading ? 'Loading...' : _workoutDetails['title'] ?? 'Workout',
          style: TextStyle(
            color: TColor.textColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: TColor.primaryColor1))
          : _isError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: TColor.primaryColor1,
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load workout',
                        style: TextStyle(
                          color: TColor.textColor(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadWorkoutData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.primaryColor1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _isCompleted
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'assets/images/success_animation.json',
                            width: 200,
                            height: 200,
                            repeat: false,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Workout Completed!',
                            style: TextStyle(
                              color: TColor.textColor(context),
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Great job! Your progress has been saved.',
                            style: TextStyle(
                              color: TColor.grayColor(context),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Video Player
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: VideoPlayerWidget(videoUrl: _videoUrl),
                          ),
                          const SizedBox(height: 24),

                          // Workout Details
                          Text(
                            _workoutDetails['title'] ?? 'Workout',
                            style: TextStyle(
                              color: TColor.textColor(context),
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Workout Stats
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: TColor.lightGrayColor(context),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                // Difficulty
                                _buildStatItem(
                                  context,
                                  Icons.fitness_center,
                                  'Difficulty',
                                  _workoutDetails['difficulty_level'] ??
                                      'Beginner',
                                ),
                                // Duration
                                _buildStatItem(
                                  context,
                                  Icons.timer_outlined,
                                  'Duration',
                                  '${_workoutDetails['duration_minutes'] ?? 0} min',
                                ),
                                // Calories
                                _buildStatItem(
                                  context,
                                  Icons.local_fire_department_outlined,
                                  'Calories',
                                  '${_workoutDetails['calories'] ?? 0}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Description
                          Text(
                            'Description',
                            style: TextStyle(
                              color: TColor.textColor(context),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _workoutDetails['description'] ??
                                'No description available.',
                            style: TextStyle(
                              color: TColor.grayColor(context),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
      bottomNavigationBar: !_isLoading && !_isError && !_isCompleted
          ? Container(
              padding: const EdgeInsets.all(15),
              child: ElevatedButton(
                onPressed: _isCompleting ? null : _completeWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primaryColor1,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isCompleting
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Finish Workout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            )
          : null,
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String title,
    String value,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: TColor.primaryColor1,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: TColor.grayColor(context),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: TColor.textColor(context),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
