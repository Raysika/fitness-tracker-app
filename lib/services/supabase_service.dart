// lib/services/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Authentication Methods
  Future<void> signUp(
      String email, String password, String firstName, String lastName) async {
    final AuthResponse res = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (res.user != null) {
      // Create user profile
      await supabase.from('user_profiles').insert({
        'id': res.user!.id,
        'first_name': firstName,
        'last_name': lastName,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> signIn(String email, String password) async {
    await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // User Profile Methods
  Future<Map<String, dynamic>?> getUserProfile() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from('user_profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return data;
  }

  Future<void> updateUserProfile({
    String? firstName,
    String? lastName,
    String? gender,
    String? dateOfBirth,
    double? height,
    double? weight,
    String? fitnessGoal,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    Map<String, dynamic> updates = {
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (firstName != null) updates['first_name'] = firstName;
    if (lastName != null) updates['last_name'] = lastName;
    if (gender != null) updates['gender'] = gender;
    if (dateOfBirth != null) updates['date_of_birth'] = dateOfBirth;
    if (height != null) updates['height'] = height;
    if (weight != null) updates['weight'] = weight;
    if (fitnessGoal != null) updates['fitness_goal'] = fitnessGoal;

    await supabase.from('user_profiles').update(updates).eq('id', userId);
  }

  // Measurements Methods
  Future<void> addBodyMeasurement({
    required double weight,
    double? height,
    double? chest,
    double? waist,
    double? arms,
    double? thighs,
    double? bodyFatPercentage,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await supabase.from('body_measurements').insert({
      'user_id': userId,
      'weight': weight,
      'height': height,
      'chest': chest,
      'waist': waist,
      'arms': arms,
      'thighs': thighs,
      'body_fat_percentage': bodyFatPercentage,
      'date_recorded': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getBodyMeasurements() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('body_measurements')
        .select()
        .eq('user_id', userId)
        .order('date_recorded', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // Workout Methods
  Future<void> logWorkout({
    required String title,
    String? description,
    required int durationMinutes,
    int? caloriesBurned,
    required String workoutType,
    required String difficultyLevel,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await supabase.from('workouts').insert({
      'user_id': userId,
      'title': title,
      'description': description,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'date_completed': DateTime.now().toIso8601String(),
      'workout_type': workoutType,
      'difficulty_level': difficultyLevel,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getWorkoutHistory() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('workouts')
        .select()
        .eq('user_id', userId)
        .order('date_completed', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  // Get workout exercises
  Future<List<Map<String, dynamic>>> getWorkoutExercises(
      String workoutId) async {
    final data = await supabase
        .from('workout_exercises')
        .select('*, exercises(*)')
        .eq('workout_id', workoutId)
        .order('id');

    return List<Map<String, dynamic>>.from(data);
  }

  // Get list of exercises
  Future<List<Map<String, dynamic>>> getExercises() async {
    final data = await supabase.from('exercises').select().order('name');

    return List<Map<String, dynamic>>.from(data);
  }
}
