// widgets/avatar_widget.dart
import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String emotion;
  final double size;

  const AvatarWidget({
    required this.emotion,
    this.size = 100,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imagePath;
    switch (emotion) {
      case "happy":
        imagePath = 'assets/avatar_happy.png';
        break;
      case "sad":
        imagePath = 'assets/avatar_sad.png';
        break;
      default:
        imagePath = 'assets/avatar_neutral.png';
    }

    return ClipOval(
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.cover, 
      ),
    );
  }
}