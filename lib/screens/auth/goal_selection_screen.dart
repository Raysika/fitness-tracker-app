// lib/screens/auth/goal_selection_screen.dart

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/color_extension.dart';
import '../../routes/routes.dart';
import '../../themes/theme.dart';
import '../../services/supabase_service.dart';

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  final SupabaseService _supabaseService = SupabaseService();
  int _selectedGoalIndex = 0;
  bool _isLoading = false;
  final List<Map<String, String>> goalOptions = [
    {
      "image": "assets/images/goal_1.png",
      "title": "Improve Shape",
      "description":
          "I have a low amount of body fat\nand need to build more muscle"
    },
    {
      "image": "assets/images/goal_2.png",
      "title": "Lean & Tone",
      "description":
          "I'm skinny fat. I want to add\nlean muscle in the right way"
    },
    {
      "image": "assets/images/goal_3.png",
      "title": "Lose Fat",
      "description": "I want to drop fat and gain\nmuscle mass"
    },
  ];
  String get _selectedGoal =>
      goalOptions[_selectedGoalIndex]["title"] ?? "Improve Shape";

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                children: [
                  Text(
                    "What is your goal?",
                    style:
                        AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                      color: TColor.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "It will help us choose the best\nprogram for you",
                    textAlign: TextAlign.center,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: TColor.gray,
                    ),
                  ),
                ],
              ),
            ),

            // Carousel Section
            Expanded(
              child: CarouselSlider(
                items: goalOptions.map((goal) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: TColor.primaryG,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: TColor.primaryColor1.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            goal["image"]!,
                          ),
                          const SizedBox(height: 30),
                          Text(
                            goal["title"]!,
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              color: TColor.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 2,
                            color: TColor.white,
                          ),
                          const SizedBox(height: 15),
                          Text(
                            goal["description"]!,
                            textAlign: TextAlign.center,
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: TColor.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  height: media.height * 1.0,
                  viewportFraction: 0.75,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _selectedGoalIndex = index;
                    });
                  },
                ),
              ),
            ),

            // Confirm Button
            Padding(
              padding: const EdgeInsets.all(25),
              child: ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    await _supabaseService.updateUserProfile(
                      fitnessGoal: _selectedGoal,
                    );

                    // Save goal selection completion in preferences
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('goal_selected', true);

                    if (context.mounted) {
                      context.go(AppRoutes.welcome);
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: ${e.toString()}")),
                      );
                    }
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primaryColor1,
                  foregroundColor: TColor.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 0),
                  elevation: 5,
                  shadowColor: TColor.primaryColor1.withOpacity(0.3),
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
                    : Text(
                        "Confirm",
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
