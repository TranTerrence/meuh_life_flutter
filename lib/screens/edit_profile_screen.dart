import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/providers/CurrentUser.dart';
import 'package:meuh_life/services/DatabaseService.dart';
import 'package:meuh_life/services/utils.dart';

class EditProfileScreen extends StatefulWidget {
  final Profile profile;
  final CurrentUser currentUser;

  const EditProfileScreen({Key key, @required this.profile, this.currentUser})
      : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  DatabaseService database = DatabaseService();
  Profile _newProfile;
  TextEditingController textInputControllerDesc;
  TextEditingController textInputControllerPromo;

  @override
  void initState() {
    super.initState();
    _newProfile = Profile.fromJSON(widget.profile.toJson()); //Making a copy
    textInputControllerDesc =
        TextEditingController(text: _newProfile.description);
    textInputControllerPromo = TextEditingController(text: _newProfile.promo);
  }

  @override
  Widget build(BuildContext context) {
    print('_newProfile ${_newProfile.toJson().toString()}');
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le profil'),
      ),
      body: SingleChildScrollView(
        key: PageStorageKey('profile_screen'),
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _newProfile.fullName,
              style: TextStyle(fontSize: 30, fontFamily: 'Marker'),
            ),
            Card(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(_newProfile.email),
                  ],
                ),
              ),
            ),
            showPromo(),
            showType(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                showGapYear(),
                showIsPAM(),
              ],
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Description',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          TextField(
                            minLines: 2,
                            maxLines: 12,
                            cursorColor: Colors.blue.shade800,
                            controller: textInputControllerDesc,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              helperText: "Présente toi",
                            ),
                            onChanged: (text) {
                              _newProfile.description = text;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                RaisedButton(
                    padding: EdgeInsets.all(12.0),
                    shape: new RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(30.0)),
                    color: Colors.blue.shade800,
                    child: new Text('Sauvegarder'),
                    onPressed: () {
                      //Avoid writing to the DB if it's not necessary
                      database.updateProfile(
                          widget.currentUser.id, _newProfile.toJson());
                      Navigator.of(context).pop();
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget showPromo() {
    final RegExp iRegNumbers = RegExp(r'(\d+)');

    return Card(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Promo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('P' + _newProfile.promo),
            TextField(
                controller: textInputControllerPromo,
                decoration: new InputDecoration(
                  hintText: 'Entrer 17 pour 2017',
                ),
                maxLines: 1,
                keyboardType: TextInputType.number,
                maxLength: 2,
                inputFormatters: [
                  WhitelistingTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) => {
                      setState(() {
                        _newProfile.promo = iRegNumbers
                            .allMatches(value)
                            .map((m) => m.group(0))
                            .join()
                            .substring(0, 2);
                      })
                    }),
          ],
        ),
      ),
    );
  }

  Widget showType() {
    return Card(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Parcours',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.school,
                      color: Colors.blue.shade800,
                    ),
                    SizedBox(
                      width: 16.0,
                    ),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _newProfile.type,
                        icon: Icon(Icons.arrow_drop_down),
                        onChanged: (String newValue) {
                          setState(() {
                            _newProfile.type = newValue;
                          });
                        },
                        items: createDropdownMenuItemList(Profile.types),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget showGapYear() {
    return Expanded(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Césurien',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_newProfile.gapYear ? 'Oui' : 'Non'),
                ],
              ),
              SizedBox(
                height: 16.0,
                child: Checkbox(
                  activeColor: Colors.blue.shade800,
                  value: _newProfile.gapYear,
                  onChanged: (bool value) => {
                    setState(() {
                      _newProfile.gapYear = value;
                    })
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget showIsPAM() {
    return Expanded(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'PAM',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_newProfile.isPAM ? 'Oui' : 'Non'),
                ],
              ),
              SizedBox(
                height: 16.0,
                child: Checkbox(
                  activeColor: Colors.blue.shade800,
                  value: _newProfile.isPAM,
                  onChanged: (bool value) => {
                    setState(() {
                      _newProfile.isPAM = value;
                    })
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
