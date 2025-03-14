import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakshak_backup_final/sign_in.dart';
import 'package:rakshak_backup_final/sign_up.dart';
import 'package:rakshak_backup_final/theme.dart';
import 'package:rakshak_backup_final/custom_scaffold.dart';
import 'package:rakshak_backup_final/signup_button.dart';
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      resizeToAvoidBottomInset: false,
      child: Column(
        children: [
          // Flexible(child: Container(
          //   padding: EdgeInsets.symmetric(vertical: 0,horizontal: 40.0),
          // )),
          Flexible(
            flex: 8,
              child: Container(
                child: Center(
                    child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                text: 'Welcome!\n',
                style: GoogleFonts.italiana(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                ),
                              ),
                              TextSpan(
                text: 'Login or Register now to join us!\n',
                style: GoogleFonts.comfortaa(
                  fontSize: 15,
                )
                              )
                            ],
                          ),
                      ),
                    ),
              ),
              ),
          Flexible(
            flex: 1,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Row(
                  children: [
                    Expanded(
                      child:
                        SignupButton(
                          buttonText: "Sign In",
                          ontap: SignIn(),
                          color: Colors.transparent,
                          TextColor: Colors.white,
                        ),
                    ),
                    Expanded(
                      child:
                      SignupButton(
                        buttonText: "Sign Up",
                        ontap: SignUp(),
                        color: Colors.white,
                        TextColor: lightColorScheme.primary,
                      ),
                    ),
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }
}
