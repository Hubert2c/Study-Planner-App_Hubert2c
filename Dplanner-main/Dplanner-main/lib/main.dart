import 'package:flutter/material.dart';
import 'package:dplanner/screens/HomeScreen.dart';
import 'package:dplanner/screens/CalendarScreen.dart';
import 'package:dplanner/screens/SettingsScreen.dart';
import 'package:dplanner/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service with better error handling
  try {
    await NotificationService.initialize();
    print('Notification service initialized successfully');
  } catch (e) {
    print('Failed to initialize notification service: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildDarkTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      primaryColor: Colors.orange,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.orange,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(221, 0, 0, 0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      scaffoldBackgroundColor: Colors.black87,
      bottomAppBarTheme: const BottomAppBarTheme(
        color: Colors.black87,
        elevation: 8,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color.fromARGB(255, 242, 137, 1),
        foregroundColor: Colors.white,
      ),
    );
  }
}