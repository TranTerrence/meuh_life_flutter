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

// Returns a key based on 2 input strings
String getMixKey(String ID1, String ID2) {
  String mixKey;
  if (ID1.hashCode <= ID2.hashCode) {
    mixKey = '$ID1-$ID2';
  } else {
    mixKey = '$ID2-$ID1';
  }
  return mixKey;
}
