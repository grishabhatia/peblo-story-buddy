import 'package:flutter/material.dart';
import 'screens/story_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Peblo Story Buddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: Colors.blue[700],
        colorScheme: ColorScheme.light(
          primary: Colors.blue[700]!,
          secondary: Colors.purple[500]!,
        ),
      ),
      home: const StoryScreen(),
    );
  }
}