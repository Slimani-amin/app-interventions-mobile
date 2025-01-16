import 'package:flutter/material.dart';
import 'main.dart';
import 'task_details_page.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PlannedTasksPage extends StatefulWidget {
  // Changed to StatefulWidget
  final DateTime selectedDate;
  final List<Task> tasks;

  const PlannedTasksPage(
      {super.key, required this.selectedDate, required this.tasks});

  @override
  _PlannedTasksPageState createState() => _PlannedTasksPageState();
}

class _PlannedTasksPageState extends State<PlannedTasksPage> {
  late List<Task> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = widget.tasks;
  }

  Map<String, List<Task>> _groupTasksByPerson() {
    Map<String, List<Task>> groupedTasks = {};
    for (var task in _tasks) {
      if (task.startDate != null &&
          DateFormat('yyyy-MM-dd').format(task.startDate!) ==
              DateFormat('yyyy-MM-dd').format(widget.selectedDate)) {
        if (groupedTasks.containsKey(task.person.name)) {
          groupedTasks[task.person.name]!.add(task);
        } else {
          groupedTasks[task.person.name] = [task];
        }
      }
    }
    return groupedTasks;
  }

  void _sendWhatsAppMessage(String phone, String message) async {
    final url = 'https://wa.me/$phone?text=${Uri.encodeFull(message)}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _onTaskUpdated(Task updatedTask) {
    setState(() {
      int index = _tasks.indexWhere((t) =>
          t.title == updatedTask.title && t.details == updatedTask.details);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Task>> groupedTasks = _groupTasksByPerson();

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Tasks for ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}'),
      ),
      body: ListView(
        children: groupedTasks.entries.map((entry) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  ...entry.value.map((task) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text('Task: ${task.title}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Details: ${task.details}'),
                            task.startTime != null
                                ? Text(
                                    'Start Time: ${task.startTime!.format(context)}')
                                : Container(),
                            task.endTime != null
                                ? Text(
                                    'End Time: ${task.endTime!.format(context)}')
                                : Container(),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetailsPage(
                                task: task,
                                onTaskUpdated: _onTaskUpdated,
                              ),
                            ),
                          );
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () {
                            final message =
                                'Task: ${task.title}\nDetails: ${task.details}\nDate: ${task.startDate != null ? DateFormat('yyyy-MM-dd').format(task.startDate!) : 'N/A'}\nStart Time: ${task.startTime != null ? task.startTime!.format(context) : 'N/A'}\nEnd Time: ${task.endTime != null ? task.endTime!.format(context) : 'N/A'}';
                            _sendWhatsAppMessage(
                                task.person.phoneNumber, message);
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
