import 'package:rakshak_backup_final/Features/Feature3.dart';
import 'package:flutter/material.dart';
import '../customButton.dart';

class Feature2screen extends StatefulWidget {
  const Feature2screen({super.key});

  @override
  State<Feature2screen> createState() => _Feature2screenState();
}

class _Feature2screenState extends State<Feature2screen> {
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
                      'RImages/genderTick.jpeg',
                      height: 150,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "AI-Powered Gender Detection",
                      textAlign: TextAlign.center, // Center-align title
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Authenticate users securely using AI-based gender detection technology.",
                      textAlign: TextAlign.center, // Center-align subtitle
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black38,
                        fontWeight: FontWeight.bold,
                        height: 1.5, // Improved line height for better readability
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Feature3screen(),
                        ),
                      ); // Navigate to the next screen
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
