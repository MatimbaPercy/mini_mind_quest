import 'package:flutter/material.dart';
import '../models/quest_model.dart';

class QuestProvider extends ChangeNotifier {
  List<QuestModel> _quests = [];

  List<QuestModel> get quests => _quests;

  Future<void> loadQuests() async {
    _quests = [
      QuestModel(id: '1', title: 'Memory Match', type: 'memory'),
      //QuestModel(id: '2', title: 'Sound Safari', type: 'sound'),
      QuestModel(id: '3', title: 'Logic Maze', type: 'logic'),
      QuestModel(id: '4', title: 'Math Puzzles', type: 'math'),
      QuestModel(id: '5', title: 'Word Hunt', type: 'word'),
      //QuestModel(id: '6', title: 'Visual Riddles', type: 'visual'),
      QuestModel(id: '7', title: 'Pattern Recognition', type: 'pattern'),
      QuestModel(id: '8', title: 'Color Sequence', type: 'color'),
      //QuestModel(id: '9', title: 'Spatial Reasoning', type: 'spatial'),
      //QuestModel(id: '10', title: 'Rhythm Tap', type: 'rhythm'),
    ];
    notifyListeners();
  }

  void markCompleted(String id) {
    final quest = _quests.firstWhere((q) => q.id == id);
    quest.completed = true;
    notifyListeners();
  }
}
