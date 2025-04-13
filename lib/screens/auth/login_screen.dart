// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../common/color_extension.dart';
import '../../routes/routes.dart';
import '../../themes/theme.dart';
import '../../services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final SupabaseService _supabaseService = SupabaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
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
                          color: TColor.black,
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
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(color: TColor.gray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.gray),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.gray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.primaryColor1),
                    ),
                    prefixIcon: Icon(Icons.email_outlined, color: TColor.gray),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: TColor.gray),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.gray),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.gray),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: TColor.primaryColor1),
                    ),
                    prefixIcon: Icon(Icons.lock_outline, color: TColor.gray),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: TColor.gray,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Remember Me & Forgot Password
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                          activeColor: TColor.primaryColor1,
                        ),
                        Text(
                          "Remember me",
                          style: TextStyle(color: TColor.gray),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle forgot password
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
                const SizedBox(height: 200),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          await _supabaseService.signIn(
                            _emailController.text,
                            _passwordController.text,
                          );
                          context.go(AppRoutes.home);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text("Login failed: ${e.toString()}")),
                          );
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(Icons.login, color: TColor.white),
                    label: _isLoading
                        ? const Text("Logging in...")
                        : const Text("Login"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primaryColor1,
                      foregroundColor: TColor.white,
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
                      child: Divider(color: TColor.lightGray),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Or",
                        style: TextStyle(color: TColor.gray),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: TColor.lightGray),
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
                        style: TextStyle(color: TColor.gray),
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
