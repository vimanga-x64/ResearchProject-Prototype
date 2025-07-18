import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoginSplashScreen extends StatefulWidget {
  final Future<void> Function()? initialization;
  final int minimumDuration; // in milliseconds

  const LoginSplashScreen({
    Key? key,
    this.initialization,
    this.minimumDuration = 2500, // Default 2.5 seconds
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<LoginSplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final startTime = DateTime.now();
    
    // Run your initialization tasks
    if (widget.initialization != null) {
      await widget.initialization!();
    }

    final elapsed = DateTime.now().difference(startTime).inMilliseconds;
    final remaining = widget.minimumDuration - elapsed;

    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/wave_animation.json',
              width: 300,
              height: 200,
            ),
            SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Preparing your learning experience...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}