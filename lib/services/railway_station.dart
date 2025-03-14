import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class RailwayStationCard extends StatelessWidget {
  final Function? onMapFunction;
  const RailwayStationCard({super.key, this.onMapFunction});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: (){
            onMapFunction!('railway stations near me');
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
                  'RImages/train_icon.png',
                  height: 32,
                ),
              ),
            ),
          ),
        ),
        Text(
          "Railway",
          style: GoogleFonts.comfortaa(
            fontSize: 10,
            fontStyle: FontStyle.normal,
          ),
        )
      ],
    );
  }
}
