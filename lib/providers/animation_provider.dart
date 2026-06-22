import 'package:flutter/material.dart';

class AnimationProvider extends ChangeNotifier {
  bool _isShaking = false;
  bool _isCelebrating = false;

  bool get isShaking => _isShaking;
  bool get isCelebrating => _isCelebrating;

  void triggerShake() {
    _isShaking = true;
    notifyListeners();

    Future.delayed(Duration(milliseconds: 500), () {
      _isShaking = false;
      notifyListeners();
    });
  }

  void triggerCelebration() {
    _isCelebrating = true;
    notifyListeners();
  }

  void resetCelebration() {
    _isCelebrating = false;
    notifyListeners();
  }
}