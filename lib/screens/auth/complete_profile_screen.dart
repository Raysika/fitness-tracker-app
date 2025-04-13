// lib/screens/auth/complete_profile_screen.dart
import 'package:fitness_tracker/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../common/color_extension.dart'; // Import TColor
import '../../themes/theme.dart'; // Import AppTheme
import '../../services/supabase_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _selectedGender = 'Male';
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _supabaseService.updateUserProfile(
          gender: _selectedGender,
          dateOfBirth: _dobController.text,
          height: double.parse(_heightController.text),
          weight: double.parse(_weightController.text),
        );

        // Also add initial body measurement
        await _supabaseService.addBodyMeasurement(
          weight: double.parse(_weightController.text),
          height: double.parse(_heightController.text),
        );

        context.go(AppRoutes.goalSelection);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
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
    return Scaffold(
      backgroundColor: TColor.white, // Use TColor for background color
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor:
            TColor.primaryColor1, // Use TColor for app bar background
        foregroundColor: TColor.white, // Use TColor for app bar text color
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add the image at the top
              Image.asset(
                'assets/images/complete_profile.png', // Path to your image
              ),
              const SizedBox(height: 20), // Add some spacing
              Text(
                'Step 1 of 3',
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: TColor.gray, // Use TColor for text color
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(
                      color: TColor.black), // Use TColor for label color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: TColor
                            .primaryColor1), // Use TColor for border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: TColor
                            .primaryColor1), // Use TColor for focused border
                  ),
                ),
                style:
                    TextStyle(color: TColor.black), // Use TColor for text color
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  labelStyle: TextStyle(
                      color: TColor.black), // Use TColor for label color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: TColor
                            .primaryColor1), // Use TColor for border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: TColor
                            .primaryColor1), // Use TColor for focused border
                  ),
                ),
                dropdownColor:
                    TColor.white, // Use TColor for dropdown background
                style:
                    TextStyle(color: TColor.black), // Use TColor for text color
                items: ['Male', 'Female', 'Other']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _dobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  labelStyle: TextStyle(
                      color: TColor.black), // Use TColor for label color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: TColor
                            .primaryColor1), // Use TColor for border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: TColor
                            .primaryColor1), // Use TColor for focused border
                  ),
                ),
                style:
                    TextStyle(color: TColor.black), // Use TColor for text color
                readOnly: true,
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    _dobController.text =
                        "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your date of birth';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'Height (cm)',
                  labelStyle: TextStyle(
                      color: TColor.black), // Use TColor for label color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: TColor
                            .primaryColor1), // Use TColor for border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: TColor
                            .primaryColor1), // Use TColor for focused border
                  ),
                ),
                style:
                    TextStyle(color: TColor.black), // Use TColor for text color
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your height';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _weightController,
                decoration: InputDecoration(
                  labelText: 'Weight (kg)',
                  labelStyle: TextStyle(
                      color: TColor.black), // Use TColor for label color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: TColor
                            .primaryColor1), // Use TColor for border color
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: TColor
                            .primaryColor1), // Use TColor for focused border
                  ),
                ),
                style:
                    TextStyle(color: TColor.black), // Use TColor for text color
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your weight';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        TColor.primaryColor1, // Use TColor for button color
                    foregroundColor: TColor.white, // Use TColor for text color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 40,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
