// lib/screens/dashboard/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:fitness_tracker/common/color_extension.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Mock user data - in a real app, this would come from your database
  final Map<String, dynamic> userData = {
    'name': 'Stefani Wong',
    'email': 'stefani.wong@example.com',
    'goal': 'Lose Fat', // This would come from onboarding
    'height': '170 cm',
    'weight': '65 kg',
    'bmi': '20.1',
    'joinDate': 'Joined May 2023',
  };

  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, you would handle logout logic here
              print("User logged out");
            },
            child: Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
