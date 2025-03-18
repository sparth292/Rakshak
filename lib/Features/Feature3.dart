import 'package:flutter/material.dart';
import 'package:rakshak_backup_final/home_page.dart';
import 'package:rakshak_backup_final/userOrGuardian.dart';
import 'package:rakshak_backup_final/welcome_screen.dart';
import '../customButton.dart';
import 'package:rakshak_backup_final/gender_detection/gender_detection.dart';

import '../splashscreen.dart';
class Feature3screen extends StatefulWidget {
  const Feature3screen({super.key});

  @override
  State<Feature3screen> createState() => _Feature1screenState();
}

class _Feature1screenState extends State<Feature3screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 35),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'RImages/deathImage.jpeg',
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Safe & Dangerous Area Mapping",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "View safe and high-risk zones on a map to avoid dangerous areas.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Previous button at bottom-left corner
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 120,
                  height: 50,
                  child: CustomButton(
                    onPressed: () {
                      Navigator.pop(context); // Go to the previous screen
                    },
                    text: "Previous",
                  ),
                ),
              ),
            ),
            // Next button at bottom-right corner
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 120,
                  height: 50,
                  child: CustomButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => userOrGuardian()),
                      );// Navigate to the next screen
                    },
                    text: "Next",
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
