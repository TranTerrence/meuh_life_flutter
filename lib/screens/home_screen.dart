import 'package:flutter/material.dart';
import 'package:meuh_life/screens/chat_screen.dart';
import 'package:meuh_life/screens/mines_screen.dart';
import 'package:meuh_life/screens/profile_screen.dart';
import 'package:meuh_life/services/authentication.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.auth, this.userId, this.logoutCallback})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isEmailVerified = false;

  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    if (index < 3) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  void _checkEmailVerification() async {
    _isEmailVerified = await widget.auth.isEmailVerified();
    if (!_isEmailVerified) {
      _showVerifyEmailDialog();
    }
  }

  void _resentVerifyEmail() {
    widget.auth.sendEmailVerification();
    _showVerifyEmailSentDialog();
  }

  void _showVerifyEmailDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return WillPopScope(
          onWillPop: () {},
          child: AlertDialog(
            title: new Text("Vérifie ton email"),
            content:
                new Text("Clique sur le lien envoyé sur ton adresse email"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Renvoyer le lien"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _resentVerifyEmail();
                },
              ),
              new FlatButton(
                child: new Text("Rafraichir"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _checkEmailVerification();
                },
              ),
              new FlatButton(
                child: new Text("Deconnexion"),
                onPressed: () {
                  Navigator.of(context).pop();
                  signOut();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return WillPopScope(
          onWillPop: () {}, //Disable back button
          child: AlertDialog(
            title: new Text("Verify your account"),
            content: new Text("Le lien pour vérifier ton email a été envoyé"),
            actions: <Widget>[
              new FlatButton(
                child: new Text("Rafraichir"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _checkEmailVerification();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      ProfileScreen(),
      MarketScreen(),
      ChatScreen(),
    ];
    return SafeArea(
      child: new Scaffold(
        /**appBar: new AppBar(
            backgroundColor: Colors.blue.shade800,
            leading: Image.asset('images/logo.png'),
            title: new Text(
            'Meuh Life',
            style: TextStyle(fontFamily: 'Marker'),
            ),
            actions: <Widget>[
            new FlatButton(
            child: new Text('Logout',
            style: new TextStyle(fontSize: 17.0, color: Colors.white)),
            onPressed: signOut)
            ],
            ),*/

        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.person_pin),
              title: Text('Profil'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance),
              title: Text('MINES'),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              title: Text('Chats'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
