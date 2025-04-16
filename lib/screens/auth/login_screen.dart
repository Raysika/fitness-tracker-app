// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/color_extension.dart';
import '../../routes/routes.dart';
import '../../themes/theme.dart';
import '../../services/supabase_service.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  // Use same keys as SupabaseService
  static const String _rememberMeKey = SupabaseService.rememberMeKey;
  static const String _savedEmailKey = SupabaseService.savedEmailKey;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final rememberMeData = await _supabaseService.getRememberMeData();
    final rememberMe = rememberMeData['rememberMe'];
    final savedEmail = rememberMeData['email'];

    print(
        'Loading saved credentials - Remember me: $rememberMe, Email: $savedEmail');

    // Set state even if remember me is false, to ensure we have clean state
    setState(() {
      _rememberMe = rememberMe;
      if (rememberMe && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
        print('Restored email: $savedEmail');
      } else {
        // Clear email field if remember me is off
        _emailController.text = '';
        print('No saved credentials to restore');
      }
    });
  }

  Future<void> _saveCredentials() async {
    print(
        'Saving credentials - Remember me: $_rememberMe, Email: ${_emailController.text}');
    await _supabaseService.setRememberMe(
        _rememberMe, _emailController.text.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Save remember me setting and email for next login
        await _supabaseService.setRememberMe(
            _rememberMe, _rememberMe ? _emailController.text.trim() : '');

        // Make sure we're not in signup process
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_signing_up', false);

        await _supabaseService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Double-check remembered state immediately after successful login
        _verifyRememberMeState();

        if (mounted) {
          context.go(AppRoutes.home);
        }
      } catch (e) {
        // Clear password on failure
        _passwordController.clear();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login failed: ${e.toString()}")),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Helper method to verify remember me state is correctly saved
  Future<void> _verifyRememberMeState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRememberMe = prefs.getBool(_rememberMeKey);
    final savedEmail = prefs.getString(_savedEmailKey);
    print(
        '*** VERIFICATION CHECK: Remember Me = $savedRememberMe, Email = $savedEmail');
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Welcome Back Text
                Center(
                  child: Column(
                    children: [
                      Text(
                        "Hey there,",
                        style:
                            AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                          color: TColor.gray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Welcome Back",
                        style: AppTheme.lightTheme.textTheme.headlineMedium
                            ?.copyWith(
                          color: TColor.textColor(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: TColor.textColor(context)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: TColor.grayColor(context)),
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
                    prefixIcon: Icon(Icons.email_outlined,
                        color: TColor.grayColor(context)),
                  ),
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  style: TextStyle(color: TColor.textColor(context)),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: TColor.grayColor(context)),
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
                  ),
                ),

                const SizedBox(height: 20),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Theme(
                          data: ThemeData(
                            checkboxTheme: CheckboxThemeData(
                              fillColor:
                                  MaterialStateProperty.resolveWith<Color>(
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
                              side:
                                  BorderSide(color: TColor.grayColor(context)),
                            ),
                          ),
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });

                              // Save credentials when checkbox is toggled
                              if (_emailController.text.isNotEmpty) {
                                _supabaseService.setRememberMe(
                                    _rememberMe,
                                    _rememberMe
                                        ? _emailController.text.trim()
                                        : '');
                              }
                            },
                          ),
                        ),
                        Text(
                          "Remember me",
                          style: TextStyle(color: TColor.grayColor(context)),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot your password?",
                        style: TextStyle(
                          color: TColor.primaryColor1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _login,
                    icon: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.login, color: TColor.white),
                    label: Text(_isLoading ? "Logging in..." : "Login"),
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
                  ),
                ),

                const SizedBox(height: 30),

                // Or Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: TColor.lightGrayColor(context)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Or",
                        style: TextStyle(color: TColor.grayColor(context)),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: TColor.lightGrayColor(context)),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Don't have account
                Center(
                  child: GestureDetector(
                    onTap: () {
                      context.go(AppRoutes.signup);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account yet? ",
                        style: TextStyle(color: TColor.grayColor(context)),
                        children: [
                          TextSpan(
                            text: "Register",
                            style: TextStyle(
                              color: TColor.primaryColor1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
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
