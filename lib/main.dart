import 'package:flutter/material.dart';
import 'package:meuh_life/services/authentication.dart';
import 'package:meuh_life/screens/root_screen.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Meuh Life',
        theme: new ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: new RootScreen(auth: new Auth()));
  }
}
