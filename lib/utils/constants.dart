// utils/constants.dart
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Colors.blue;
  static const secondary = Colors.purple;
  static const success = Colors.green;
  static const danger = Colors.red;
  static const warning = Colors.orange;
}

class AppTextStyles {
  static TextStyle headline(BuildContext context) => 
      Theme.of(context).textTheme.titleLarge!.copyWith(
        fontWeight: FontWeight.bold,
      );
  
  static TextStyle body(BuildContext context) => 
      Theme.of(context).textTheme.bodyLarge!;
}

class AppPadding {
  static const horizontal = EdgeInsets.symmetric(horizontal: 16);
  static const all = EdgeInsets.all(16);
}