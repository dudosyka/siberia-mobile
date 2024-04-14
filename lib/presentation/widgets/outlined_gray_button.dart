import 'package:flutter/material.dart';

Widget outlinedGrayButton(void Function() onTap, String text) {
  return InkWell(
    onTap: onTap,
    child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0xFF3C3C3C))),
        child: Padding(
          padding:
              const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF3C3C3C),
                  fontWeight: FontWeight.w500),
            ),
          ),
        )),
  );
}
