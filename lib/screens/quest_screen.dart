import 'package:flutter/material.dart';
import 'package:mini_mind_quest/games/color_sequence_game.dart';
import 'package:mini_mind_quest/games/logic_maze_game.dart';
import 'package:mini_mind_quest/games/math_puzzles_game.dart';
import 'package:mini_mind_quest/games/memory_match_game.dart';
import 'package:mini_mind_quest/games/pattern_recognition_game.dart';
import 'package:mini_mind_quest/games/word_hunt_game.dart';
import 'package:mini_mind_quest/helpers/adHelper.dart';
import 'package:mini_mind_quest/models/quest_model.dart';
import 'package:mini_mind_quest/providers/quest_provider.dart';
import 'package:mini_mind_quest/screens/home_screen.dart';
import 'package:mini_mind_quest/widgets/ad_bar_widget.dart';
import 'package:mini_mind_quest/widgets/top_app_bar_widget.dart';
import 'package:provider/provider.dart';

class QuestScreen extends StatelessWidget {
  final QuestModel quest;

  const QuestScreen({super.key, required this.quest});

  void _onQuestCompleted(BuildContext context) {
    final questProvider = Provider.of<QuestProvider>(context, listen: false);
    questProvider.markCompleted(quest.id);
    AdHelper().showInterstitialAd();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  Widget _buildGameWidget(BuildContext context) {
    switch (quest.type) {
      case 'memory':
        return MemoryMatchGame(onCompleted: () => _onQuestCompleted(context));
      case 'logic':
        return LogicMazeGame(onCompleted: () => _onQuestCompleted(context));
      case 'color':
        return ColorSequenceGame(onCompleted: () => _onQuestCompleted(context));
      case 'word':
        return WordHuntGame(onCompleted: () => _onQuestCompleted(context));
      // You can add other game types here in the future
      case 'math':
        return MathPuzzlesGame(onCompleted: () => _onQuestCompleted(context));
      case 'pattern':
        return PatternRecognitionGame(
          onCompleted: () => _onQuestCompleted(context),
        );
      // case 'sound':
      //   return SoundSafariGame(onCompleted: () => _onQuestCompleted(context));
      default:
        // Placeholder for other games
        return Center(
          child: ElevatedButton(
            child: const Text('Complete Quest'),
            onPressed: () => _onQuestCompleted(context),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(title: quest.title),
      body: _buildGameWidget(context),
      bottomNavigationBar: AdBarWidget(),
    );
  }
}
