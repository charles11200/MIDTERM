import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/task.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // ✅ Specify the type <Task> to match how it was opened in main.dart
  final Box<Task> tasksBox = Hive.box<Task>('tasks');

  void _addTask() {
    final controller = TextEditingController();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Add New Task'),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'What needs to be done?',
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Add'),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                // ✅ Use Task model instead of Map
                final newTask = Task(
                  title: text,
                  isDone: false,
                  createdAt: DateTime.now(),
                );
                tasksBox.add(newTask);
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _editTask(int index, Task task) {
    final controller = TextEditingController(text: task.title);
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Edit Task'),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(
            controller: controller,
            placeholder: 'Edit task',
            autofocus: true,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Save'),
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                // ✅ Update using Task model properties
                task.title = text;
                task.save(); // HiveObject allows .save()
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('My Tasks'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _addTask,
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: ValueListenableBuilder(
        valueListenable: tasksBox.listenable(),
        builder: (context, Box<Task> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No tasks yet. Add one!'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final task = box.getAt(index)!;
              final isDone = task.isDone;

              return CupertinoListTile(
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? CupertinoColors.systemGrey : null,
                  ),
                ),
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    task.isDone = !isDone;
                    task.save();
                  },
                  child: Icon(
                    isDone ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                    color: isDone ? CupertinoColors.activeGreen : CupertinoColors.systemGrey,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => _editTask(index, task),
                      child: const Icon(CupertinoIcons.pencil, size: 20),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => task.delete(),
                      child: const Icon(CupertinoIcons.delete, color: CupertinoColors.destructiveRed, size: 20),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
