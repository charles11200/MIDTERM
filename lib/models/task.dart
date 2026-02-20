import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 5)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isDone;

  @HiveField(2)
  DateTime createdAt;

  Task({
    required this.title,
    this.isDone = false,
    required this.createdAt,
  });
}
