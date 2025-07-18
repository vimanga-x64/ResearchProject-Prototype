// widgets/avatar_widget.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AvatarWidget extends StatelessWidget {
  final String emotion;
  final double size;
  final Color borderColor;
  final double borderWidth;

  const AvatarWidget({
    required this.emotion,
    this.size = 220,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
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

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
          ),
          // Lottie animation with proper constraints
          SizedBox(
            width: size - borderWidth * 2,
            height: size - borderWidth * 2,
            child: ClipOval(
              child: OverflowBox(
                maxWidth: size * 1.2, // Allows slight overflow if needed
                maxHeight: size * 1.2,
                alignment: Alignment.center,
                child: Lottie.asset(
                  assetPath,
                  fit: BoxFit.cover,
                  repeat: true,
                  alignment: Alignment.center,
                  frameBuilder: (context, child, frame) {
                    return Center(child: child);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}