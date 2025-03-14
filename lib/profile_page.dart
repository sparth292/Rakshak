import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rakshak_backup_final/change_password.dart';
import 'package:rakshak_backup_final/sign_in.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _image;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignIn()));
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 60), // Space for status bar
            Text(
              "Profile",
              style: GoogleFonts.italiana(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Color(0xFF78143C),
              ),
            ),
            const SizedBox(height: 30),

            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            Text(
              user?.displayName ?? "Username",
              style: GoogleFonts.cabin(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF78143C),
              ),
            ),
            const SizedBox(height: 5),

            Text(
              user?.email ?? "email@example.com",
              style: GoogleFonts.comfortaa(fontSize: 16, color: Color(0xFF78143C)),
            ),
            const SizedBox(height: 50),

            _buildProfileOption(Icons.lock, "Change Password"),
            _buildProfileOption(Icons.notifications, "Notifications"),
            _buildProfileOption(Icons.logout, "Logout"),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF78143C)),
      title: Text(
        title,
        style: GoogleFonts.comfortaa(fontSize: 18, color: Color(0xFF78143C)),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF78143C), size: 16),
      onTap: () {
        if (title == "Change Password") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ChangePasswordScreen()));
        } else if (title == "Logout") {
          _logout();
        }
      },
    );
  }
}
