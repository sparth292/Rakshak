import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:rakshak_backup_final/home_page.dart'; // Import HomePage

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
      backgroundColor: Color.fromRGBO(188, 66, 107, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('RImages/redbull.png')
                .animate()
                .fadeIn(duration: Duration(seconds: 2))
                .scale(duration: Duration(seconds: 2)),
            SizedBox(height: 20),
            Image.asset(
              'RImages/rakshaktxt.jpeg',
              height: 50,
              width: 200,
            )
                .animate()
                .slideY(begin: 1, end: 0, duration: Duration(seconds: 2))
                .fadeIn(duration: Duration(seconds: 2)),
            SizedBox(height: 10),
            Text(
              "𝑨 𝒃𝒐𝒏𝒅 𝒕𝒉𝒂𝒕 𝒌𝒆𝒆𝒑𝒔 𝒚𝒐𝒖 𝒔𝒂𝒇𝒆,",
              style: TextStyle(
                fontSize: 20.0,
                color: Color(0xFFFFC1CC),
                fontWeight: FontWeight.bold,
              ),
            )
                .animate()
                .slideY(begin: 1, end: 0, duration: Duration(seconds: 2), delay: Duration(milliseconds: 200))
                .fadeIn(duration: Duration(seconds: 2)),
            Text(
              "𝒆𝒗𝒆𝒓𝒚 𝒎𝒊𝒏𝒖𝒕𝒆, 𝒆𝒗𝒆𝒓𝒚 𝒅𝒂𝒚.",
              style: TextStyle(
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
