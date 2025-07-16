// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/avatar_widget.dart';
import '../utils/avatar_logic.dart';
import '../models/lesson_model.dart';
import 'package:app_prototype/widgets/lesson_card.dart' hide LessonScreen;
import 'lesson_screen.dart';
import 'login_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _totalScore = 75; // Persistent total score starting at 75
  String emotion = "neutral";
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    emotion = getAvatarEmotion(_totalScore);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Load any additional user data here if needed
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout(BuildContext context) {
    FirebaseAuth.instance.signOut().then((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    MyApp.of(context)?.toggleTheme(_isDarkMode);
  }

  void _navigateToLesson(String subject) async {
  final lesson = Lesson.createSampleLesson(subject);
  
  final lessonScore = await Navigator.push<int>(
    context,
    MaterialPageRoute(
      builder: (_) => LessonScreen(lesson: lesson), // Now unambiguous
    ),
  );

  if (lessonScore != null) {
    setState(() {
      _totalScore += lessonScore;
      emotion = getAvatarEmotion(_totalScore);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Custom Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/background.png',
              fit: BoxFit.cover,
              color: _isDarkMode 
                  ? Colors.black.withOpacity(0.7)
                  : Colors.white.withOpacity(0.5),
              colorBlendMode: BlendMode.overlay,
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Avatar and Greeting Section
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: AvatarWidget(
                            emotion: emotion,
                            size: 200,
                          ),
                        ),
                        SizedBox(height: 20),
                        
                        // Greeting
                        Column(
                          children: [
                            Text(
                              'Welcome back,',
                              style: TextStyle(
                                fontSize: 18,
                                color: _isDarkMode 
                                    ? Colors.white.withOpacity(0.9)
                                    : Colors.blue.shade900.withOpacity(0.8),
                              ),
                            ),
                            Text(
                              _userData?['displayName'] ??
                              FirebaseAuth.instance.currentUser?.displayName ?? 
                              'Learner',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: _isDarkMode ? Colors.white : Colors.blue.shade900,
                              ),
                            ),
                             Text(
                            'Logged in as: ${_userData?['email'] ?? FirebaseAuth.instance.currentUser?.email ?? ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                               ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Total Score: $_totalScore',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _isDarkMode ? Colors.white : Colors.blue.shade800,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        
                        // Score Indicator
                        _buildScoreIndicator(),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  
                  // Lessons Section
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Your Lessons',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _isDarkMode ? Colors.white : Colors.blue.shade900,
                          ),
                        ),
                        SizedBox(height: 20),
                        GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          children: [
                            _buildLessonCard('Math', Icons.calculate, Colors.orange),
                            _buildLessonCard('Science', Icons.science, Colors.green),
                            _buildLessonCard('History', Icons.history, Colors.purple),
                            _buildLessonCard('English', Icons.menu_book, Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode,
                    color: _isDarkMode ? Colors.white : Colors.blue.shade900),
                onPressed: _toggleTheme,
                tooltip: 'Toggle theme',
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.logout, 
                      color: _isDarkMode ? Colors.white : Colors.blue.shade900),
                  onPressed: () => _logout(context),
                  tooltip: 'Logout',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator() {
    Color scoreColor;
    if (_totalScore >= 80) {
      scoreColor = Colors.green;
    } else if (_totalScore >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: scoreColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _totalScore >= 80
                ? Icons.emoji_emotions
                : _totalScore >= 50
                    ? Icons.emoji_emotions_outlined
                    : Icons.sentiment_dissatisfied,
            color: scoreColor,
          ),
          SizedBox(width: 8),
          Text(
            'Current Mood',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: scoreColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard(String subject, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () => _navigateToLesson(subject),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              SizedBox(height: 10),
              Text(
                subject,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.blue.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}