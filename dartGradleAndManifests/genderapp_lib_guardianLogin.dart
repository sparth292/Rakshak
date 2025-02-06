import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import 'livelocation.dart';

class UUIDEntryPage extends StatefulWidget {
  @override
  _UUIDEntryPageState createState() => _UUIDEntryPageState();
}

class _UUIDEntryPageState extends State<UUIDEntryPage> {
  final TextEditingController _uuidController = TextEditingController();
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("locations");

  String? _error;

  void validateUUID() async {
    final uuid = _uuidController.text.trim();

    if (uuid.isEmpty) {
      setState(() => _error = "Please enter a valid UUID.");
      return;
    }

    // Check if UUID exists in the database
    final snapshot = await _databaseRef.child(uuid).get();

    if (snapshot.exists) {
      // Navigate to the tracking page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LiveTrackingPage(uuid: uuid)),
      );
    } else {
      setState(() => _error = "Invalid UUID. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter User UUID")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _uuidController,
              decoration: InputDecoration(
                labelText: "Enter UUID",
                errorText: _error,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: validateUUID,
              child: Text("Track Location"),
            ),
          ],
        ),
      ),
    );
  }
}
