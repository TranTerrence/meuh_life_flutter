import 'package:flutter/material.dart';

class MeuhLifeLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Image.asset(
          'images/logo.png',
          width: 200,
        ),
        RichText(
          text: TextSpan(
            text: '',
            children: <TextSpan>[
              TextSpan(
                text: 'M',
                style: TextStyle(
                  color: Colors.amber.shade800,
                  fontFamily: 'Marker',
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              TextSpan(
                text: 'euh',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontFamily: 'Marker',
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              TextSpan(
                text: ' L',
                style: TextStyle(
                  color: Colors.amber.shade800,
                  fontFamily: 'Marker',
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
              TextSpan(
                text: 'ife',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontFamily: 'Marker',
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
