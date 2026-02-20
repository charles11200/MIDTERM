import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:hive_flutter/hive_flutter.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final tasksBox = Hive.box('tasks');

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
                tasksBox.add({
                  'title': text,
                  'isDone': false,
                  'createdAt': DateTime.now().toIso8601String(),
                });
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  void _editTask(int index, Map task) {
    final controller = TextEditingController(text: task['title']);
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
                final updatedTask = Map.from(task);
                updatedTask['title'] = text;
                tasksBox.putAt(index, updatedTask);
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
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No tasks yet. Add one!'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final task = box.getAt(index) as Map;
              final isDone = task['isDone'] as bool;

              return CupertinoListTile(
                title: Text(
                  task['title'],
                  style: TextStyle(
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? CupertinoColors.systemGrey : null,
                  ),
                ),
                leading: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    final updatedTask = Map.from(task);
                    updatedTask['isDone'] = !isDone;
                    tasksBox.putAt(index, updatedTask);
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
                      onPressed: () => tasksBox.deleteAt(index),
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
