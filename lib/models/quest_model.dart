class QuestModel {
  final String id;
  final String title;
  final String type;
  bool completed;

  QuestModel({
    required this.id,
    required this.title,
    required this.type,
    this.completed = false,
  });
}
