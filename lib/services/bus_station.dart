import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class BusStationCard extends StatelessWidget {
  final Function? onMapFunction;
  const BusStationCard({super.key, this.onMapFunction});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: (){
            onMapFunction!('bus stops near me');
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
                  'RImages/busStation_icon.png',
                  height: 32,
                ),
              ),
            ),
          ),
        ),
        Text(
          "Bus",
          style: GoogleFonts.comfortaa(
            fontSize: 10,
            fontStyle: FontStyle.normal,
          ),
        )
      ],
    );
  }
}
