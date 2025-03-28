import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../common/color_extension.dart';
import '../../routes/routes.dart';
import '../../themes/theme.dart';

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({super.key});

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
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
                // For v5.0.0, we don't pass controller directly
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
                            // width: media.width * 0.5,
                            // fit: BoxFit.contain,
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
                ),
              ),
            ),

            // Confirm Button
            Padding(
              padding: const EdgeInsets.all(25),
              child: ElevatedButton(
                onPressed: () {
                  context.go(AppRoutes.welcome);
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
                child: Text(
                  "Confirm",
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
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
