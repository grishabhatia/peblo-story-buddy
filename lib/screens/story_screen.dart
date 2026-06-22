import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/animation_provider.dart';
import '../widgets/buddy_avatar.dart';
import '../widgets/story_card.dart';
import '../widgets/quiz_widget.dart';
import '../widgets/celebration_effect.dart';
import '../utils/constants.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => AnimationProvider()),
      ],
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue[50]!,
                Colors.purple[50]!,
                Colors.pink[50]!,
              ],
            ),
          ),
          child: SafeArea(
            child: Consumer3<AudioProvider, QuizProvider, AnimationProvider>(
              builder: (context, audioProvider, quizProvider, animationProvider, _) {
                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 10),
                          Text(
                            '🌟 Story Buddy',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Listen to a magical story!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 30),
                          BuddyAvatar(
                            isCelebrating: animationProvider.isCelebrating,
                            isListening: audioProvider.state == AudioState.playing,
                          ),
                          SizedBox(height: 30),
                          StoryCard(
                            storyText: AppConstants.storyText,
                            isVisible: true,
                          ),
                          SizedBox(height: 20),
                          _buildReadButton(audioProvider, quizProvider, animationProvider),
                          SizedBox(height: 20),
                          if (quizProvider.state != QuizState.hidden)
                            QuizWidget(
                              quizProvider: quizProvider,
                              animationProvider: animationProvider,
                            ),
                          SizedBox(height: 30),
                          if (audioProvider.state == AudioState.loading)
                            _buildStatusMessage('📚 Preparing the story...', Colors.blue),
                          if (audioProvider.state == AudioState.error)
                            _buildStatusMessage(
                              audioProvider.errorMessage,
                              Colors.red,
                              showRetry: true,
                              onRetry: () {
                                audioProvider.resetState();
                                quizProvider.resetQuiz();
                                animationProvider.resetCelebration();
                              },
                            ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                    if (animationProvider.isCelebrating)
                      CelebrationEffect(isActive: animationProvider.isCelebrating),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadButton(
    AudioProvider audioProvider,
    QuizProvider quizProvider,
    AnimationProvider animationProvider,
  ) {
    bool isPlaying = audioProvider.state == AudioState.playing;
    bool isLoading = audioProvider.state == AudioState.loading;
    bool isCompleted = audioProvider.state == AudioState.completed;

    return GestureDetector(
      onTap: isLoading || isPlaying
          ? null
          : () => _handleReadStory(audioProvider, quizProvider, animationProvider),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPlaying || isCompleted
                ? [Colors.grey[400]!, Colors.grey[500]!]
                : [Colors.blue[400]!, Colors.blue[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Text(
                      isPlaying ? 'Listening...' : 'Read Me a Story 📖',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _handleReadStory(
    AudioProvider audioProvider,
    QuizProvider quizProvider,
    AnimationProvider animationProvider,
  ) {
    quizProvider.resetQuiz();
    animationProvider.resetCelebration();

    audioProvider.speakStory(AppConstants.storyText);

    _checkAudioCompletion(context);
  }

  void _checkAudioCompletion(BuildContext context) async {
    final audioProvider = Provider.of<AudioProvider>(context, listen: false);
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    await Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 500));
      return audioProvider.state != AudioState.completed &&
          audioProvider.state != AudioState.error;
    });

    if (audioProvider.state == AudioState.completed && mounted) {
      quizProvider.loadQuiz(AppConstants.quizJson);
    }
  }

  Widget _buildStatusMessage(String message, Color color,
      {bool showRetry = false, VoidCallback? onRetry}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 14),
            ),
          ),
          if (showRetry && onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text('Retry', style: TextStyle(color: color)),
            ),
        ],
      ),
    );
  }
}