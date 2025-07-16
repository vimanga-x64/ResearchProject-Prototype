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
    String assetPath;
    switch (emotion) {
      case "happy":
        assetPath = 'assets/avatar_happy.png';
        break;
      case "sad":
        assetPath = 'assets/avatar_sad.png';
        break;
      default:
        assetPath = 'assets/avatar_neutral.png';
    }

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200], // Optional: background color
        ),
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover, // Ensures the image fills the circle
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}