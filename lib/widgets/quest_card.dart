import 'package:flutter/material.dart';
import '../models/quest_model.dart';
import '../screens/quest_screen.dart';

class QuestCard extends StatelessWidget {
  final QuestModel quest;

  const QuestCard({super.key, required this.quest});

  IconData _getIconForQuestType(String type) {
    switch (type) {
      case 'memory':
        return Icons.psychology_outlined;
      case 'logic':
        return Icons.extension_outlined;
      case 'math':
        return Icons.calculate_outlined;
      case 'word':
        return Icons.abc_outlined;
      case 'pattern':
        return Icons.apps_outlined;
      case 'color':
        return Icons.palette_outlined;
      default:
        return Icons.help_outline;
    }
  }

  Color _getColorForQuest(String id) {
    final colors = [
      Colors.blue.shade200,
      Colors.green.shade200,
      Colors.orange.shade200,
      Colors.purple.shade200,
      Colors.red.shade200,
      Colors.teal.shade200,
      Colors.amber.shade200,
      Colors.cyan.shade200,
    ];
    // Use the hash code of the ID to get a consistent color for each quest
    return colors[id.hashCode % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _getColorForQuest(quest.id),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: Icon(
          _getIconForQuestType(quest.type),
          size: 40,
          color: Colors.black54,
        ),
        title: Text(
          quest.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        trailing:
            quest.completed
                ? const Icon(Icons.check_circle, color: Colors.green, size: 30)
                : null,
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => QuestScreen(quest: quest)),
            ),
      ),
    );
  }
}
