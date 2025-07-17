import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final bool reverse;

  const GradientBackground({
    required this.child,
    this.reverse = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? reverse
                  ? [Colors.black, Colors.grey.shade900] // Dark mode reversed (can be adjusted)
                  : [Colors.grey.shade900, Colors.black] // Dark mode (can be adjusted)
              : reverse
                  ? [Colors.blue.shade700, Colors.white] // Light mode reversed: darker blue to white
                  : [Colors.white, Colors.blue.shade800], // Light mode: white top, darker blue bottom
          stops: const [0.5, 1.0], // This makes the top half solid white (0.0 to 0.5) and the gradient in the bottom half (0.5 to 1.0)
        ),
      ),
      child: child,
    );
  }
}