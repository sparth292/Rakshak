import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rakshak_backup_final/Features/Feature1.dart';
import 'package:rakshak_backup_final/home_page.dart'; // Import HomePage
import 'package:google_fonts/google_fonts.dart';
class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure navigation happens only once
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Navbar()), // Navigate to HomePage after splash
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF78143C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('RImages/redbull.png')
                .animate()
                .fadeIn(duration: Duration(seconds: 2))
                .scale(duration: Duration(seconds: 2)),
            SizedBox(height: 20),
            // Image.asset(
            //   'RImages/rakshaktxt.jpeg',
            //   height: 50,
            //   width: 200,
            // )
          Text(
            "RAKSHAK",
            style: GoogleFonts.italiana(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          )
                .animate()
                .slideY(begin: 1, end: 0, duration: Duration(seconds: 2))
                .fadeIn(duration: Duration(seconds: 2)),
            SizedBox(height: 10),
            Text(
              "A bond that keeps you safe,",
              style: GoogleFonts.comfortaa(
                fontSize: 20.0,
                color: Color(0xFFFFC1CC),
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .slideY(begin: 1, end: 0, duration: Duration(seconds: 2), delay: Duration(milliseconds: 200))
                .fadeIn(duration: Duration(seconds: 2)),
            Text(
              "every minute, every day.",
              style: GoogleFonts.comfortaa(
                fontSize: 20.0,
                color: Color(0xFFFFC1CC),
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .slideY(begin: 1, end: 0, duration: Duration(seconds: 2), delay: Duration(milliseconds: 400))
                .fadeIn(duration: Duration(seconds: 2)),
          ],
        ),
      ),
    );
  }
}
