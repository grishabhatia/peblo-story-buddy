import 'package:flutter/material.dart';
import '../models/quiz_model.dart';

enum QuizState { hidden, showing, correct, wrong, success }

class QuizProvider extends ChangeNotifier {
  QuizModel? _quiz;
  QuizState _state = QuizState.hidden;
  String? _selectedAnswer;
  int _attempts = 0;

  QuizModel? get quiz => _quiz;
  QuizState get state => _state;
  String? get selectedAnswer => _selectedAnswer;
  int get attempts => _attempts;

  void loadQuiz(Map<String, dynamic> jsonData) {
    try {
      _quiz = QuizModel.fromJson(jsonData);
      if (_quiz!.isValid()) {
        _state = QuizState.showing;
        _attempts = 0;
        _selectedAnswer = null;
        notifyListeners();
      } else {
        throw Exception('Invalid quiz data');
      }
    } catch (e) {
      _quiz = QuizModel(
        question: 'What colour was Pip the Robot\'s lost gear?',
        options: ['Red', 'Green', 'Blue', 'Yellow'],
        answer: 'Blue',
      );
      _state = QuizState.showing;
      notifyListeners();
    }
  }

  void answerQuestion(String answer) {
    if (_state == QuizState.success) return;

    _selectedAnswer = answer;

    if (answer == _quiz!.answer) {
      _state = QuizState.success;
      notifyListeners();
    } else {
      _state = QuizState.wrong;
      _attempts++;
      notifyListeners();

      Future.delayed(Duration(milliseconds: 800), () {
        if (_state == QuizState.wrong) {
          _state = QuizState.showing;
          _selectedAnswer = null;
          notifyListeners();
        }
      });
    }
  }

  void resetQuiz() {
    _state = QuizState.hidden;
    _selectedAnswer = null;
    _attempts = 0;
    notifyListeners();
  }
}