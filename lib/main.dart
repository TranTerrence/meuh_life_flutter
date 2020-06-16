import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meuh_life/screens/root_screen.dart';
import 'package:meuh_life/services/authentication.dart';
import 'package:provider/provider.dart';

import 'providers/CurrentUser.dart';

void main() async {
  await Hive.initFlutter();
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Auth auth = new Auth();
    return Provider(
      create: (context) => CurrentUser(auth: auth),
      child: new MaterialApp(
        title: 'Meuh Life',
        theme: new ThemeData(
          //primarySwatch: Colors.blue,
          primaryColor: Colors.blue.shade800,
          accentColor: Colors.amber.shade800,
        ),
        home: new RootScreen(auth: auth),
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'),
          const Locale('fr'),
        ],
      ),
    );
  }
}
