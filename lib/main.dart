import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'task_details_page.dart';
import 'add_task_page.dart';
import 'add_person_page.dart';
import 'calendar_page.dart';
import 'schedule_page.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(TaskApp());
}

class TaskApp extends StatelessWidget {
  const TaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TaskListPage(),
    );
  }
}

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> _tasks = [];
  List<Person> _persons = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadPersons();
  }

  Future<void> _loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      List<dynamic> taskList = json.decode(tasksString);
      setState(() {
        _tasks = taskList.map((task) => Task.fromJson(task)).toList();
      });
    }
  }

  Future<void> _loadPersons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? personsString = prefs.getString('persons');
    if (personsString != null) {
      List<dynamic> personList = json.decode(personsString);
      setState(() {
        _persons = personList.map((person) => Person.fromJson(person)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'tasks', json.encode(_tasks.map((task) => task.toJson()).toList()));
  }

  Future<void> _savePersons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('persons',
        json.encode(_persons.map((person) => person.toJson()).toList()));
  }

  bool _hasConflict(Task newTask, {Task? existingTask}) {
    for (var task in _tasks) {
      if (task.person.name == newTask.person.name &&
          task != existingTask &&
          task.startDate == newTask.startDate &&
          ((newTask.startTime!.hour < task.endTime!.hour) ||
              (newTask.startTime!.hour == task.endTime!.hour &&
                  newTask.startTime!.minute < task.endTime!.minute)) &&
          ((newTask.endTime!.hour > task.startTime!.hour) ||
              (newTask.endTime!.hour == task.endTime!.hour &&
                  newTask.endTime!.minute > task.endTime!.minute))) {
        return true;
      }
    }
    return false;
  }

  Future<void> _addTask(Task task) async {
    setState(() {
      _tasks.add(task);
    });
    await _saveTasks();
  }

  Future<void> _editTask(int index, Task task) async {
    setState(() {
      _tasks[index] = task;
    });
    await _saveTasks();
  }

  Future<void> _removeTask(int index) async {
    setState(() {
      _tasks.removeAt(index);
    });
    await _saveTasks();
  }

  Future<void> _toggleTaskCompletion(int index) async {
    setState(() {
      _tasks[index].completed = !_tasks[index].completed;
    });
    await _saveTasks();
  }

  void _showTaskDetails(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsPage(
          task: task,
          onTaskUpdated: (updatedTask) {
            setState(() {
              int index = _tasks.indexWhere(
                  (t) => t.title == task.title && t.details == task.details);
              if (index != -1) {
                _tasks[index] = updatedTask;
                _saveTasks();
              }
            });
          },
        ),
      ),
    );
  }

  void _navigateToAddTaskPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskPage(
            persons: _persons, tasks: _tasks, hasConflict: _hasConflict),
      ),
    );

    if (result != null && result is Task) {
      _addTask(result);
    }
  }

  void _navigateToEditTaskPage(BuildContext context, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskPage(
            task: _tasks[index],
            persons: _persons,
            tasks: _tasks,
            hasConflict: _hasConflict),
      ),
    );

    if (result != null && result is Task) {
      _editTask(index, result);
    }
  }

  void _navigateToAddPersonPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddPersonPage(),
      ),
    );

    if (result != null && result is Person) {
      setState(() {
        _persons.add(result);
      });
      await _savePersons();
    }
  }

  void _navigateToCalendarPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CalendarPage(tasks: _tasks),
      ),
    );
  }

  void _navigateToSchedulePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchedulePage(tasks: _tasks),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task App',
          style: TextStyle(
            fontSize: 24,
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontFamily: 'Outfit',
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 234, 237, 221),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Tasks',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    _tasks[index].title,
                    style: TextStyle(
                      decoration: _tasks[index].completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  subtitle: _tasks[index].startDate != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Date: ${DateFormat('yyyy-MM-dd').format(_tasks[index].startDate!)}'),
                            Text(
                                'Start Time: ${_tasks[index].startTime?.format(context) ?? 'Not set'}'),
                            Text(
                                'End Time: ${_tasks[index].endTime?.format(context) ?? 'Not set'}'),
                            Text('Person: ${_tasks[index].person.name}'),
                          ],
                        )
                      : Text('Person: ${_tasks[index].person.name}'),
                  onTap: () => _showTaskDetails(_tasks[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _navigateToEditTaskPage(context, index),
                      ),
                      IconButton(
                        icon: Icon(
                          _tasks[index].completed ? Icons.undo : Icons.check,
                        ),
                        onPressed: () => _toggleTaskCompletion(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeTask(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_task',
            onPressed: () => _navigateToAddTaskPage(context),
            tooltip: 'Add Task',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'add_person',
            onPressed: () => _navigateToAddPersonPage(context),
            tooltip: 'Add Person',
            child: const Icon(Icons.person_add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'calendar',
            onPressed: () => _navigateToCalendarPage(context),
            tooltip: 'View Calendar',
            child: const Icon(Icons.calendar_today),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'schedule',
            onPressed: () => _navigateToSchedulePage(context),
            tooltip: 'View Schedule',
            child: const Icon(Icons.schedule),
          ),
        ],
      ),
    );
  }
}

class Task {
  String title;
  String details;
  Person person;
  bool completed;
  DateTime? startDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  String? imagePath;

  Task({
    required this.title,
    required this.details,
    required this.person,
    this.completed = false,
    this.startDate,
    this.startTime,
    this.endTime,
    this.imagePath,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'],
      details: json['details'],
      person: Person.fromJson(json['person']),
      completed: json['completed'] ?? false,
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      startTime: json['startTime'] != null
          ? TimeOfDay(
              hour: int.parse(json['startTime'].split(":")[0]),
              minute: int.parse(json['startTime'].split(":")[1]))
          : null,
      endTime: json['endTime'] != null
          ? TimeOfDay(
              hour: int.parse(json['endTime'].split(":")[0]),
              minute: int.parse(json['endTime'].split(":")[1]))
          : null,
      imagePath: json['imagePath'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'details': details,
        'person': person.toJson(),
        'completed': completed,
        'startDate': startDate?.toIso8601String(),
        'startTime': startTime != null
            ? '${startTime!.hour}:${startTime!.minute}'
            : null,
        'endTime':
            endTime != null ? '${endTime!.hour}:${endTime!.minute}' : null,
        'imagePath': imagePath,
      };
}

class Person {
  String name;
  String phoneNumber;

  Person({
    required this.name,
    required this.phoneNumber,
  });

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      name: json['name'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phoneNumber': phoneNumber,
      };
}
