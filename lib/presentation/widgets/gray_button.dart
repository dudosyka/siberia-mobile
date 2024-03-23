import 'package:flutter/material.dart';

Widget grayButton(void Function() onTap, String text) {
  return InkWell(
    onTap: onTap,
    child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFF3C3C3C),
            borderRadius: BorderRadius.circular(4)),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
            ),
          ),
        )),
  );
}
