import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'ChatApp/AuthScreen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  File? _selectedImage;
  String? _profileImagePath;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkLoggedInUser();
  }

  Future<void> _checkLoggedInUser() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      _currentUser = _auth.currentUser;

      if (_currentUser != null) {
        await _fetchUserDetails();
        await _loadProfileImagePath();
      } else {
        _errorMessage = 'No user logged in.';
      }
    } catch (e) {
      _errorMessage = 'Error checking logged-in user: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUserDetails() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data();
        });
      } else {
        _errorMessage = 'User data not found in Firestore.';
      }
    } catch (e) {
      _errorMessage = 'Error fetching user details: $e';
    }
  }

  Future<void> _loadProfileImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _profileImagePath = prefs.getString('profileImagePath_${_currentUser!.uid}');
      });
    } catch (e) {
      _errorMessage = 'Error loading profile image: $e';
    }
  }

  Future<void> _saveProfileImagePath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profileImagePath_${_currentUser!.uid}', _profileImagePath!);
    } catch (e) {
      debugPrint('Error saving profile image path: $e');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && File(pickedFile.path).existsSync()) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _profileImagePath = pickedFile.path;
      });

      await _saveProfileImagePath();
    } else {
      debugPrint('No valid image selected.');
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromRGBO(188, 66, 107, 1),
        title: Text(
          'Profile',
          style: GoogleFonts.cinzel(
            fontSize: 25,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _currentUser == null
          ? _buildErrorState('No user logged in. Please log in.')
          : _errorMessage.isNotEmpty
          ? _buildErrorState(_errorMessage)
          : _buildProfileContent(),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.comfortaa(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(188, 66, 107, 1),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.comfortaa(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: _profileImagePath != null
                    ? FileImage(File(_profileImagePath!))
                    : const AssetImage('assets/default_avatar.png')
                as ImageProvider,
                child: _profileImagePath == null
                    ? const Icon(
                  Icons.camera_alt,
                  size: 50,
                  color: Colors.grey,
                )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Username: ${_userData!['username']}',
              style: GoogleFonts.cinzel(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${_userData!['email']}',
              style: GoogleFonts.comfortaa(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(188, 66, 107, 1),
              ),
              child: Text(
                'Logout',
                style: GoogleFonts.comfortaa(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
