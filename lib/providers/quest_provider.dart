import 'package:flutter/material.dart';
import '../models/quest_model.dart';

class QuestProvider extends ChangeNotifier {
  List<QuestModel> _quests = [];

  List<QuestModel> get quests => _quests;

  Future<void> loadQuests() async {
    _quests = [
      QuestModel(id: '1', title: 'Memory Match', type: 'memory'),
      QuestModel(id: '2', title: 'Math Puzzles', type: 'math'),
      QuestModel(id: '3', title: 'Word Hunt', type: 'word'),
      QuestModel(id: '4', title: 'Pattern Recognition', type: 'pattern'),
      QuestModel(id: '5', title: 'Color Sequence', type: 'color'),
      //QuestModel(id: '6', title: 'Color Catch', type: 'colour_catch'),
      //QuestModel(id: '7', title: 'Logic Maze', type: 'logic'),
      QuestModel(id: '8', title: 'Shape Snap', type: 'shape_snap'),
    ];
    notifyListeners();
  }

  void markCompleted(String id) {
    final quest = _quests.firstWhere((q) => q.id == id);
    quest.completed = true;
    notifyListeners();
  }
}
