import 'package:flutter/material.dart';

@override
Widget exitDialog(BuildContext context, String text) {
  return AlertDialog(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    title: Text(text),
    actions: [
      TextButton(
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text(
            "No",
            style: TextStyle(color: Colors.black),
          )),
      TextButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          child: const Text(
            "Yes",
            style: TextStyle(color: Colors.redAccent),
          ))
    ],
  );
}
