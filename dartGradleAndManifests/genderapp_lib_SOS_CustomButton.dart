import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;

  CustomButton({required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: Color.fromRGBO(188, 66, 107, 1),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        title,
        style: GoogleFonts.comfortaa(
          fontSize: 16,
          color: Colors.pink.shade50,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}