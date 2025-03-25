import 'package:flutter/material.dart';
import 'onboarding_model.dart';
import '../../common/color_extension.dart'; // Import TColor
import '../../themes/theme.dart'; // Import AppTheme

class OnboardingWidget extends StatelessWidget {
  final OnboardingModel model;

  const OnboardingWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          model.image,
          height: 300,
        ),
        const SizedBox(height: 20),
        Text(
          model.title,
          style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
            color: TColor.black, // Use TColor for text color
          ),
        ),
        const SizedBox(height: 10),
        Text(
          model.description,
          textAlign: TextAlign.center,
          style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
            color: TColor.gray, // Use TColor for text color
          ),
        ),
      ],
    );
  }
}
