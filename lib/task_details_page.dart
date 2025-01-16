import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'main.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class TaskDetailsPage extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskUpdated;

  const TaskDetailsPage(
      {super.key, required this.task, required this.onTaskUpdated});

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  File? _image;

  @override
  void initState() {
    super.initState();
    if (widget.task.imagePath != null) {
      _image = File(widget.task.imagePath!);
    }
  }

  Future<void> _openWhatsApp(String phone, String message) async {
    final whatsappUrl = "https://wa.me/$phone?text=${Uri.encodeFull(message)}";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open WhatsApp')),
      );
    }
  }

  void _copyToClipboard(String message) {
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task details copied to clipboard')),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      final savedImage = await File(pickedFile.path).copy(imagePath);

      setState(() {
        _image = savedImage;
        widget.task.imagePath = imagePath;
      });

      widget.onTaskUpdated(widget.task);
    }
  }

  String _formatTaskDetails() {
    return '''
Task: ${widget.task.title}
Details: ${widget.task.details}
Date: ${widget.task.startDate != null ? DateFormat('yyyy-MM-dd').format(widget.task.startDate!) : 'N/A'}
Start Time: ${widget.task.startTime != null ? widget.task.startTime!.format(context) : 'N/A'}
End Time: ${widget.task.endTime != null ? widget.task.endTime!.format(context) : 'N/A'}
Person: ${widget.task.person.name}
Phone: ${widget.task.person.phoneNumber}
''';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskDetails = _formatTaskDetails();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyToClipboard(taskDetails),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                'Date:',
                widget.task.startDate != null
                    ? DateFormat('yyyy-MM-dd').format(widget.task.startDate!)
                    : 'N/A'),
            _buildInfoRow(
                'Start Time:',
                widget.task.startTime != null
                    ? widget.task.startTime!.format(context)
                    : 'N/A'),
            _buildInfoRow(
                'End Time:',
                widget.task.endTime != null
                    ? widget.task.endTime!.format(context)
                    : 'N/A'),
            _buildInfoRow('Person:', widget.task.person.name),
            _buildInfoRow('Phone:', widget.task.person.phoneNumber),
            const SizedBox(height: 16),
            const Text(
              'Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.task.details,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () =>
                    _openWhatsApp(widget.task.person.phoneNumber, taskDetails),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('Send WhatsApp Message'),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Task Image:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  if (_image != null)
                    Image.file(
                      _image!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child:
                          Icon(Icons.image, size: 50, color: Colors.grey[600]),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text(
                        'Upload Image'), // Button label updated to "Upload Image"
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
