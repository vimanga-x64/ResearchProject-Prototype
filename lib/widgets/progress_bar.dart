// widgets/progress_bar.dart
import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;
  final double height;

  const ProgressBar({
    required this.progress,
    this.color,
    this.height = 8.0,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: Colors.grey[200],
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: MediaQuery.of(context).size.width * progress,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(height / 2),
            color: color ?? Theme.of(context).primaryColor,
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade700],
            ),
          ),
        ),
      ),
    );
  }
}