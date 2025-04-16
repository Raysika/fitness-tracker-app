import 'package:flutter/material.dart';
import 'package:fitness_tracker/common/color_extension.dart';
import 'package:go_router/go_router.dart';
import '../../services/supabase_service.dart';
import 'package:lottie/lottie.dart';
import '../../widgets/video_player_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:confetti/confetti.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final String workoutType;

  const WorkoutDetailScreen({
    Key? key,
    required this.workoutType,
  }) : super(key: key);

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

// Static cache for video URLs
class _VideoCache {
  static final Map<String, String> _cache = {};

  static String? getUrl(String workoutType) {
    return _cache[workoutType];
  }

  static void setUrl(String workoutType, String url) {
    _cache[workoutType] = url;
  }

  static bool hasUrl(String workoutType) {
    return _cache.containsKey(workoutType);
  }
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;
  bool _isError = false;
  bool _isCompleting = false;
  bool _isCompleted = false;
  Map<String, dynamic> _workoutDetails = {};
  String? _videoUrl;
  late ConfettiController _confettiController;

  // Check if running on Windows/Web
  bool get _isWindowsOrWeb {
    try {
      return kIsWeb || Platform.isWindows;
    } catch (e) {
      // If Platform is not available, assume false
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadWorkoutData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Get workout details
      _workoutDetails =
          await _supabaseService.getWorkoutDetails(widget.workoutType);

      // First check if we have a cached URL
      if (_VideoCache.hasUrl(widget.workoutType)) {
        print('Using cached video URL for ${widget.workoutType}');
        _videoUrl = _VideoCache.getUrl(widget.workoutType);
        setState(() {
          _isLoading = false;
        });
      } else {
        // Get video URL from service
        print('Fetching video URL for ${widget.workoutType}');
        final url =
            await _supabaseService.getWorkoutVideoUrl(widget.workoutType);
        if (url != null) {
          _VideoCache.setUrl(widget.workoutType, url);
        }
        _videoUrl = url;

        setState(() {
          _isLoading = false;
        });
      }
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

      // Start confetti animation
      _confettiController.play();

      // Show success screen for a few seconds then navigate back
      Future.delayed(const Duration(seconds: 5), () {
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
      appBar: _isCompleted
          ? null // Hide the app bar when showing completion screen
          : AppBar(
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
                _isLoading
                    ? 'Loading...'
                    : _workoutDetails['title'] ?? 'Workout',
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
                  ? _buildWorkoutCompletedScreen()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Video Player
                          _buildVideoSection(),
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

  Widget _buildVideoSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          // Video Player
          VideoPlayerWidget(
            videoUrl: _videoUrl,
            onError: (String message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
          ),

          // "Open in browser" button - only show on mobile
          if (!_isWindowsOrWeb && _videoUrl != null && _videoUrl!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.open_in_browser,
                      color: TColor.primaryColor1, size: 16),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () async {
                      if (_videoUrl != null) {
                        // Launch URL in browser
                        final Uri url = Uri.parse(_videoUrl!);
                        try {
                          print('Opening URL in browser: $_videoUrl');
                          await launchUrl(url);
                        } catch (e) {
                          print('Could not launch URL: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Could not open video in browser')),
                          );
                        }
                      }
                    },
                    child: Text(
                      'Open in browser',
                      style: TextStyle(
                        color: TColor.primaryColor1,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
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

  Widget _buildWorkoutCompletedScreen() {
    return Stack(
      children: [
        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.2,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.red,
            ],
          ),
        ),

        // Content
        Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Workout completion image
                  Image.asset(
                    'assets/images/workout_completed.png',
                    width: 250,
                    height: 250,
                  ),
                  const SizedBox(height: 40),

                  // Congratulations text
                  Text(
                    'Congratulations, You Have',
                    style: TextStyle(
                      color: TColor.textColor(context),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'Finished Your Workout',
                    style: TextStyle(
                      color: TColor.textColor(context),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  // Motivational quote
                  Text(
                    'Exercises is king and nutrition is queen. Combine the',
                    style: TextStyle(
                      color: TColor.grayColor(context),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    'two and you will have a kingdom',
                    style: TextStyle(
                      color: TColor.grayColor(context),
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Quote attribution
                  Text(
                    '-Jack Lalanne',
                    style: TextStyle(
                      color: TColor.grayColor(context),
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Continue button
                  ElevatedButton(
                    onPressed: () {
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primaryColor1,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
