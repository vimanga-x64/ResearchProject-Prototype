import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static _MyAppState? of(BuildContext context) => 
      context.findAncestorStateOfType<_MyAppState>();

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get currentThemeMode => _themeMode;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode') ?? false;
      setState(() {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      });
    } catch (e) {
      print('Error loading theme: $e');
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDark);
      setState(() {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      });
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Tutor Application',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        colorScheme: ColorScheme.light(
          primary: Colors.blue.shade800,
          secondary: Colors.blue.shade600,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.blue.shade800),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue.shade300,
          secondary: Colors.blue.shade200,
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(color: Colors.blue.shade300),
        ),
      ),
      themeMode: _themeMode,
      home: LoginScreen(),
    );
  }
}