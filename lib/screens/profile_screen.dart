import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/services/authentication.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen(this.userID, this.auth);

  final BaseAuth auth;
  final String userID;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile _profile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document(widget.userID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return new Text("Chargement ... ");
              }
              _profile = Profile.fromDocSnapshot(snapshot.data);
              return Column(
                children: [
                  showAvatar(),
                  Text(
                    _profile.getFullName(),
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
                          Text(_profile.email),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: Card(
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            child: Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Promo',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text('P' + _profile.promo),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(_profile.gapYear ? 'Oui' : 'Non'),
                                  ],
                                ),
                                SizedBox(
                                  height: 16.0,
                                  child: Checkbox(
                                      activeColor: Colors.blue.shade800,
                                      value: _profile.gapYear,
                                      onChanged: (bool value) =>
                                          updateGapYear(value)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Card(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Description',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(_profile.description),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blue.shade800,
                            ),
                            onPressed: () => print('edit Desrip'),
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
                        child: new Text('Paramétres'),
                        onPressed: () => print('Click Parametres'),
                      ),
                      RaisedButton(
                        padding: EdgeInsets.all(12.0),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Colors.blue.shade800,
                        child: new Text('Se déconnecter'),
                        onPressed: () => widget.auth.signOut(),
                      ),
                    ],
                  ),
                ],
              );
            }),
      ),
    );
  }

  Widget showAvatar() {
    return CachedNetworkImage(
      imageUrl: _profile.picUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: 120.0,
        height: 120.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.blue.shade800,
            width: 2,
          ),
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: 60.0,
        backgroundColor: Colors.blue.shade800,
        child: Text(
          _profile.getNameInitials(),
          style: TextStyle(
            fontSize: 60.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  updateGapYear(value) {
    DocumentReference ref =
        Firestore.instance.document("users/" + widget.userID);
    ref.updateData({"gapYear": value});
  }
}
