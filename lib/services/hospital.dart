import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class HospitalCard extends StatelessWidget {
  final Function? onMapFunction;
  const HospitalCard({super.key, this.onMapFunction});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: (){
            onMapFunction!('hospitals near me');
          },
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              height: 50,
              width: 50,
              child: Center(
                child: Image.asset(
                  'RImages/hospital_icon.png',
                  height: 32,
                ),
              ),
            ),
          ),
        ),
        Text(
          "Hospital",
          style: GoogleFonts.comfortaa(
            fontSize: 10,
            fontStyle: FontStyle.normal,
          ),
        )
      ],
    );
  }
}
