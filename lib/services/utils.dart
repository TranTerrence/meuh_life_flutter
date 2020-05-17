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
