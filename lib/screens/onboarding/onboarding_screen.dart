import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'onboarding_model.dart';
import 'onboarding_widget.dart';
import '../../common/color_extension.dart'; // Import TColor
import '../../routes/routes.dart'; // Import AppRoutes

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingModel> onboardingData = [
    OnboardingModel(
      title: 'Track Your Progress',
      description: 'Monitor your fitness journey with detailed analytics.',
      image: 'assets/images/onboarding1.png',
    ),
    OnboardingModel(
      title: 'Personalized Workouts',
      description: 'Get workout plans tailored to your goals.',
      image: 'assets/images/onboarding2.png',
    ),
    OnboardingModel(
      title: 'Stay Motivated',
      description: 'Achieve your fitness goals with daily reminders and tips.',
      image: 'assets/images/onboarding3.png',
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _navigateToSignUp(BuildContext context) {
    // Changed method name and navigation target
    context.go(AppRoutes.signup); // Navigate to signup screen instead of login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return OnboardingWidget(model: onboardingData[index]);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? TColor.primaryColor1
                        : TColor.lightGray,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: _currentPage == onboardingData.length - 1
                    ? () =>
                        _navigateToSignUp(context) // Updated to use new method
                    : () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primaryColor1,
                  foregroundColor: TColor.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                child: Text(
                  _currentPage == onboardingData.length - 1
                      ? 'Get Started'
                      : 'Next',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
