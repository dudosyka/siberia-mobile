import 'package:flutter/material.dart';

Widget roundButton(
    Widget icon, double size, void Function() onTap, bool isActive) {
  return Opacity(
    opacity: isActive ? 1.0 : 0.3,
    child: InkWell(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size + 8,
            height: size + 8,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: const Color(0xFFDFDFDF)),
          ),
          Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: isActive ? Colors.black : const Color(0xFFF4F4F4)),
              child: icon),
        ],
      ),
    ),
  );
}
