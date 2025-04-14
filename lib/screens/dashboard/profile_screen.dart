// lib/screens/dashboard/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:fitness_tracker/common/color_extension.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../routes/routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Map<String, dynamic> userData;
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final profile = await _supabaseService.getUserProfile();
    if (profile != null) {
      setState(() {
        // Convert numeric values to proper types
        double? height = profile['height'] != null
            ? (profile['height'] is int
                ? profile['height'].toDouble()
                : profile['height'])
            : null;

        double? weight = profile['weight'] != null
            ? (profile['weight'] is int
                ? profile['weight'].toDouble()
                : profile['weight'])
            : null;

        userData = {
          'name':
              '${profile['first_name'] ?? ''} ${profile['last_name'] ?? ''}',
          'email': Supabase.instance.client.auth.currentUser?.email ?? '',
          'goal': profile['fitness_goal'] ?? 'Not set',
          'height': height != null ? '$height cm' : 'Not set',
          'weight': weight != null ? '$weight kg' : 'Not set',
          'bmi': _calculateBMI(height, weight),
          'joinDate': 'Joined ${_formatDate(profile['created_at'])}',
        };
        _isLoading = false;
      });
    }
  }

  String _calculateBMI(double? height, double? weight) {
    if (height == null || weight == null || height == 0) return 'N/A';
    final heightInMeters = height / 100;
    final bmi = weight / (heightInMeters * heightInMeters);
    return bmi.toStringAsFixed(1);
  }

  String _formatDate(String? isoString) {
    if (isoString == null) return 'N/A';
    try {
      final date = DateTime.parse(isoString);
      return '${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Profile Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: TColor.primaryColor1,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/profile_placeholder.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            userData['name'],
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userData['email'],
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            userData['joinDate'],
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // User Information Section
                    Text(
                      "Personal Information",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildInfoCard(
                      icon: Icons.person_outline,
                      title: "Name",
                      value: userData['name'],
                      onTap: () => _editProfileField('Name'),
                    ),
                    _buildInfoCard(
                      icon: Icons.email_outlined,
                      title: "Email",
                      value: userData['email'],
                      onTap: () => _editProfileField('Email'),
                    ),
                    _buildInfoCard(
                      icon: Icons.height,
                      title: "Height",
                      value: userData['height'],
                      onTap: () => _editProfileField('Height'),
                    ),
                    _buildInfoCard(
                      icon: Icons.monitor_weight_outlined,
                      title: "Weight",
                      value: userData['weight'],
                      onTap: () => _editProfileField('Weight'),
                    ),
                    const SizedBox(height: 25),

                    // Fitness Goals Section (from onboarding)
                    Text(
                      "Fitness Goals",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: TColor.lightGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            color: TColor.primaryColor1,
                            size: 30,
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Primary Goal",
                                  style: TextStyle(
                                    color: TColor.gray,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  userData['goal'],
                                  style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: TColor.gray,
                              size: 18,
                            ),
                            onPressed: () => _editGoal(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),

                    // App Preferences Section
                    Text(
                      "App Preferences",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: TColor.lightGray.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          _buildPreferenceSwitch(
                            icon: Icons.dark_mode_outlined,
                            title: "Dark Mode",
                            value: _isDarkMode,
                            onChanged: (value) {
                              setState(() {
                                _isDarkMode = value;
                                // In a real app, you would update the app theme here
                                // AppTheme.setDarkMode(value);
                              });
                            },
                          ),
                          const Divider(height: 25),
                          _buildPreferenceItem(
                            icon: Icons.notifications_none,
                            title: "Notifications",
                            onTap: () => _manageNotifications(),
                          ),
                          const Divider(height: 25),
                          _buildPreferenceItem(
                            icon: Icons.language,
                            title: "Language",
                            onTap: () => _changeLanguage(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Logout Button
                    Center(
                      child: TextButton(
                        onPressed: () => _confirmLogout(),
                        child: Text(
                          "Logout",
                          style: TextStyle(
                            color: TColor.primaryColor1,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Reset App State Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Show confirmation dialog
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Reset App State"),
                              content: const Text(
                                "This will clear all app data and return to the splash screen. "
                                "Use this for development purposes only. Continue?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text("Reset"),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true) {
                            // Get router reference before clearing state
                            final router = GoRouter.of(context);

                            // Clear preferences and sign out
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            await Supabase.instance.client.auth.signOut();

                            // Navigate back to splash
                            router.go(AppRoutes.splash);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(color: Colors.red.shade200),
                          ),
                        ),
                        child: const Text("Reset App State (Development Only)"),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: TColor.lightGray.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: TColor.primaryColor1, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.arrow_forward_ios,
              color: TColor.gray,
              size: 18,
            ),
            onPressed: onTap,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceSwitch({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: TColor.primaryColor1, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: TColor.black,
              fontSize: 16,
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: TColor.primaryColor1,
        ),
      ],
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: TColor.primaryColor1, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: TColor.black,
                fontSize: 16,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: TColor.gray,
            size: 18,
          ),
        ],
      ),
    );
  }

  // Mock functions for the actions
  void _editProfileField(String field) {
    // In a real app, this would open an edit dialog
    print("Editing $field");
  }

  void _editGoal() {
    // This would navigate to a goal selection screen
    print("Editing goal");
  }

  void _manageNotifications() {
    // This would open notification settings
    print("Managing notifications");
  }

  void _changeLanguage() {
    // This would open language selection
    print("Changing language");
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // First get the BuildContext for navigation
              final router = GoRouter.of(context);

              // Close the dialog first
              Navigator.pop(dialogContext);

              // Then perform the signout operation
              await context.read<AuthProvider>().signOut();

              // Navigate to login screen after signout is complete
              // Use the saved router instead of context.go
              router.go(AppRoutes.login);
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
