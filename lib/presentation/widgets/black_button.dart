import 'package:flutter/material.dart';

Widget blackButton(String? text, Widget? icon, void Function() onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 45,
    child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10))),
        child: text == null
            ? icon
            : Text(
                text,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFFF7F7F7)),
              )),
  );
}
