import 'package:flutter/material.dart';

Widget backButton(void Function() onTap, String text, bool isIcon) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: 90,
      height: 30,
      decoration: BoxDecoration(
          color: const Color(0xFF3C3C3C),
          borderRadius: BorderRadius.circular(4)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isIcon
              ? const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 18,
                )
              : Container(),
          isIcon
              ? const SizedBox(
                  width: 6,
                )
              : Container(),
          Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          )
        ],
      ),
    ),
  );
}
