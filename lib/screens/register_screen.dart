// screens/register_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../widgets/gradient_background.dart'; // Import the GradientBackground widget

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isDarkMode = false;
  double _contentOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentTheme();
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _contentOpacity = 1.0;
        });
      }
    });
  }

   Future<void> _loadCurrentTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

 @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update to get theme from MyApp
    final appState = MyApp.of(context);
    if (appState != null) {
      setState(() {
        _isDarkMode = appState.currentThemeMode == ThemeMode.dark;
      });
    }
  }
  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _authService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
      );

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SplashScreen(
             userName: user.displayName ?? _nameController.text.trim(),
             initialScore: 75,
          )),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else {
        message = 'Registration failed. Please try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An unexpected error occurred.')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground( // Wrap the existing Stack with GradientBackground
        child: Stack(
          children: [
            // Solid background - REMOVE THIS as GradientBackground will handle the background
            // Container(
            //   width: double.infinity,
            //   height: double.infinity,
            //   color: _isDarkMode ? Colors.black : Colors.white,
            // ),

            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: AnimatedOpacity(
                  opacity: _contentOpacity,
                  duration: Duration(milliseconds: 500),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/register.json',
                          height: 200,
                          width: 200,
                          fit: BoxFit.contain,
                          repeat: true,
                        ),

                        Text(
                          'Create Your Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Name Field
                        _buildTextField(
                          controller: _nameController,
                          label: 'Display Name',
                          icon: Icons.person,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter your name' : null,
                        ),
                        const SizedBox(height: 16),

                        // Email Field
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter email' : null,
                        ),
                        const SizedBox(height: 16),

                        // Password Field
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock,
                          obscureText: true,
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter password' : null,
                        ),
                        const SizedBox(height: 16),

                        // Confirm Password Field
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          icon: Icons.lock,
                          obscureText: true,
                          validator: (value) => value!.isEmpty
                              ? 'Please confirm password'
                              : (value != _passwordController.text
                                  ? 'Passwords do not match'
                                  : null),
                        ),
                        const SizedBox(height: 30),

                        // Register Button
                        _buildActionButton(
                          onPressed: _register,
                          label: 'Register',
                          isLoading: _isLoading,
                          isPrimary: true,
                        ),
                        const SizedBox(height: 20),

                        // Login Link
                        TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        ), // This was the missing closing parenthesis
                        child: Text(
                          'Already have an account? Log In',
                          style: TextStyle(
                            color: _isDarkMode ? Colors.white : Colors.blue.shade900,
                          ),
                        ),
                      ),                      // Spacer to fill remaining space
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black54),
        prefixIcon: Icon(icon, color: _isDarkMode ? Colors.white70 : Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _isDarkMode ? Colors.white54 : Colors.grey.shade400),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: _isDarkMode ? Colors.white : Colors.blue.shade700),
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: _isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String label,
    required bool isLoading,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary
              ? (_isDarkMode ? Colors.blue.shade700 : Colors.blue.shade600)
              : Colors.transparent,
          foregroundColor: isPrimary ? Colors.white : (_isDarkMode ? Colors.white : Colors.blue.shade700),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: _isDarkMode ? Colors.white54 : Colors.blue.shade700, width: 1),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}