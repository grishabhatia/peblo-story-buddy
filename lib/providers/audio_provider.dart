import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum AudioState { idle, loading, playing, completed, error }

class AudioProvider extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  AudioState _state = AudioState.idle;
  String _errorMessage = '';

  AudioState get state => _state;
  String get errorMessage => _errorMessage;

  AudioProvider() {
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    _flutterTts.setCompletionHandler(() {
      _state = AudioState.completed;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _state = AudioState.error;
      _errorMessage = msg ?? 'Something went wrong with the story!';
      notifyListeners();
    });
  }

  Future<void> speakStory(String story) async {
    try {
      _state = AudioState.loading;
      notifyListeners();

      await Future.delayed(Duration(milliseconds: 500));

      int result = await _flutterTts.speak(story);

      if (result == 1) {
        _state = AudioState.playing;
        notifyListeners();
      } else {
        throw Exception('TTS failed to start');
      }
    } catch (e) {
      _state = AudioState.error;
      _errorMessage = 'Oops! Having trouble speaking. Want to try again?';
      notifyListeners();
    }
  }

  Future<void> stopStory() async {
    await _flutterTts.stop();
    _state = AudioState.idle;
    notifyListeners();
  }

  void resetState() {
    _state = AudioState.idle;
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}