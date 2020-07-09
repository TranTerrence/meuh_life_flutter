import 'package:meuh_life/services/authentication.dart';

//Class use for the provider
class CurrentUser {
  String id = '';
  BaseAuth auth;
  Function logoutCallback;

  CurrentUser({this.id, this.auth, this.logoutCallback});

  signOut() async {
    try {
      await auth.signOut();
      logoutCallback();
    } catch (e) {
      print(e);
    }
  }
}
