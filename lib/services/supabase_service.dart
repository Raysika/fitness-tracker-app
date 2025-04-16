// lib/services/supabase_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import './body_fat_calculator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // Shared Preferences keys
  static const String _calorieGoalKey = 'calorie_goal';
  static const String _workoutMinuteGoalKey = 'workout_minute_goal';

  // Shared preferences keys for remember me feature
  static const String rememberMeKey = 'remember_me';
  static const String savedEmailKey = 'saved_email';

  // Default values
  static const int defaultCalorieGoal = 1200;
  static const int defaultWorkoutMinuteGoal = 60;

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
    // Get Remember Me data using our helper method
    final rememberMeData = await getRememberMeData();
    final rememberMe = rememberMeData['rememberMe'];
    final savedEmail = rememberMeData['email'];

    print(
        'Sign out - Remember me setting: $rememberMe, Saved email: $savedEmail');

    // If remember me is off, clear saved email
    if (!rememberMe) {
      await setRememberMe(false, '');
      print('Cleared saved email on sign out');
    } else {
      print('Keeping saved email for next login: $savedEmail');
    }

    // Sign out from Supabase
    await supabase.auth.signOut();
  }

  // Password Reset Method
  Future<void> resetPassword(String email) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.flutterquickstart://reset-callback/',
    );
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
    String? profileImageUrl,
    int? stepGoal,
    int? waterGoal,
    int? calorieGoal,
    int? workoutMinuteGoal,
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
    if (profileImageUrl != null) updates['profile_image_url'] = profileImageUrl;
    if (stepGoal != null) updates['step_goal'] = stepGoal;
    if (waterGoal != null) updates['water_goal'] = waterGoal;

    // Save calorie goal and workout minute goal to SharedPreferences
    if (calorieGoal != null || workoutMinuteGoal != null) {
      final prefs = await SharedPreferences.getInstance();

      if (calorieGoal != null) {
        await prefs.setInt(_calorieGoalKey, calorieGoal);
        print('Calorie goal set to $calorieGoal (saved to SharedPreferences)');
      }

      if (workoutMinuteGoal != null) {
        await prefs.setInt(_workoutMinuteGoalKey, workoutMinuteGoal);
        print(
            'Workout minute goal set to $workoutMinuteGoal (saved to SharedPreferences)');
      }
    }

    await supabase.from('user_profiles').update(updates).eq('id', userId);
  }

  // Profile Image Methods
  Future<String?> uploadProfileImage(File imageFile) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = 'profile_$userId$fileExt';
      final filePath = 'profiles/$fileName';

      print('Attempting to upload file to: $filePath');
      print('User ID: $userId');
      print('File extension: $fileExt');

      // Upload the file to storage
      await supabase.storage.from('user-images').upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
          );

      print('Upload successful!');

      // Try getting a signed URL with direct access
      try {
        final signedUrl =
            await supabase.storage.from('user-images').createSignedUrl(
                  filePath,
                  60 * 60 * 24 * 365, // 1 year expiry
                );

        print('Created signed URL: $signedUrl');

        // Update the user profile with the signed URL
        await updateUserProfile(profileImageUrl: signedUrl);

        return signedUrl;
      } catch (e) {
        print('Error creating signed URL: $e');
        // Fall back to public URL if signed URL fails
      }

      // Get the public URL as fallback
      final imageUrlResponse =
          supabase.storage.from('user-images').getPublicUrl(filePath);

      print('Fallback public URL: $imageUrlResponse');

      // Update the user profile with the public URL
      await updateUserProfile(profileImageUrl: imageUrlResponse);

      return imageUrlResponse;
    } catch (error) {
      print('Error uploading profile image: $error');
      if (error is StorageException) {
        print(
            'Storage error details: ${error.message}, status: ${error.statusCode}');
      }
      return null;
    }
  }

  Future<String?> getProfileImageUrl() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final profile = await getUserProfile();
    return profile?['profile_image_url'];
  }

  // Measurements Methods
  Future<void> addBodyMeasurement({
    required double weight,
    double? height,
    double? chest,
    double? waist,
    double? neck,
    double? hip,
    double? arms,
    double? thighs,
    double? bodyFatPercentage,
    int? age,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    // Get user profile to retrieve gender for body fat calculation
    final profile = await getUserProfile();
    String gender = profile?['gender'] ?? 'male'; // Default to male if not set

    // If body fat percentage wasn't provided, calculate it
    double calculatedBodyFat = bodyFatPercentage ?? 0.0;

    // Only calculate body fat if not directly provided AND we have height
    if (bodyFatPercentage == null && height != null) {
      try {
        calculatedBodyFat = _calculateBodyFat(
          gender: gender,
          heightCm: height,
          weightKg: weight,
          waistCm: waist,
          neckCm: neck,
          hipCm: hip,
          age: age ?? 30, // Default to age 30 if not provided
        );
      } catch (e) {
        print('Error calculating body fat: $e');
        // Keep the default value (0.0) if calculation fails
      }
    }

    await supabase.from('body_measurements').insert({
      'user_id': userId,
      'weight': weight,
      'height': height,
      'chest': chest,
      'waist': waist,
      'neck': neck,
      'hip': hip,
      'arms': arms,
      'thighs': thighs,
      'body_fat_percentage': calculatedBodyFat,
      'date_recorded': DateTime.now().toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Helper method to calculate body fat
  double _calculateBodyFat({
    required String gender,
    required double heightCm,
    required double weightKg,
    double? waistCm,
    double? neckCm,
    double? hipCm,
    required int age,
  }) {
    // Use the BodyFatCalculator to calculate body fat
    return BodyFatCalculator.calculateBodyFat(
      gender: gender,
      heightCm: heightCm,
      weightKg: weightKg,
      waistCm: waistCm,
      neckCm: neckCm,
      hipCm: hipCm,
      age: age,
    );
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
    bool completed = true,
  }) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await supabase.from('workouts').insert({
      'user_id': userId,
      'title': title,
      'description': description,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'date_completed': completed ? DateTime.now().toIso8601String() : null,
      'workout_type': workoutType,
      'difficulty_level': difficultyLevel,
      'created_at': DateTime.now().toIso8601String(),
      'completed': completed,
    });
  }

  Future<List<Map<String, dynamic>>> getWorkoutHistory() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('workouts')
        .select()
        .eq('user_id', userId)
        .eq('completed', true)
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

  // Get workout video URL
  Future<String?> getWorkoutVideoUrl(String workoutType) async {
    try {
      print('Getting workout video for type: $workoutType');
      final data = await supabase
          .from('workout_videos')
          .select('video_url')
          .eq('workout_type', workoutType)
          .limit(1)
          .single();

      final videoUrl = data['video_url'] as String?;
      print('Video URL from database: $videoUrl');

      if (videoUrl != null && videoUrl.isNotEmpty) {
        // Make sure it's a valid YouTube URL and format it properly
        final formattedUrl = _ensureValidYoutubeUrl(videoUrl);
        print('Formatted video URL: $formattedUrl');
        return formattedUrl;
      }

      print('No video URL found in database for: $workoutType');
      return _getFallbackVideoUrl(workoutType);
    } catch (e) {
      print('Error getting workout video URL from database: $e');
      // Fallback to hardcoded videos if database query fails
      return _getFallbackVideoUrl(workoutType);
    }
  }

  // Get fallback video URL
  String _getFallbackVideoUrl(String workoutType) {
    print('Using fallback video for: $workoutType');
    // These are verified working YouTube video IDs
    Map<String, String> fallbackVideoIds = {
      'Fullbody': 'UBMk30rjy0o',
      'Upper': 'aP03n2ZqfaU',
      'Lower': 'kwkXyHjgoDM',
      'Abs': '8AAmaSOSyIA',
      'Core': 'DHD1-2PKufg',
      'Cardio': 'ml6cT4AZdqI',
    };

    final videoId =
        fallbackVideoIds[workoutType] ?? fallbackVideoIds['Fullbody']!;
    final url = 'https://www.youtube.com/watch?v=$videoId';
    print('Fallback video URL: $url');
    return url;
  }

  // Helper method to ensure YouTube URLs are properly formatted
  String _ensureValidYoutubeUrl(String url) {
    if (url.isEmpty) {
      print('Empty URL provided to _ensureValidYoutubeUrl');
      return 'https://www.youtube.com/watch?v=UBMk30rjy0o'; // Default fallback
    }

    // Handle youtu.be format
    if (url.contains('youtu.be/')) {
      final parts = url.split('youtu.be/');
      if (parts.length > 1) {
        final videoId = parts[1].split('?')[0].split('&')[0];
        print('Extracted video ID from youtu.be URL: $videoId');
        return 'https://www.youtube.com/watch?v=$videoId';
      }
    }

    // Handle embed format
    if (url.contains('youtube.com/embed/')) {
      final parts = url.split('youtube.com/embed/');
      if (parts.length > 1) {
        final videoId = parts[1].split('?')[0].split('&')[0];
        print('Extracted video ID from embed URL: $videoId');
        return 'https://www.youtube.com/watch?v=$videoId';
      }
    }

    // Handle normal YouTube URLs
    if (url.contains('youtube.com/watch')) {
      // Extract v parameter
      final uri = Uri.parse(url);
      final videoId = uri.queryParameters['v'];
      if (videoId != null && videoId.isNotEmpty) {
        print('Extracted video ID from watch URL: $videoId');
        return 'https://www.youtube.com/watch?v=$videoId';
      }
    }

    print('URL format not recognized, using as is: $url');
    // Already in proper format or unrecognized
    return url;
  }

  // Get workout details by type
  Future<Map<String, dynamic>> getWorkoutDetails(String workoutType) async {
    // In a real app, this would fetch from the database
    // Returning hardcoded data for demonstration
    Map<String, Map<String, dynamic>> workoutDetails = {
      'Fullbody': {
        'title': 'Fullbody Workout',
        'description':
            'A complete workout targeting all major muscle groups for overall strength and conditioning.',
        'calories': 350,
        'duration_minutes': 40,
        'difficulty_level': 'Beginner',
        'exercises_count': 12,
      },
      'Upper': {
        'title': 'Upper Body Workout',
        'description':
            'Focus on chest, back, shoulders and arms for upper body strength and definition.',
        'calories': 280,
        'duration_minutes': 30,
        'difficulty_level': 'Intermediate',
        'exercises_count': 10,
      },
      'Lower': {
        'title': 'Lower Body Workout',
        'description':
            'Target your legs, glutes and calves for lower body strength and endurance.',
        'calories': 320,
        'duration_minutes': 25,
        'difficulty_level': 'Beginner',
        'exercises_count': 8,
      },
      'Abs': {
        'title': 'Abs Workout',
        'description':
            'Core-focused workout to strengthen abs and build a solid foundation.',
        'calories': 200,
        'duration_minutes': 20,
        'difficulty_level': 'Intermediate',
        'exercises_count': 6,
      },
      'Core': {
        'title': 'Core & Abs Builder',
        'description':
            'Comprehensive core workout targeting all abdominal muscles and lower back.',
        'calories': 230,
        'duration_minutes': 25,
        'difficulty_level': 'Intermediate',
        'exercises_count': 8,
      },
      'Cardio': {
        'title': 'Cardio Blast',
        'description':
            'High-intensity cardio workout to improve stamina and burn calories.',
        'calories': 400,
        'duration_minutes': 30,
        'difficulty_level': 'Advanced',
        'exercises_count': 10,
      },
    };

    return Future.value(
        workoutDetails[workoutType] ?? workoutDetails['Fullbody']);
  }

  // Get workouts by type
  Future<List<Map<String, dynamic>>> getWorkoutsByType(
      String? workoutType) async {
    if (workoutType == null || workoutType.toLowerCase() == 'all') {
      // Return all predefined workouts
      List<String> types = [
        'Fullbody',
        'Upper',
        'Lower',
        'Abs',
        'Core',
        'Cardio'
      ];
      List<Map<String, dynamic>> allWorkouts = [];

      for (var type in types) {
        allWorkouts.add(await getWorkoutDetails(type));
      }

      return allWorkouts;
    } else {
      // Return workouts of the specified type
      var workout = await getWorkoutDetails(workoutType);
      return [workout];
    }
  }

  // Get workout recommendations based on user's fitness goal
  Future<List<Map<String, dynamic>>> getWorkoutRecommendations() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    // Get user's fitness goal
    final profile = await getUserProfile();
    String fitnessGoal = profile?['fitness_goal'] ?? 'General Fitness';

    // Get user's workout history
    final workoutHistory = await getWorkoutHistory();

    // Simple recommendation logic based on fitness goal
    // In a real app, this would be more sophisticated
    List<Map<String, dynamic>> recommendations = [];

    switch (fitnessGoal.toLowerCase()) {
      case 'lose weight':
        recommendations.add(await getWorkoutDetails('Cardio'));
        recommendations.add(await getWorkoutDetails('Fullbody'));
        break;
      case 'gain muscle':
        recommendations.add(await getWorkoutDetails('Upper'));
        recommendations.add(await getWorkoutDetails('Lower'));
        break;
      case 'improve fitness':
        recommendations.add(await getWorkoutDetails('Fullbody'));
        recommendations.add(await getWorkoutDetails('Cardio'));
        break;
      default:
        // General fitness or any other goal
        recommendations.add(await getWorkoutDetails('Core'));
        recommendations.add(await getWorkoutDetails('Fullbody'));
    }

    // Add recommendation reason based on history
    for (var rec in recommendations) {
      rec['reason'] = 'Based on your fitness goal: $fitnessGoal';

      // If they haven't done this workout type recently, add that reason
      if (workoutHistory.isEmpty ||
          !workoutHistory
              .any((w) => w['workout_type'] == rec['title'].split(' ')[0])) {
        rec['reason'] = 'Try something new based on your goals';
      }
    }

    return recommendations;
  }

  // Search workouts
  Future<List<Map<String, dynamic>>> searchWorkouts(String query) async {
    if (query.isEmpty) return [];

    query = query.toLowerCase();
    List<String> types = [
      'Fullbody',
      'Upper',
      'Lower',
      'Abs',
      'Core',
      'Cardio'
    ];
    List<Map<String, dynamic>> results = [];

    for (var type in types) {
      var workout = await getWorkoutDetails(type);
      if (workout['title'].toString().toLowerCase().contains(query) ||
          workout['description'].toString().toLowerCase().contains(query)) {
        results.add(workout);
      }
    }

    return results;
  }

  // Step Tracking Methods
  Future<void> updateStepCount(String date, int steps) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Check if entry exists for this date
    final existing = await supabase
        .from('step_tracking')
        .select()
        .eq('user_id', userId)
        .eq('date', date)
        .maybeSingle();

    if (existing != null) {
      // Update existing entry
      await supabase
          .from('step_tracking')
          .update({
            'steps': steps,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('date', date);
    } else {
      // Create new entry
      await supabase.from('step_tracking').insert({
        'user_id': userId,
        'date': date,
        'steps': steps,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<int?> getDailyStepCount(String date) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from('step_tracking')
        .select('steps')
        .eq('user_id', userId)
        .eq('date', date)
        .maybeSingle();

    return data?['steps'] as int?;
  }

  // Efficient batch method to get step data for a date range
  Future<List<Map<String, dynamic>>> getStepDataRange(
      String startDate, String endDate) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      // Query all step data within the date range in a single request
      final data = await supabase
          .from('step_tracking')
          .select('date, steps')
          .eq('user_id', userId)
          .gte('date', startDate) // Greater than or equal to start date
          .lte('date', endDate) // Less than or equal to end date
          .order('date', ascending: false);

      if (data == null) return [];

      // Convert to the required format
      List<Map<String, dynamic>> result = [];
      for (var item in data) {
        final steps = item['steps'] as int? ?? 0;
        // Estimate calories based on steps (simple calculation)
        final calories = (steps * 0.04).round();

        result.add({
          'date': item['date'],
          'steps': steps,
          'calories': calories,
        });
      }

      return result;
    } catch (e) {
      print('Error fetching step data range: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getDailyActivitySummary() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      return {
        'steps': 0,
        'step_goal': 10000,
        'calories': 0,
        'calorie_goal': defaultCalorieGoal,
        'workout_minutes': 0,
        'workout_minute_goal': defaultWorkoutMinuteGoal,
        'water_intake': 0,
        'water_goal': 4000, // 4 liters in ml
      };
    }

    // Get today's date
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Get steps
    final steps = await getDailyStepCount(today) ?? 0;

    // Get user profile for goals
    final profile = await getUserProfile();
    final stepGoal = profile?['step_goal'] ?? 10000;
    final waterGoal = profile?['water_goal'] ?? 4000; // 4 liters in ml

    // Get goals from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final calorieGoal = prefs.getInt(_calorieGoalKey) ?? defaultCalorieGoal;
    final workoutMinuteGoal =
        prefs.getInt(_workoutMinuteGoalKey) ?? defaultWorkoutMinuteGoal;

    // Calculate estimated calories based on steps (very simple estimation)
    // In a real app, this would be much more sophisticated
    final estimatedCalories = (steps * 0.04).round();

    // Get water intake
    final waterIntake = await getDailyWaterIntake(today) ?? 0;

    // Get workout minutes from completed workouts for today
    final workoutMinutes = await getDailyWorkoutMinutes(today) ?? 0;

    return {
      'steps': steps,
      'step_goal': stepGoal,
      'calories': estimatedCalories,
      'calorie_goal': calorieGoal,
      'workout_minutes': workoutMinutes,
      'workout_minute_goal': workoutMinuteGoal,
      'water_intake': waterIntake,
      'water_goal': waterGoal,
    };
  }

  // Water Tracking Methods
  Future<void> logWaterIntake(int amount) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final now = DateTime.now().toIso8601String();

    await supabase.from('water_intake').insert({
      'user_id': userId,
      'date': today,
      'amount': amount,
      'time': now,
      'created_at': now,
    });
  }

  Future<int?> getDailyWaterIntake(String date) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from('water_intake')
        .select('amount')
        .eq('user_id', userId)
        .eq('date', date);

    if (data == null || data.isEmpty) return 0;

    // Sum the amounts
    int total = 0;
    for (var entry in data) {
      total += entry['amount'] as int;
    }

    return total;
  }

  Future<List<Map<String, dynamic>>> getDailyWaterIntakeDetails(
      String date) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await supabase
        .from('water_intake')
        .select()
        .eq('user_id', userId)
        .eq('date', date)
        .order('time', ascending: true);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<int?> getDailyWorkoutMinutes(String date) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await supabase
        .from('workouts')
        .select('duration_minutes')
        .eq('user_id', userId)
        .eq('date_completed', date)
        .eq('completed', true);

    if (data == null || data.isEmpty) return 0;

    // Sum the workout minutes
    int total = 0;
    for (var entry in data) {
      total += entry['duration_minutes'] as int;
    }

    return total;
  }

  // Helper methods for goal management
  Future<int> getCalorieGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_calorieGoalKey) ?? defaultCalorieGoal;
  }

  Future<void> setCalorieGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_calorieGoalKey, goal);
  }

  Future<int> getWorkoutMinuteGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_workoutMinuteGoalKey) ?? defaultWorkoutMinuteGoal;
  }

  Future<void> setWorkoutMinuteGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_workoutMinuteGoalKey, goal);
  }

  // Helper methods for remember me functionality
  Future<void> setRememberMe(bool value, String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(rememberMeKey, value);
    if (value && email.isNotEmpty) {
      await prefs.setString(savedEmailKey, email);
      print('SupabaseService: Set remember me=$value, email=$email');
    } else {
      await prefs.remove(savedEmailKey);
      print('SupabaseService: Cleared remember me data');
    }
  }

  Future<Map<String, dynamic>> getRememberMeData() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(rememberMeKey) ?? false;
    final email = prefs.getString(savedEmailKey) ?? '';
    print('SupabaseService: Got remember me=$rememberMe, email=$email');
    return {
      'rememberMe': rememberMe,
      'email': email,
    };
  }
}
