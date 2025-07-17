// widgets/avatar_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
        assetPath = 'assets/animations/happy_avatar.json';
        break;
      case "sad":
        assetPath = 'assets/animations/sad_avatar.json';
        break;
      default:
        assetPath = 'assets/animations/neutral_avatar.json';
    }

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200], // Optional: background color
        ),
        child: Lottie.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain, // Adjust fit as necessary for your animation files
        repeat: true, // Set to true if you want the animation to loop
        // Add other Lottie properties like animate, frameRate, etc., if needed
      ),
      ),
    );
  }
}