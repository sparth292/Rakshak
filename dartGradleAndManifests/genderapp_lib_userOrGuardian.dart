import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:genderapp/Feature/Feature1.dart';
import 'guardianLogin.dart';

class UserOrGuardian extends StatefulWidget {
  @override
  _UserOrGuardianState createState() => _UserOrGuardianState();
}

class _UserOrGuardianState extends State<UserOrGuardian> {
  String? selectedRole;

  @override
  void initState() {
    super.initState();
    _getSelectedRole();
  }

  // Retrieve the stored choice from SharedPreferences
  Future<void> _getSelectedRole() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedRole = prefs.getString('selectedRole');
    });

    // If a role is already selected, navigate directly to the relevant screen
    if (selectedRole != null) {
      if (selectedRole == 'user') {
        _navigateToFeature1();
      } else if (selectedRole == 'guardian') {
        _navigateToGuardianLogin();
      }
    }
  }

  // Save the selected role to SharedPreferences
  Future<void> _setSelectedRole(String role) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedRole', role);
    setState(() {
      selectedRole = role;
    });
  }

  void _navigateToFeature1() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Feature1screen()),
    );
  }

  void _navigateToGuardianLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => GuardianLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // If a role is already selected, do not display this screen
    if (selectedRole != null) {
      return SizedBox(); // Empty widget as navigation happens in initState
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Save the role and navigate to the user login screen
                await _setSelectedRole('user');
                _navigateToFeature1();
              },
              child: Text("Login as User"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Save the role and navigate to the guardian login screen
                await _setSelectedRole('guardian');
                _navigateToGuardianLogin();
              },
              child: Text("Login as Guardian"),
            ),
          ],
        ),
      ),
    );
  }
}
