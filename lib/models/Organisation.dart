import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Organisation {
  String id = '';
  String email = ''; //Always like name.lastname@mines-paristech.fr
  String fullName = '';
  String imageURL = '';
  String description = '';
  String creatorID = ''; //userID of the creator
  List<String> members = []; // List of members
  bool isVerified = false;

  Organisation();

  Organisation.fromDocSnapshot(DocumentSnapshot document) {
    this.id = document.documentID;
    this.fullName = document['fullName'];
    this.imageURL = document['imageURL'];
    this.description = document['description'];
    this.creatorID = document['creatorID']; //userID of the creator
    this.isVerified = document['isVerified'];
    this.members = List<String>.from(document['members']); // List of members
  }

  addMember(String memberID) {
    if (!this.members.contains(memberID)) {
      this.members.add(memberID);
    }
  }

  removeMember(String memberID) {
    this.members.remove(memberID);
  }

  Widget getCircleAvatar({double radius = 60.0}) {
    if (this.imageURL != null && this.imageURL.length > 2) {
      return CircleAvatar(
        backgroundImage: FirebaseImage(this.imageURL),
        radius: radius,
      );
    } else {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue.shade800,
        child: Center(
          child: (this.fullName.length > 0)
              ? Text(
                  this.fullName,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: radius / 2,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.clip,
                )
              : Icon(
                  Icons.photo,
                  color: Colors.amber.shade800,
                  size: 32.0,
                ),
        ),
      );
    }
  }

  toJson() {
    return {
      "id": this.id,
      "email": this.email, //Always like name.lastname@mines-paristech.fr
      "fullName": this.fullName,
      "imageURL": this.imageURL,
      "description": this.description,
      "creatorID": this.creatorID, //userID of the creator
      "members": this.members,
      "isVerified": this.isVerified
    };
  }
}

class Member {
  // Keys : value to show, only the keys should be saved, the value serves only the UI
  static const roles = {
    'Admin': 'Admin',
    'Member': 'Membre',
    'Owner': 'Propriétaire',
    'Publisher': 'Publisher'
  };

  String id = '';
  String userID = ''; // userID of the member
  String organisationID = 'Oganisation ID';
  String role = 'Member';
  String position = ''; // President, tresorier ,...
  String addedBy = '';
  DateTime joiningDate = DateTime.now();

  Member.fromUserID(String userID) {
    this.userID = userID;
  }

  Member.fromDocSnapshot(DocumentSnapshot document) {
    this.id = document.documentID;
    this.userID = document['userID']; // userID of the member
    this.organisationID = document['organisationID'];
    this.role = document['role'];
    this.position = document['position']; // President, tresorier ,...
    this.addedBy = document['addedBy'];
    this.joiningDate = document['joiningDate'] != null
        ? document['joiningDate'].toDate()
        : null;
  }

  String getRole() {
    return roles[this.role];
  }

  toJson() {
    return {
      "id": this.id,
      "userID": this.userID,
      "organisationID": this.organisationID,
      "role": this.role,
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
      case 'position':
        return this.position;
      case 'joiningDate':
        return this.joiningDate;
    }
  }
}
