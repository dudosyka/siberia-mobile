import 'package:flutter/material.dart';

Widget backButton(void Function() onTap) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: 80,
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFF3C3C3C),
        borderRadius: BorderRadius.circular(4)
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 18,
          ),
          SizedBox(width: 6,),
          Text(
            "BACK",
            style: TextStyle(fontSize: 16, color: Colors.white),
          )
        ],
      ),
    ),
  );
}
