import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/services/DatabaseService.dart';

class Member {
  // Keys : value to show, only the keys should be saved, the value serves only the UI
  static const roles = {
    'Owner': 'Propriétaire',
    'Admin': 'Admin',
    'Publisher': 'Publisher',
    'Member': 'Membre',
  };

  static const states = {
    'Requested': 'Demande envoyée',
    'Accepted': 'Accepté',
  };

  String id;
  String userID = ''; // userID of the member
  String organisationID = 'Oganisation ID';
  String role = 'Member';
  String state = 'Accepted';

  String position = ''; // President, tresorier ,...
  String addedBy = '';
  DateTime joiningDate = DateTime.now();

  Member(
      {this.id,
      this.userID,
      this.organisationID,
      this.role,
      this.position,
      this.addedBy,
      this.joiningDate,
      this.state});

  Member.fromUserID(String userID) {
    this.userID = userID;
  }

  Member.fromDocSnapshot(DocumentSnapshot document) {
    this.id = document.documentID;
    this.userID = document['userID']; // userID of the member
    this.organisationID = document['organisationID'];
    this.role = document['role'];
    this.state = document['state'] ?? 'Accepted';
    this.position = document['position']; // President, tresorier ,...
    this.addedBy = document['addedBy'];
    this.joiningDate = document['joiningDate'] != null
        ? document['joiningDate'].toDate()
        : null;
  }

  Member.fromMap(Map<String, dynamic> map, String memberID) {
    this.id = memberID;
    this.userID = map['userID']; // userID of the member
    this.organisationID = map['organisationID'];
    this.role = map['role'];
    this.state = map['state'];
    this.position = map['position']; // President, tresorier ,...
    this.addedBy = map['addedBy'];
    //this.joiningDate = map['joiningDate'] != null ? map['joiningDate'].toDate() : null;
  }

  Widget getListItemProfile(DatabaseService database) {
    return StreamBuilder(
        stream: database.getProfileStream(this.userID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text('No Data for this member'),
            );
          } else {
            Profile profile = snapshot.data;
            return Container(
              padding: EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  profile.getCircleAvatar(radius: 24.0),
                  SizedBox(
                    width: 8.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        profile.fullName + ' (${profile.promoWithP})',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (this.position != '') Text(this.position)
                    ],
                  ),
                ],
              ),
            );
          }
        });
  }

  Widget getListItemOrganisation(DatabaseService database) {
    return StreamBuilder(
        stream: database.getOrganisationStream(this.organisationID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text('No Data for this member'),
            );
          } else {
            Organisation organisation = snapshot.data;
            return Container(
              padding: EdgeInsets.only(top: 8.0),
              child: Row(
                children: <Widget>[
                  organisation.getCircleAvatar(radius: 24.0),
                  SizedBox(
                    width: 8.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        organisation.fullName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (this.position != '') Text(this.position)
                    ],
                  ),
                ],
              ),
            );
          }
        });
  }

  String getRole() {
    return roles[this.role];
  }

  Future<Organisation> getOrganisation() async {
    DatabaseService database = DatabaseService();
    Organisation orga = await database.getOrganisation(this.organisationID);
    return orga;
  }

  toJson() {
    return {
      "userID": this.userID,
      "organisationID": this.organisationID,
      "role": this.role,
      "state": this.state,
      "position": this.position,
      "addedBy": this.addedBy,
      "joiningDate": this.joiningDate
    };
  }

  operator [](String key) {
    switch (key) {
      case 'id':
        return this.id;
      case 'userID':
        return this.userID;
      case 'organisationID':
        return this.organisationID;
      case 'role':
        return this.role;
      case 'state':
        return this.state;
      case 'position':
        return this.position;
      case 'joiningDate':
        return this.joiningDate;
    }
  }
}

class Consts {
  Consts._();

  static const double padding = 16.0;
  static const double avatarRadius = 60.0;
}
