// lib/screens/dashboard/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:fitness_tracker/common/color_extension.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
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
  String? _profileImageUrl;
  File? _selectedImage;

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
          'firstName': profile['first_name'] ?? '',
          'lastName': profile['last_name'] ?? '',
          'email': Supabase.instance.client.auth.currentUser?.email ?? '',
          'goal': profile['fitness_goal'] ?? 'Not set',
          'height': height != null ? '$height cm' : 'Not set',
          'weight': weight != null ? '$weight kg' : 'Not set',
          'gender': profile['gender'] ?? 'Not set',
          'heightValue': height,
          'weightValue': weight,
          'bmi': _calculateBMI(height, weight),
          'joinDate': 'Joined ${_formatDate(profile['created_at'])}',
        };
        _profileImageUrl = profile['profile_image_url'];
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

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isLoading = true;
      });

      try {
        final imageUrl =
            await _supabaseService.uploadProfileImage(_selectedImage!);
        if (imageUrl != null) {
          setState(() {
            _profileImageUrl = imageUrl;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: TColor.backgroundColor(context),
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
                          GestureDetector(
                            onTap: _pickAndUploadImage,
                            child: Stack(
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
                                    child: _profileImageUrl != null
                                        ? Image.network(
                                            _profileImageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                'assets/images/profile_placeholder.jpg',
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                        : Image.asset(
                                'assets/images/profile_placeholder.jpg',
                                fit: BoxFit.cover,
                              ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: TColor.primaryColor1,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.edit,
                                      color: TColor.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            userData['name'],
                            style: TextStyle(
                              color: TColor.textColor(context),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            userData['email'],
                            style: TextStyle(
                              color: TColor.grayColor(context),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            userData['joinDate'],
                            style: TextStyle(
                              color: TColor.grayColor(context),
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
                        color: TColor.textColor(context),
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
                      icon: Icons.person,
                      title: "Gender",
                      value: userData['gender'],
                      onTap: () => _editProfileField('Gender'),
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
                        color: TColor.textColor(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: TColor.lightGrayColor(context),
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
                                    color: TColor.grayColor(context),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  userData['goal'],
                                  style: TextStyle(
                                    color: TColor.textColor(context),
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
                              color: TColor.grayColor(context),
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
                        color: TColor.textColor(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: TColor.lightGrayColor(context),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
                          _buildPreferenceSwitch(
                            icon: Icons.dark_mode_outlined,
                            title: "Dark Mode",
                            value: themeProvider.isDarkMode,
                            onChanged: (value) {
                              themeProvider.toggleTheme();
                            },
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
        color: TColor.lightGrayColor(context),
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
                    color: TColor.grayColor(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                    color: TColor.textColor(context),
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
              color: TColor.grayColor(context),
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
              color: TColor.textColor(context),
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

  // Edit profile field
  void _editProfileField(String field) {
    String? initialValue;
    String hintText = '';
    TextInputType inputType = TextInputType.text;

    switch (field) {
      case 'Name':
        initialValue = userData['name'];
        hintText = 'Enter your full name';
        break;
      case 'Email':
        initialValue = userData['email'];
        hintText = 'Enter your email';
        inputType = TextInputType.emailAddress;
        break;
      case 'Gender':
        _showGenderPicker();
        return;
      case 'Height':
        _showHeightWeightEditor(true);
        return;
      case 'Weight':
        _showHeightWeightEditor(false);
        return;
      default:
        initialValue = '';
    }

    if (field == 'Email') {
      // Show notification that email can't be changed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email address cannot be changed.'),
        ),
      );
      return;
    }

    // For name, show name editor
    if (field == 'Name') {
      _showNameEditor();
      return;
    }

    // For others, show generic text editor
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $field'),
        content: TextField(
          controller: TextEditingController(text: initialValue),
          decoration: InputDecoration(hintText: hintText),
          keyboardType: inputType,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Save changes logic here
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showNameEditor() {
    final firstNameController =
        TextEditingController(text: userData['firstName']);
    final lastNameController =
        TextEditingController(text: userData['lastName']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);

              try {
                await _supabaseService.updateUserProfile(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                );
                await _loadUserData(); // Refresh data
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating name: $e')),
                );
                setState(() => _isLoading = false);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showGenderPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Male'),
              onTap: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                await _supabaseService.updateUserProfile(gender: 'Male');
                await _loadUserData();
              },
            ),
            ListTile(
              title: const Text('Female'),
              onTap: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                await _supabaseService.updateUserProfile(gender: 'Female');
                await _loadUserData();
              },
            ),
            ListTile(
              title: const Text('Other'),
              onTap: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                await _supabaseService.updateUserProfile(gender: 'Other');
                await _loadUserData();
              },
            ),
            ListTile(
              title: const Text('Prefer not to say'),
              onTap: () async {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                await _supabaseService.updateUserProfile(
                    gender: 'Prefer not to say');
                await _loadUserData();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showHeightWeightEditor(bool isHeight) {
    final controller = TextEditingController(
        text: isHeight
            ? userData['heightValue']?.toString() ?? ''
            : userData['weightValue']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${isHeight ? 'Height' : 'Weight'}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: isHeight ? 'Height (cm)' : 'Weight (kg)',
            suffixText: isHeight ? 'cm' : 'kg',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              if (controller.text.isEmpty) return;

              try {
                final value = double.parse(controller.text);
                setState(() => _isLoading = true);

                if (isHeight) {
                  await _supabaseService.updateUserProfile(height: value);
                } else {
                  await _supabaseService.updateUserProfile(weight: value);
                }

                await _loadUserData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid number')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editGoal() {
    final goals = [
      'Lose Weight',
      'Build Muscle',
      'Improve Fitness',
      'Increase Flexibility',
      'Maintain Health'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Goal'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: goals.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(goals[index]),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  await _supabaseService.updateUserProfile(
                      fitnessGoal: goals[index]);
                  await _loadUserData();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
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
