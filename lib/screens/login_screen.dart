// screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'register_screen.dart';
import 'splash_screen.dart';
import 'package:lottie/lottie.dart';
import '../main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/gradient_background.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _firestoreService = FirestoreService();
  bool _isLoading = false;
  bool _isDarkMode = false;
  double _contentOpacity = 0.0; 

   @override
  void initState() {
    super.initState();
    _loadCurrentTheme();
    // Start the fade-in animation after a short delay
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) { // Check if the widget is still in the tree
        setState(() {
          _contentOpacity = 1.0;
        });
      }
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
 

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter an email address and a password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = await _authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (user != null) {
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(
      builder: (_) => HomeScreen( ),
    ),
  );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: Invalid credentials')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

   Future<void> _loadCurrentTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _socialLogin(Future<User?> Function() socialLoginFunction) async {
  setState(() => _isLoading = true);
  try {
    final user = await socialLoginFunction();
    if (user != null) {
    Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => HomeScreen()
      ),
  );
}else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: ${e.toString()}')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
 }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: GradientBackground( // Use Stack to layer background behind content
        child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Lottie.asset(
                    'assets/animations/humans.json', // Your Lottie file path
                    height: 200, // Adjust size as needed
                    width: 200,  // Adjust size as needed
                    fit: BoxFit.contain,
                    repeat: true, // Set to true if you want it to loop
                  ),
                  //const SizedBox(height: 5), // Space between avatar and title

                
                  //SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                 Text(
                    'E-Tutor Avatar Prototype',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _isDarkMode ? Colors.white : Colors.black, // Dynamic color
                    ),
                  ),
                SizedBox(height: 40),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                ),
                SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: 24),
                _buildActionButton(
                  onPressed: _login,
                  label: 'Login',
                  isLoading: _isLoading,
                  isPrimary: true,
                ),
                SizedBox(height: 20),
                Text(
                    'Or continue with', 
                    style: TextStyle(color: _isDarkMode ? Colors.white70 : Colors.black54)
                  ),
                SizedBox(height: 20),

                // Social Login Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialButton(
                      icon: FontAwesomeIcons.google,
                      color: Colors.white,
                      onPressed: () => _socialLogin(_authService.signInWithGoogle),
                    ),
                    SizedBox(width: 20),
                    _buildSocialButton(
                      icon: FontAwesomeIcons.microsoft,
                      color: Colors.white,
                      onPressed: () => _socialLogin(_authService.signInWithMicrosoft),
                    ),
                    SizedBox(width: 20),
                    _buildSocialButton(
                      icon: FontAwesomeIcons.facebook,
                      color: Colors.white,
                      onPressed: () => _socialLogin(_authService.signInWithFacebook),
                    ),
                  ],
                ),

                SizedBox(height: 30),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => RegisterScreen()),
                  ),
                  child: Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(color: _isDarkMode ? Colors.white : Colors.blue.shade900),
                  ),
                ),
              ],
            
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSocialButton({
  required IconData icon,
  required Color color,
  required VoidCallback onPressed,
}) {
  return IconButton(
    icon: FaIcon(icon, size: 24, color: _isDarkMode ? color : Colors.blue.shade700),
    onPressed: onPressed,
    style: IconButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: _isDarkMode ? Colors.white54 : Colors.blue.shade700, 
          width: 1),
      ),
      backgroundColor: _isDarkMode 
          ? Colors.white.withOpacity(0.1) 
          : Colors.blue.shade50,
      padding: EdgeInsets.all(15),
    ),
  );
}

  Widget _buildTextField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool obscureText = false,
}) {
  return TextField(
    controller: controller,
    obscureText: obscureText,
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
          backgroundColor: isPrimary ? (_isDarkMode ? Colors.blue.shade700 : Colors.blue.shade600)  : Colors.transparent,
          foregroundColor: isPrimary ? Colors.white : (_isDarkMode ? Colors.white : Colors.blue.shade700),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: isPrimary
                ? BorderSide.none
                : BorderSide(color: _isDarkMode ? Colors.white54 : Colors.blue.shade700, width: 1),
          ),
          elevation: isPrimary ? 4 : 0,
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