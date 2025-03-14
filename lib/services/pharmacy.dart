import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class PharmacyCard extends StatelessWidget {
  final Function? onMapFunction;
  const PharmacyCard({super.key, this.onMapFunction});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: (){
            onMapFunction!('pharmacies near me');
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
                  'RImages/pharmacy_icon.png',
                  height: 32,
                ),
              ),
            ),
          ),
        ),
        Text(
          "Pharmacy",
          style: GoogleFonts.comfortaa(
            fontSize: 10,
            fontStyle: FontStyle.normal,
          ),
        )
      ],
    );
  }
}
