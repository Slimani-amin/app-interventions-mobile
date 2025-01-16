import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'main.dart';

class AddPersonPage extends StatefulWidget {
  const AddPersonPage({super.key});

  @override
  _AddPersonPageState createState() => _AddPersonPageState();
}

class _AddPersonPageState extends State<AddPersonPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  Future<void> _savePerson(String name, String phoneNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Person> persons = [];
    String? personsString = prefs.getString('persons');
    if (personsString != null) {
      List<dynamic> personList = json.decode(personsString);
      persons = personList.map((person) => Person.fromJson(person)).toList();
    }
    persons.add(Person(name: name, phoneNumber: phoneNumber));
    prefs.setString('persons',
        json.encode(persons.map((person) => person.toJson()).toList()));
  }

  void _submitPerson() {
    if (_nameController.text.isNotEmpty &&
        _phoneNumberController.text.isNotEmpty) {
      _savePerson(_nameController.text, _phoneNumberController.text);
      Navigator.pop(
          context,
          Person(
              name: _nameController.text,
              phoneNumber: _phoneNumberController.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Person'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Enter person name',
              ),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                hintText: 'Enter phone number',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _submitPerson,
              child: const Text('Add Person'),
            ),
          ],
        ),
      ),
    );
  }
}
