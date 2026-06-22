import 'package:flutter/material.dart';
import '../providers/quiz_provider.dart';
import '../providers/animation_provider.dart';

class QuizWidget extends StatefulWidget {
  final QuizProvider quizProvider;
  final AnimationProvider animationProvider;

  const QuizWidget({
    super.key,
    required this.quizProvider,
    required this.animationProvider,
  });

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(QuizWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quizProvider.state == QuizState.showing &&
        oldWidget.quizProvider.state != QuizState.showing) {
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quizProvider.state == QuizState.hidden) {
      return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.1),
              blurRadius: 30,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.quiz, color: Colors.purple[400]),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.quizProvider.quiz!.question,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ...widget.quizProvider.quiz!.options.map((option) {
              return _buildOption(option);
            }).toList(),
            SizedBox(height: 10),
            if (widget.quizProvider.state == QuizState.success)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 10),
                    Text(
                      ' Amazing! You got it right!',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.quizProvider.state == QuizState.wrong)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.red),
                    SizedBox(width: 10),
                    Text(
                      'Oops! Try again! ',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String option) {
    bool isSelected = widget.quizProvider.selectedAnswer == option;
    bool isCorrect = widget.quizProvider.state == QuizState.success &&
        option == widget.quizProvider.quiz!.answer;
    bool isWrong = widget.quizProvider.state == QuizState.wrong &&
        isSelected &&
        option != widget.quizProvider.quiz!.answer;

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    Color textColor = Colors.grey[800]!;

    if (isCorrect) {
      backgroundColor = Colors.green[50]!;
      borderColor = Colors.green;
      textColor = Colors.green[700]!;
    } else if (isWrong) {
      backgroundColor = Colors.red[50]!;
      borderColor = Colors.red;
      textColor = Colors.red[700]!;
    } else if (isSelected) {
      backgroundColor = Colors.blue[50]!;
      borderColor = Colors.blue;
      textColor = Colors.blue[700]!;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: widget.quizProvider.state == QuizState.success
            ? null
            : () => _handleOptionTap(option),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isWrong ? Colors.red : borderColor,
              width: isWrong || isCorrect ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                  color: isSelected ? Colors.blue : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (isCorrect)
                Icon(Icons.emoji_events, color: Colors.amber),
            ],
          ),
        ),
      ),
    );
  }

  void _handleOptionTap(String option) {
    if (widget.quizProvider.state == QuizState.success) return;

    if (option == widget.quizProvider.quiz!.answer) {
      widget.quizProvider.answerQuestion(option);
      widget.animationProvider.triggerCelebration();
    } else {
      widget.quizProvider.answerQuestion(option);
      widget.animationProvider.triggerShake();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}