import 'package:flutter/material.dart';

Widget homeCard(String iconPath, String text, void Function() onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF3C3C3C), width: 4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 29,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                iconPath,
                scale: 4,
              ),
            ),
          ),
          Expanded(
            flex: 33,
            child: Container(
              decoration: BoxDecoration(
                  color: const Color(0xFF3C3C3C),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
                  border: Border.all(color: const Color(0xFF3C3C3C), width: 1)),
              child: Padding(
                padding: const EdgeInsets.only(left: 5, right: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    text,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                        color: Colors.white,
                        height: 1.3),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}
