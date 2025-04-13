// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;

  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _user = Supabase.instance.client.auth.currentUser;
    if (_user != null) {
      await _fetchUserProfile();
    }

    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.userUpdated) {
        _user = session?.user;
        _fetchUserProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _userProfile = null;
      }

      notifyListeners();
    });
  }

  Future<void> _fetchUserProfile() async {
    if (_user == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      _userProfile = await _supabaseService.getUserProfile();
    } catch (e) {
      print('Error fetching user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabaseService.signIn(email, password);
      _user = Supabase.instance.client.auth.currentUser;
      await _fetchUserProfile();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(
      String email, String password, String firstName, String lastName) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabaseService.signUp(email, password, firstName, lastName);
      _user = Supabase.instance.client.auth.currentUser;
      await _fetchUserProfile();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabaseService.signOut();

      _user = null;
      _userProfile = null;
    } catch (e) {
      print('Error signing out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? gender,
    String? dateOfBirth,
    double? height,
    double? weight,
    String? fitnessGoal,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabaseService.updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        gender: gender,
        dateOfBirth: dateOfBirth,
        height: height,
        weight: weight,
        fitnessGoal: fitnessGoal,
      );

      await _fetchUserProfile();
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
