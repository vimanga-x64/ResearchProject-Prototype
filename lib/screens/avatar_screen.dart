// screens/avatar_screen.dart
import 'package:flutter/material.dart';
import '../widgets/avatar_widget.dart';
import '../utils/avatar_logic.dart';

class AvatarScreen extends StatefulWidget {
  final int currentScore;

  AvatarScreen({required this.currentScore});

  @override
  _AvatarScreenState createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  late String _emotion;

  @override
  void initState() {
    super.initState();
    _emotion = getAvatarEmotion(widget.currentScore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Avatar')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue.shade200, Colors.blue.shade400],
                ),
              ),
              child: AvatarWidget(emotion: _emotion, size: 200),
            ),
            SizedBox(height: 20),
            Text(
              'Current Mood: ${_emotion.toUpperCase()}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Score: ${widget.currentScore}',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}