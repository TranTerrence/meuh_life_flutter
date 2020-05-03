import 'package:flutter/material.dart';

Widget showLogo() {
  return Column(
    children: <Widget>[
      Image.asset(
        'images/logo.png',
        width: 200,
      ),
      Text(
        'Meuh Life',
        style: TextStyle(
          color: Colors.blue.shade800,
          fontFamily: 'Marker',
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),
    ],
  );
}
