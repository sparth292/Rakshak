import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class SignupButton extends StatelessWidget {
  const SignupButton({super.key, this.buttonText, this.ontap, this.color, this.TextColor});
  final String? buttonText;
  final Widget? ontap;
  final Color? color;
  final Color? TextColor;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (e)=> ontap!,
            ));
        },
      child: Container(
        decoration: BoxDecoration(
          color: color!,
          borderRadius: BorderRadius.only(topLeft:Radius.circular(50)),
        ),
        child: Center(
          child: Text(
          buttonText!,
            textAlign: TextAlign.center,
          style: GoogleFonts.comfortaa(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: TextColor!,
          ),),
        ),
      ),
    );
  }
}
