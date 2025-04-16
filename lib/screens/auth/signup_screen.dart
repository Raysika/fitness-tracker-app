// lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/color_extension.dart';
import '../../routes/routes.dart';
import '../../services/supabase_service.dart';
import '../../screens/legal/privacy_policy.dart';
import '../../screens/legal/terms_of_use.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Set signing up flag for onboarding flow
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_signing_up', true);

        await _supabaseService.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _firstNameController.text.trim(),
          _lastNameController.text.trim(),
        );

        if (mounted) {
          // Navigate to email verification screen or directly to complete profile
          context.go(AppRoutes.completeProfile);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Signup failed: ${e.toString()}")),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept the Terms and Conditions"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.backgroundColor(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Centered header
                Column(
                  children: [
                    Text(
                      "Hey there,",
                      style: TextStyle(
                        fontSize: 16,
                        color: TColor.grayColor(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Create an Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: TColor.textColor(context),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // First Name Field with icon
                TextField(
                  controller: _firstNameController,
                  style: TextStyle(color: TColor.textColor(context)),
                  decoration: InputDecoration(
                    hintText: "First Name",
                    hintStyle: TextStyle(
                      color: TColor.grayColor(context).withOpacity(0.6),
                      fontWeight: FontWeight.normal,
                    ),
                    prefixIcon: Icon(Icons.person_outline,
                        color: TColor.grayColor(context)),
                    filled: true,
                    fillColor: TColor.whiteColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.grayColor(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.grayColor(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.primaryColor1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Last Name Field with icon
                TextField(
                  controller: _lastNameController,
                  style: TextStyle(color: TColor.textColor(context)),
                  decoration: InputDecoration(
                    hintText: "Last Name",
                    hintStyle: TextStyle(
                      color: TColor.grayColor(context).withOpacity(0.6),
                      fontWeight: FontWeight.normal,
                    ),
                    prefixIcon: Icon(Icons.person_outline,
                        color: TColor.grayColor(context)),
                    filled: true,
                    fillColor: TColor.whiteColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.grayColor(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.grayColor(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.primaryColor1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Email Field with icon
                TextField(
                  controller: _emailController,
                  style: TextStyle(color: TColor.textColor(context)),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: TextStyle(
                      color: TColor.grayColor(context).withOpacity(0.6),
                      fontWeight: FontWeight.normal,
                    ),
                    prefixIcon: Icon(Icons.email_outlined,
                        color: TColor.grayColor(context)),
                    filled: true,
                    fillColor: TColor.whiteColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.grayColor(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.grayColor(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.primaryColor1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field with icon
                TextField(
                  controller: _passwordController,
                  style: TextStyle(color: TColor.textColor(context)),
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(
                      color: TColor.grayColor(context).withOpacity(0.6),
                      fontWeight: FontWeight.normal,
                    ),
                    prefixIcon: Icon(Icons.lock_outline,
                        color: TColor.grayColor(context)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: TColor.grayColor(context),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: TColor.whiteColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.grayColor(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.grayColor(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.primaryColor1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Password Field with icon
                TextField(
                  controller: _confirmPasswordController,
                  style: TextStyle(color: TColor.textColor(context)),
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: "Confirm Password",
                    hintStyle: TextStyle(
                      color: TColor.grayColor(context).withOpacity(0.6),
                      fontWeight: FontWeight.normal,
                    ),
                    prefixIcon: Icon(Icons.lock_outline,
                        color: TColor.grayColor(context)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: TColor.grayColor(context),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: TColor.whiteColor(context),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.grayColor(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.grayColor(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.primaryColor1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Terms Checkbox
                Row(
                  children: [
                    Theme(
                      data: ThemeData(
                        checkboxTheme: CheckboxThemeData(
                          fillColor: MaterialStateProperty.resolveWith<Color>(
                            (states) {
                              if (states.contains(MaterialState.selected)) {
                                return TColor.primaryColor1;
                              }
                              return TColor.whiteColor(context);
                            },
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          side: BorderSide(color: TColor.grayColor(context)),
                        ),
                      ),
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          // This ensures tapping anywhere in the text works for accessibility
                          setState(() {
                            _acceptTerms = !_acceptTerms;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "By continuing you accept our ",
                            style: TextStyle(color: TColor.grayColor(context)),
                            children: [
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PrivacyPolicyScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Privacy Policy",
                                    style: TextStyle(
                                      color: TColor.primaryColor1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              TextSpan(text: " and "),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const TermsOfUseScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Terms of Use",
                                    style: TextStyle(
                                      color: TColor.primaryColor1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primaryColor1,
                      foregroundColor: TColor.white,
                      disabledBackgroundColor:
                          TColor.primaryColor1.withOpacity(0.7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Register",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // Already have an account link
                GestureDetector(
                  onTap: () {
                    context.go(AppRoutes.login);
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "Already have an account? ",
                      style: TextStyle(color: TColor.grayColor(context)),
                      children: [
                        TextSpan(
                          text: "Login",
                          style: TextStyle(
                            color: TColor.primaryColor1,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
