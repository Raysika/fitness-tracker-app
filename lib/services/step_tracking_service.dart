import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:fitness_tracker/services/supabase_service.dart';
import 'package:intl/intl.dart';

class StepTrackingService {
  static final StepTrackingService _instance = StepTrackingService._internal();
  factory StepTrackingService() => _instance;
  StepTrackingService._internal();

  final SupabaseService _supabaseService = SupabaseService();

  Stream<StepCount>? _stepCountStream;
  StreamSubscription<StepCount>? _stepCountSubscription;

  int _stepsCount = 0;
  int _stepsGoal = 10000; // Default goal
  DateTime _lastSyncTime = DateTime.now();

  bool _isInitialized = false;
  bool _isTracking = false;

  // Get current steps
  int get steps => _stepsCount;
  int get stepsGoal => _stepsGoal;
  double get stepsProgress => _stepsCount / _stepsGoal;

  // Initialize the step tracking service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load step goal from Supabase
      await _loadStepGoal();

      // Load today's steps if any
      await _loadTodaySteps();

      // Initialize pedometer
      _stepCountStream = Pedometer.stepCountStream;
      _isInitialized = true;
    } catch (e) {
      print('Error initializing step tracking: $e');
    }
  }

  // Start tracking steps
  Future<void> startTracking() async {
    if (!_isInitialized) await initialize();
    if (_isTracking) return;

    try {
      _stepCountSubscription = _stepCountStream?.listen(_onStepCount);
      _isTracking = true;

      // Set up periodic sync
      Timer.periodic(Duration(minutes: 15), (timer) {
        syncStepsToSupabase();
      });
    } catch (e) {
      print('Error starting step tracking: $e');
    }
  }

  // Stop tracking steps
  void stopTracking() {
    _stepCountSubscription?.cancel();
    _isTracking = false;
  }

  // Handle step count events
  void _onStepCount(StepCount event) {
    // In a real app, we would handle step count more robustly
    // For demo, we'll just increment the steps
    _stepsCount = event.steps;
    _checkAndSyncSteps();
  }

  // Check if we need to sync steps to Supabase
  void _checkAndSyncSteps() {
    final now = DateTime.now();
    if (now.difference(_lastSyncTime).inMinutes >= 15) {
      syncStepsToSupabase();
      _lastSyncTime = now;
    }
  }

  // Sync steps to Supabase
  Future<void> syncStepsToSupabase() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _supabaseService.updateStepCount(today, _stepsCount);
    } catch (e) {
      print('Error syncing steps to Supabase: $e');
    }
  }

  // Load today's steps from Supabase
  Future<void> _loadTodaySteps() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final steps = await _supabaseService.getDailyStepCount(today);
      if (steps != null) {
        _stepsCount = steps;
      }
    } catch (e) {
      print('Error loading today\'s steps: $e');
    }
  }

  // Load step goal from Supabase
  Future<void> _loadStepGoal() async {
    try {
      final profile = await _supabaseService.getUserProfile();
      if (profile != null && profile['step_goal'] != null) {
        _stepsGoal = profile['step_goal'];
      }
    } catch (e) {
      print('Error loading step goal: $e');
    }
  }

  // Update step goal
  Future<void> updateStepGoal(int goal) async {
    _stepsGoal = goal;
    // Update step_goal in user_profiles table through Supabase
    await _supabaseService.updateUserProfile(stepGoal: goal);
  }
}
