import 'package:flutter/material.dart';
import 'main.dart';
import 'package:intl/intl.dart';

class AddTaskPage extends StatefulWidget {
  final Task? task;
  final List<Person> persons;
  final List<Task> tasks;
  final bool Function(Task, {Task? existingTask}) hasConflict;

  const AddTaskPage(
      {super.key,
      this.task,
      required this.persons,
      required this.tasks,
      required this.hasConflict});

  @override
  _AddTaskPageState createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  DateTime? _selectedStartDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  Person? _selectedPerson;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _detailsController.text = widget.task!.details;
      _selectedPerson = widget.task!.person;
      if (widget.task!.startDate != null) {
        _selectedStartDate = widget.task!.startDate;
        _startDateController.text =
            DateFormat('yyyy-MM-dd').format(_selectedStartDate!);
      }
      if (widget.task!.startTime != null) {
        _selectedStartTime = widget.task!.startTime;
        _startTimeController.text = _selectedStartTime!.format(context);
      }
      if (widget.task!.endTime != null) {
        _selectedEndTime = widget.task!.endTime;
        _endTimeController.text = _selectedEndTime!.format(context);
      }
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedStartDate = pickedDate;
        _startDateController.text =
            DateFormat('yyyy-MM-dd').format(_selectedStartDate!);
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedStartTime = pickedTime;
        _startTimeController.text = pickedTime.format(context);
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedEndTime = pickedTime;
        _endTimeController.text = pickedTime.format(context);
      });
    }
  }

  void _submitTask() {
    if (_titleController.text.isNotEmpty &&
        _detailsController.text.isNotEmpty &&
        _selectedPerson != null &&
        _selectedStartDate != null &&
        _selectedStartTime != null &&
        _selectedEndTime != null) {
      final task = Task(
        title: _titleController.text,
        details: _detailsController.text,
        person: _selectedPerson!,
        startDate: _selectedStartDate,
        startTime: _selectedStartTime,
        endTime: _selectedEndTime,
        completed: widget.task?.completed ?? false,
      );

      if (widget.hasConflict(task, existingTask: widget.task)) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Conflict'),
            content: const Text(
                'The selected time for this person is already planned.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        Navigator.pop(context, task);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter task title',
              ),
            ),
            TextField(
              controller: _detailsController,
              decoration: const InputDecoration(
                hintText: 'Enter task details',
              ),
              minLines: 1,
              maxLines: 10,
              keyboardType: TextInputType.multiline,
            ),
            DropdownButtonFormField<Person>(
              value: _selectedPerson,
              onChanged: (value) {
                setState(() {
                  _selectedPerson = value;
                });
              },
              items: widget.persons.map((person) {
                return DropdownMenuItem<Person>(
                  value: person,
                  child: Text(person.name),
                );
              }).toList(),
              decoration: const InputDecoration(
                hintText: 'Select person',
              ),
            ),
            GestureDetector(
              onTap: () => _selectStartDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _startDateController,
                  decoration: const InputDecoration(
                    hintText: 'Select Start Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _selectStartTime(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _startTimeController,
                  decoration: const InputDecoration(
                    hintText: 'Select Start Time',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _selectEndTime(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _endTimeController,
                  decoration: const InputDecoration(
                    hintText: 'Select End Time',
                    prefixIcon: Icon(Icons.access_time),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _submitTask,
              child: Text(widget.task == null ? 'Add Task' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
