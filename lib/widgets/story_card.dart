import 'package:flutter/material.dart';

class StoryCard extends StatelessWidget {
  final String storyText;
  final bool isVisible;

  const StoryCard({
    super.key,
    required this.storyText,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 500),
      child: Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
          border: Border.all(color: Colors.blue[100]!, width: 2),
        ),
        child: Text(
          storyText,
          style: TextStyle(
            fontSize: 18,
            height: 1.6,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}