import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meuh_life/providers/CurrentUser.dart';
import 'package:meuh_life/screens/connexion_screen.dart';
import 'package:meuh_life/screens/home_screen.dart';
import 'package:meuh_life/services/HivePrefs.dart';
import 'package:meuh_life/services/authentication.dart';
import 'package:provider/provider.dart';

enum AuthStatus {
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN,
}
// Shared Preference save USER ID
saveUserIDToHive(userID) async {
  final preferences = await HivePrefs.getInstance();
  await preferences.setUserID(userID);
}

/// First screen of the App
///
/// Check if the user is already logged in or not
/// will show Home Screen or the Connexion screen
///
class RootScreen extends StatefulWidget {
  RootScreen({this.auth});

  final BaseAuth auth;

  @override
  State<StatefulWidget> createState() => new _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = "";
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then((user) {
      saveUserIDToHive(user.uid.toString());
      setState(() {
        _userId = user.uid.toString();
      });
    });

    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userId = "";
    });
  }

  Widget buildWaitingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return new ConnexionScreen(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          registerNotification(_userId);
          return Provider(
            create: (context) => CurrentUser(
                auth: widget.auth, id: _userId, logoutCallback: logoutCallback),
            child: HomeScreen(
              userId: _userId,
              auth: widget.auth,
              logoutCallback: logoutCallback,
            ),
          );
        } else
          return buildWaitingScreen();
        break;
      default:
        return buildWaitingScreen();
    }
  }

  void registerNotification(String userID) {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      print('onMessage: $message');
      Platform.isAndroid
          ? showNotification(message['notification'])
          : showNotification(message['aps']['alert']);
//      //Test to get the notification to open the Conversation Screen, but doen't work, can delete this code
//      if (authStatus == AuthStatus.LOGGED_IN) {
//        ChatRoom chatRoom =
//            ChatRoom.fromMap(message['chatRoom'], message['chatRoom'].id);
//        var convProps = {
//          chatRoom: chatRoom,
//          userID: userID,
//        };
//        switch (message['chatRoom'].type) {
//          case "SINGLE_USER":
//            convProps.addAll({"toProfile": message['chatRoom'].users[0]});
//            break;
//
//          case "SINGLE_ORGANISATION":
//            convProps.addAll(
//                {"toOrganisation": message['chatRoom'].organisations[0]});
//            break;
//        }
//        Navigator.push(
//          context,
//          MaterialPageRoute(
//              builder: (context) => ConversationScreen(
//                    userID: userID,
//                    chatRoom: chatRoom,
//                  )),
//        );
//      }

      return;
    }, onResume: (Map<String, dynamic> message) {
      print('onResume: $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      print('onLaunch: $message');
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      Firestore.instance
          .collection('users')
          .document(userID)
          .updateData({'pushToken': token});
    }).catchError((err) {
      print(err.message.toString());
      //Fluttertoast.showToast(msg: err.message.toString());
    });
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ?? 'com.terrence.meuhlife',
      'Meuh Life',
      'Canal des nouveaux post',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    print(message);
//    print(message['body'].toString());
//    print(json.encode(message));

    await flutterLocalNotificationsPlugin.show(0, message['title'].toString(),
        message['body'].toString(), platformChannelSpecifics,
        payload: json.encode(message));

//    await flutterLocalNotificationsPlugin.show(
//        0, 'plain title', 'plain body', platformChannelSpecifics,
//        payload: 'item x');
  }
}
