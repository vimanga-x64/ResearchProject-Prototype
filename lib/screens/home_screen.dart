// screens/home_screen.dart
import 'package:app_prototype/widgets/lesson_card.dart';
import 'package:flutter/material.dart';
import '../widgets/avatar_widget.dart';
import '../utils/avatar_logic.dart';
import '../services/firestore_service.dart';
import 'login_screen.dart';
import '../main.dart';
import 'lesson_screen.dart';
import '../models/lesson_model.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int score = 75;
  String emotion = "neutral";
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    emotion = getAvatarEmotion(score);
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userModel = await FirestoreService().getUser(user.uid);
      setState(() {
        _userData = userModel != null ? userModel.toMap() : null;
        _isLoading = false;
      });
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    MyApp.of(context)?.toggleTheme(_isDarkMode);
  }

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Theme.of(context).colorScheme.background,
    appBar: AppBar(
      title: Text(_userData != null 
          ? 'Welcome, ${_userData!['displayName'] ?? 'User'}'
          : 'My E-Tutor'),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).primaryColor,
      actions: [
        if (_userData?['photoUrl'] != null)
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundImage: NetworkImage(_userData!['photoUrl']),
              radius: 16,
            ),
          ),
        IconButton(
          icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
          onPressed: _toggleTheme,
          tooltip: 'Toggle theme',
        ),
        IconButton(
          icon: Icon(Icons.logout),
          onPressed: () => _logout(context),
          tooltip: 'Logout',
        ),
      ],
    ),
    body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Learning Companion',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                      ),
                    ),
                    Text('Email: ${_userData?['email'] ?? ''}'),
                    SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _isDarkMode
                                  ? [Colors.blue.shade800, Colors.purple.shade600]
                                  : [Colors.blue.shade200, Colors.blue.shade400],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade100.withOpacity(_isDarkMode ? 0.2 : 0.5),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: AvatarWidget(emotion: emotion, size: 150),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    _buildScoreIndicator(),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Today\'s Lessons',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 20),
                      Expanded(
                        child: GridView.count(
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
  );
}

  void _navigateToLesson(String subject) {
  // You would typically fetch the lesson from Firestore here
  final lesson = Lesson.createSampleLesson(subject);
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => LessonScreen(lesson: lesson),
    ),
  ).then((score) {
    if (score != null) {
      setState(() {
        this.score = score;
        emotion = getAvatarEmotion(score);
      });
    }
  });
}

  Widget _buildScoreIndicator() {
    Color scoreColor;
    if (score >= 80) {
      scoreColor = Colors.green;
    } else if (score >= 50) {
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
            score >= 80
                ? Icons.emoji_emotions
                : score >= 50
                    ? Icons.emoji_emotions_outlined
                    : Icons.sentiment_dissatisfied,
            color: scoreColor,
          ),
          SizedBox(width: 8),
          Text(
            'Score: $score',
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
        onTap: () {
          _navigateToLesson(subject);
        },
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
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}