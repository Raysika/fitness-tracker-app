import 'package:flutter/material.dart';
import '../../common/color_extension.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: TColor.backgroundColor(context),
        elevation: 0,
        title: Text(
          'Terms of Use',
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
                'SyncFit Terms of Use',
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
              _buildSectionTitle(context, 'Agreement to Terms'),
              _buildParagraph(
                context,
                'By accessing or using the SyncFit application ("App"), you agree to be bound by these Terms of Use and all applicable laws and regulations. If you do not agree with any of these terms, you are prohibited from using the App.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Use License'),
              _buildParagraph(
                context,
                'Permission is granted to use the App for personal, non-commercial use only. This license shall automatically terminate if you violate any of these restrictions and may be terminated by SyncFit at any time.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'User Accounts'),
              _buildParagraph(
                context,
                'To use certain features of the App, you must register for an account. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Fitness and Health Disclaimer'),
              _buildParagraph(
                context,
                'SyncFit is designed for fitness tracking and general wellness purposes only. The App is not intended to diagnose, treat, cure, or prevent any disease or health condition. Always consult with a healthcare professional before starting any fitness program.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Content and User Submissions'),
              _buildParagraph(
                context,
                'Users may submit content, including profile images and fitness data. You retain ownership of content you submit, but grant SyncFit a worldwide, royalty-free license to use, reproduce, and display such content in connection with the App.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Limitation of Liability'),
              _buildParagraph(
                context,
                'SyncFit shall not be liable for any direct, indirect, incidental, consequential, or special damages arising out of or in any way connected with your use of the App.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Modifications'),
              _buildParagraph(
                context,
                'SyncFit reserves the right to modify or replace these Terms of Use at any time. It is your responsibility to check these Terms periodically for changes.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Governing Law'),
              _buildParagraph(
                context,
                'These Terms shall be governed by and construed in accordance with the laws of the United States, without regard to its conflict of law provisions.',
              ),
              const SizedBox(height: 16),
              _buildSectionTitle(context, 'Contact Us'),
              _buildParagraph(
                context,
                'If you have any questions about these Terms, please contact us at terms@syncfit.example.com.',
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
}
