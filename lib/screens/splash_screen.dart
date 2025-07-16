// screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../widgets/avatar_widget.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final String userName;
  final int initialScore;

  const SplashScreen({
    required this.userName,
    required this.initialScore,
    Key? key,
  }) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<String> _messages;
  int _currentTextIndex = 0;

  @override
  void initState() {
    super.initState();
    
    // Initialize messages here where we can access widget properties
    _messages = [
      "Hello ${widget.userName}!",
      "You start off with a score of ${widget.initialScore}",
      "Your avatar begins neutral:",
      "If you get a score of 80 or more, you will see a happy avatar :)",
      "If you get a score of 50 or below, your avatar will frown :(",
    ];

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    ));

    _playAnimations();
  }


  void _playAnimations() async {
    for (int i = 0; i < _messages.length; i++) {
      setState(() => _currentTextIndex = i);
      _controller.reset();
      await _controller.forward();
      await Future.delayed(Duration(milliseconds: 800));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedText(String text) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentAvatar() {
    if (_currentTextIndex < 2) return SizedBox.shrink();
    
    String emotion;
    if (_currentTextIndex == 2) emotion = "neutral";
    else if (_currentTextIndex == 3) emotion = "happy";
    else emotion = "sad";

    return ScaleTransition(
      scale: Tween<double>(begin: 0.5, end: 1).animate(_controller),
      child: AvatarWidget(emotion: emotion, size: 150),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedText(_messages[_currentTextIndex]),
              SizedBox(height: 30),
              _buildCurrentAvatar(),
              if (_currentTextIndex == _messages.length - 1) ...[
                SizedBox(height: 40),
                ScaleTransition(
                  scale: Tween<double>(begin: 0, end: 1).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.elasticOut,
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Continue to Lessons',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}