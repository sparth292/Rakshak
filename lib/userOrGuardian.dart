import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rakshak_backup_final/gender_detection/gender_detection.dart';
import 'package:rakshak_backup_final/theme.dart';
import 'package:rakshak_backup_final/custom_scaffold.dart';
import 'package:rakshak_backup_final/signup_button.dart';

class userOrGuardian extends StatelessWidget {
  const userOrGuardian ({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      resizeToAvoidBottomInset: false,
      child: Column(
        children: [
          Flexible(
            flex: 8,
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
                      text: 'Login as User or Guardian?\n',
                      style: GoogleFonts.comfortaa(
                        fontSize: 15,
                      ),
                    ),
                  ],
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
                    child: SignupButton(
                      buttonText: "User",
                      ontap: GenderVerification(),
                      color: Colors.transparent,
                      TextColor: Colors.white,
                    ),
                  ),
                  Expanded(
                    child: SignupButton(
                      buttonText: "Guardian",
                      ontap: AlertDialog(
                        title: const Text("Coming Soon"),
                        content: const Text("The Guardian Map feature will be added in a future update."),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      ), // Show popup when clicked
                      color: Colors.white,
                      TextColor: lightColorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
