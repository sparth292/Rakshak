import 'package:flutter/material.dart';

class DialogueBox {
  DialogueBox(BuildContext context, String text);

  static void show(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(text),
      ),
    );
  }
}