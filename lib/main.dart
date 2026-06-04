import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const AzureControllerApp());
}

class AzureControllerApp extends StatelessWidget {
  const AzureControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Azure VM Controller',
      debugShowCheckedModeBanner: false, // Removes the red debug banner
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark, // A cool dark mode for cloud monitoring!
        ),
      ),
      home: const HomeScreen(),
    );
  }
}