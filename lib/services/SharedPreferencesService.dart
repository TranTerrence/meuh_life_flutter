import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  Future<String> getUserID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID');
    return userID;
  }
}
