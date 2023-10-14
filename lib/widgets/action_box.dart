import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionBox extends StatelessWidget {
  final IconData image;
  final String action;
  final String? description;

  const ActionBox(
      {Key? key, required this.image, required this.action, this.description})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(10.0),
        height: 80.0,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.0), color: Colors.green),
        child: Center(
            child: Text(
          action,
          style: GoogleFonts.roboto(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        )));
  }
}
