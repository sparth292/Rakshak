import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:genderapp/Feature/Feature1.dart';
import 'package:genderapp/home_page.dart';
import 'package:genderapp/splashscreen.dart';
import 'package:genderapp/splashscreenstart.dart';
import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';


List<CameraDescription>? cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  await Firebase.initializeApp();
  // Check if gender verification is already completed
  final prefs = await SharedPreferences.getInstance();
  final isVerified = prefs.getBool('isGenderVerified') ?? false;

  runApp(MyApp(isVerified: isVerified));
}

class MyApp extends StatelessWidget {
  final bool isVerified;

  const MyApp({Key? key, required this.isVerified}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rakshak',
      home: isVerified ? SplashScreen() :  SplashScreen1(),
    );
  }
}



