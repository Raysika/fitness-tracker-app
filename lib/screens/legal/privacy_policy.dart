import 'package:flutter/material.dart';
import '../../common/color_extension.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: TColor.backgroundColor(context),
        elevation: 0,
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: TColor.textColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: TColor.textColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SyncFit Privacy Policy',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: TColor.textColor(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Last Updated: April 16, 2025',
                style: TextStyle(
                  fontSize: 14,
                  color: TColor.grayColor(context),
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 20),
              _buildSectionTitle(context, 'Introduction'),
              _buildParagraph(
                context,
                'SyncFit ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application and related services.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Information We Collect'),
              _buildParagraph(
                context,
                'We collect information that you provide directly to us, such as when you create an account, update your profile, or use the features of our app. This information may include:',
              ),
              _buildBulletPoint(
                  context, 'Personal information (name, email address)'),
              _buildBulletPoint(
                  context, 'Profile information (age, gender, photos)'),
              _buildBulletPoint(context,
                  'Health and fitness data (weight, height, body measurements)'),
              _buildBulletPoint(
                  context, 'Activity data (workouts, steps, water intake)'),
              _buildBulletPoint(
                  context, 'Device information and usage statistics'),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'How We Use Your Information'),
              _buildParagraph(
                context,
                'We use the information we collect to:',
              ),
              _buildBulletPoint(
                  context, 'Provide, maintain, and improve our services'),
              _buildBulletPoint(context, 'Create and update your account'),
              _buildBulletPoint(
                  context, 'Process and track your fitness activities'),
              _buildBulletPoint(
                  context, 'Provide personalized recommendations'),
              _buildBulletPoint(
                  context, 'Communicate with you about our services'),
              _buildBulletPoint(
                  context, 'Analyze usage and improve the user experience'),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Data Security'),
              _buildParagraph(
                context,
                'We implement appropriate security measures to protect your personal data against unauthorized access, alteration, disclosure, or destruction. However, please be aware that no method of transmission over the internet or electronic storage is 100% secure.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Your Choices'),
              _buildParagraph(
                context,
                'You can access, update, or delete your account information at any time through the app settings. You can also choose which data you share with the app and adjust your notification preferences.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Contact Us'),
              _buildParagraph(
                context,
                'If you have any questions or concerns about this Privacy Policy, please contact us at privacy@syncfit.example.com',
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: TColor.primaryColor1,
        ),
      ),
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: TColor.textColor(context),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: TColor.primaryColor1,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: TColor.textColor(context),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
