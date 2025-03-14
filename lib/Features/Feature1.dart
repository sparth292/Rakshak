import 'package:rakshak_backup_final/Features/Feature2.dart';
import 'package:flutter/material.dart';
import '../customButton.dart';

class Feature1screen extends StatefulWidget {
  const Feature1screen({super.key});

  @override
  State<Feature1screen> createState() => _Feature1screenState();
}

class _Feature1screenState extends State<Feature1screen> {
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
                    Hero(
                      tag: 'sosImage',
                      child: Image.asset(
                        'assets/images/sos3.png',
                        height: 150,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Voice-Activated SOS",
                      textAlign: TextAlign.center, // Center-align title
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Trigger an SOS alert via voice commands for hands-free emergency support.",
                      textAlign: TextAlign.center, // Center-align subtitle
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Next button at the center-bottom
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: 150,
                  height: 50,
                  child: CustomButton(
                    onPressed: () {
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Feature2screen(),
                          ),
                        );
                      } catch (e) {
                        debugPrint("Navigation error: $e");
                      }
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
