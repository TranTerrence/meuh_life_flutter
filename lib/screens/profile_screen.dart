import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/screens/create_organisation_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';
import 'package:meuh_life/services/authentication.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen(this.userID, this.auth, this.signOut);

  final BaseAuth auth;
  final String userID;
  final VoidCallback signOut;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile _profile;
  DatabaseService database = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: StreamBuilder(
            stream: database.getProfileStream(widget.userID),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return new Text("Chargement ... ");
              }
              _profile = snapshot.data;
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
                  showOrganisations(),
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
                        onPressed: () => widget.signOut(),
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

  Widget showOrganisations() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Organisations',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              child: StreamBuilder(
                  stream: database.getMemberListStream(userID: widget.userID),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Text('No Member data for ${widget.userID}'),
                      );
                    } else {
                      List<Member> members = snapshot.data;
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            Member member = members[index];
                            return buildMember(context, member);
                          });
                    }
                  }),
            ),
            Center(
              child: OutlineButton.icon(
                onPressed: () =>
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CreateOrganisationScreen(widget.userID)),
                  ),
                },
                icon: Icon(
                  Icons.add,
                  color: Colors.blue.shade800,
                ),
                label: Text('Créer une organisation'),
              ),
            )
          ],
        ),
      ),
    );
  }

  updateGapYear(value) {
    DocumentReference ref =
        Firestore.instance.document("users/" + widget.userID);
    ref.updateData({"gapYear": value});
  }

  Widget buildMember(BuildContext context, Member member) {
    return StreamBuilder(
        stream: database.getOrganisationStream(member.organisationID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text('No Organisation Data for this member'),
            );
          } else {
            Organisation organisation = snapshot.data;
            return Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    organisation.getCircleAvatar(radius: 24.0),
                    SizedBox(
                      width: 8.0,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(organisation.fullName,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          if (member.position != '') Text(member.position),
                          Text(member.getRole()),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${organisation.members.length}',
                          style: TextStyle(
                              fontSize: 18.0, color: Colors.blue.shade800),
                        ),
                        Icon(
                          organisation.members.length == 1
                              ? Icons.person
                              : Icons.people,
                          color: Colors.blue.shade800,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }
}
