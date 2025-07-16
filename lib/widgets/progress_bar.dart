// widgets/progress_bar.dart
import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;

  const ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade300,
          color: Colors.blue,
          minHeight: 10,
        ),
        SizedBox(height: 5),
        Align(
          alignment: Alignment.centerRight,
          child: Text('${(progress * 100).round()}% complete'),
        ),
      ],
    );
  }
}