import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static Future<String> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID');
    return userID;
  }
}

List<DropdownMenuItem<String>> createDropdownMenuItemList(Map map) {
  List<DropdownMenuItem<String>> list = [];
  map.forEach((key, value) {
    list.add(DropdownMenuItem<String>(
      value: key,
      child: Text(value),
    ));
  });
  return list;
}

String getChatRoomID(String userID1, String userID2) {
  String chatRoomID;
  if (userID1.hashCode <= userID2.hashCode) {
    chatRoomID = '$userID1-$userID2';
  } else {
    chatRoomID = '$userID2-$userID1';
  }
  return chatRoomID;
}
