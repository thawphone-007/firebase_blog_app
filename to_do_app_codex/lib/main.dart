import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _taskBoxName = 'tasks';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final taskBox = await Hive.openBox(_taskBoxName);

  runApp(MyApp(taskBox: taskBox));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.taskBox});

  final Box taskBox;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Tasks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: TaskScreen(taskBox: taskBox),
    );
  }
}

class Task {
  Task({
    required this.id,
    required this.title,
    required this.createdAt,
    this.isCompleted = false,
  });

  final String id;
  String title;
  final DateTime createdAt;
  bool isCompleted;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key, required this.taskBox});

  final Box taskBox;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final List<Task> _tasks = [];
  String _newTaskTitle = '';
  int _newTaskFieldVersion = 0;
  String? _newTaskError;

  @override
  void initState() {
    super.initState();
    _tasks.addAll(
      widget.taskBox.values.map(
        (task) => Task.fromMap(Map<dynamic, dynamic>.from(task as Map)),
      ),
    );
  }

  Future<void> _addTask() async {
    final title = _newTaskTitle.trim();
    if (title.isEmpty) {
      setState(() {
        _newTaskError = 'Enter a task title.';
      });
      return;
    }

    final createdAt = DateTime.now();
    final task = Task(
      id: createdAt.microsecondsSinceEpoch.toString(),
      title: title,
      createdAt: createdAt,
    );

    setState(() {
      _tasks.add(task);
      _newTaskTitle = '';
      _newTaskFieldVersion++;
      _newTaskError = null;
    });
    await widget.taskBox.put(task.id, task.toMap());
  }

  Future<void> _editTask(Task task) async {
    final controller = TextEditingController(text: task.title);
    final editedTitle = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit task'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Task title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                Navigator.pop(dialogContext, title);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (editedTitle == null || editedTitle.isEmpty || !mounted) {
      return;
    }

    setState(() {
      task.title = editedTitle;
    });
    await widget.taskBox.put(task.id, task.toMap());
  }

  Future<void> _toggleTask(Task task, bool? isCompleted) async {
    setState(() {
      task.isCompleted = isCompleted ?? false;
    });
    await widget.taskBox.put(task.id, task.toMap());
  }

  Future<void> _deleteTask(Task task) async {
    setState(() {
      _tasks.remove(task);
    });
    await widget.taskBox.delete(task.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: ValueKey(_newTaskFieldVersion),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'What needs to be done?',
                      labelText: 'New task',
                      errorText: _newTaskError,
                    ),
                    onChanged: (value) {
                      _newTaskTitle = value;
                      if (_newTaskError != null) {
                        setState(() {
                          _newTaskError = null;
                        });
                      }
                    },
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.task_alt_outlined, size: 56),
                          SizedBox(height: 12),
                          Text('No tasks yet'),
                          SizedBox(height: 4),
                          Text('Add a task above to get started.'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _tasks.length,
                      itemBuilder: (context, index) {
                        final task = _tasks[index];
                        return Card(
                          child: ListTile(
                            onTap: () => _editTask(task),
                            leading: Checkbox(
                              value: task.isCompleted,
                              onChanged: (value) => _toggleTask(task, value),
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  tooltip: 'Edit task',
                                  onPressed: () => _editTask(task),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Delete task',
                                  onPressed: () => _deleteTask(task),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
