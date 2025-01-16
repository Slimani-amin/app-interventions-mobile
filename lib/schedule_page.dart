import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'main.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  final List<Task> tasks;

  const SchedulePage({super.key, required this.tasks});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime _selectedDate = DateTime.now();
  final CalendarController _calendarController = CalendarController();

  Future<void> _sendWhatsAppMessage(String phone, String message) async {
    final url = 'https://wa.me/$phone?text=${Uri.encodeFull(message)}';
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        print('Could not launch $url');
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
          ),
        ],
      ),
      body: SfCalendar(
        controller: _calendarController,
        view: CalendarView.timelineWeek,
        firstDayOfWeek: 1,
        initialDisplayDate: _selectedDate,
        dataSource: TaskDataSource(widget.tasks),
        resourceViewSettings: ResourceViewSettings(
          visibleResourceCount:
              widget.tasks.map((e) => e.person.name).toSet().length,
          displayNameTextStyle: const TextStyle(
            fontSize: 12,
            color: Colors.black,
            fontStyle: FontStyle.normal,
          ),
          showAvatar: true,
          size: 80,
        ),
        timeSlotViewSettings: const TimeSlotViewSettings(
          timeInterval: Duration(hours: 1),
          startHour: 6,
          endHour: 24, // Extend the end hour to midnight
        ),
        onTap: (calendarTapDetails) {
          if (calendarTapDetails.targetElement == CalendarElement.appointment) {
            final Appointment appointment =
                calendarTapDetails.appointments!.first;
            final Task task = widget.tasks.firstWhere((task) =>
                task.title == appointment.subject.split('\n').first &&
                task.details == appointment.subject.split('\n').last);
            final message =
                'Task: ${task.title}\nDetails: ${task.details}\nDate: ${task.startDate != null ? DateFormat('yyyy-MM-dd').format(task.startDate!) : 'N/A'}\nStart Time: ${task.startTime != null ? task.startTime!.format(context) : 'N/A'}\nEnd Time: ${task.endTime != null ? task.endTime!.format(context) : 'N/A'}';
            _sendWhatsAppMessage(task.person.phoneNumber, message);
          }
        },
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _calendarController.displayDate = _selectedDate;
      });
    }
  }
}

List<CalendarResource> getResources(List<Task> tasks) {
  Set<String> persons = tasks.map((e) => e.person.name).toSet();
  return persons.map((person) {
    return CalendarResource(
      id: person,
      displayName: person,
      color: Colors.blue,
    );
  }).toList();
}

List<Appointment> getAppointmentsFromTasks(List<Task> tasks) {
  List<Appointment> appointments = <Appointment>[];
  for (var task in tasks) {
    if (task.startDate != null &&
        task.startTime != null &&
        task.endTime != null) {
      final DateTime startDateTime = DateTime(
        task.startDate!.year,
        task.startDate!.month,
        task.startDate!.day,
        task.startTime!.hour,
        task.startTime!.minute,
      );
      final DateTime endDateTime = DateTime(
        task.startDate!.year,
        task.startDate!.month,
        task.startDate!.day,
        task.endTime!.hour,
        task.endTime!.minute,
      );

      appointments.add(Appointment(
        startTime: startDateTime,
        endTime: endDateTime,
        subject: '${task.title}\n${task.details}',
        color: Colors.blue,
        resourceIds: [task.person.name],
      ));
    }
  }
  return appointments;
}

class TaskDataSource extends CalendarDataSource {
  TaskDataSource(List<Task> tasks) {
    resources = getResources(tasks);
    appointments = getAppointmentsFromTasks(tasks);
  }
}
