import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class PoliceStationCard extends StatelessWidget {
  final Function? onMapFunction;
  const PoliceStationCard({super.key, this.onMapFunction});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: (){
            onMapFunction!('police stations near me');
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
                  'RImages/police_icon.png',
                  height: 32,
                ),
              ),
            ),
          ),
        ),
        Text(
          "Police",
          style: GoogleFonts.comfortaa(
            fontSize: 10,
            fontStyle: FontStyle.normal,
          ),
        )
      ],
    );
  }
}
