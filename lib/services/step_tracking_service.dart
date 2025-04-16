import 'package:fitness_tracker/services/supabase_service.dart';
import 'package:intl/intl.dart';

class StepTrackingService {
  static final StepTrackingService _instance = StepTrackingService._internal();
  factory StepTrackingService() => _instance;
  StepTrackingService._internal();

  final SupabaseService _supabaseService = SupabaseService();

  int _stepsCount = 0;
  int _stepsGoal = 10000; // Default goal

  bool _isInitialized = false;

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

      _isInitialized = true;
    } catch (e) {
      print('Error initializing step tracking: $e');
    }
  }

  // Add steps manually
  Future<void> addSteps(int steps) async {
    if (!_isInitialized) await initialize();

    // Update local steps count
    _stepsCount = steps;

    // Save to Supabase
    await syncStepsToSupabase();
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
