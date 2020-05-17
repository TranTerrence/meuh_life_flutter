import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Profile {
  String id = '';
  String email = ''; //Always like name.lastname@mines-paristech.fr
  String promo = '';
  String firstName = '';
  String lastName = '';
  String picUrl = '';
  String description = '';
  String type = 'ENGINEER';

  DateTime creationDate;

  bool isEmailVerified = false;
  bool gapYear = false;
  bool isPAM = false;

  static const types = {
    'ENGINEER': 'Cycle ingénieur',
    'ISUPFERE': 'ISUPFERE',
    'MASTER': 'Master spécialisé',
  };

  Profile(
      {String id,
      String promo,
      String firstName,
      String lastName,
      String picUrl,
      String description,
      String type,
      DateTime creationDate,
      bool isEmailVerified,
      bool gapYear,
      bool isPAM}) {
    this.email =
        (firstName + '.' + lastName + '@mines-paristech.fr').toLowerCase();
    this.promo = promo;
    this.firstName = capitalize(firstName);
    this.lastName = capitalize(lastName);
    this.picUrl = createPicUrl(lastName, promo);
    this.type = type;
    this.creationDate = creationDate;
    this.gapYear = gapYear;
    this.isEmailVerified = false;
    this.isPAM = isPAM;
  }

  Profile.fromDocSnapshot(DocumentSnapshot document) {
    this.id = document.documentID;
    this.email = document['email'];
    this.promo = document['promo'];
    this.firstName = document['firstName'];
    this.lastName = document['lastName'];
    this.picUrl = document['picUrl'];
    this.gapYear = document['gapYear'];
    this.isEmailVerified = document['isEmailVerified'];
    this.description = document['description'];
    this.isPAM = document['isPAM'];
    this.creationDate = document['creationDate'] != null
        ? document['creationDate'].toDate()
        : null;
    this.type = document['type'];
  }

  toJson() {
    return {
      "id": this.id = '',
      "email": this.email,
      "promo": this.promo,
      "firstName": this.firstName,
      "lastName": this.lastName,
      "picUrl": this.picUrl,
      "gapYear": this.gapYear,
      "isEmailVerified": this.isEmailVerified,
      "description": this.description,
      "isPAM": this.isPAM,
      "type": this.type,
      "creationDate": this.creationDate ?? FieldValue.serverTimestamp(),
    };
  }

  String getFullName() {
    return this.firstName + ' ' + this.lastName;
  }

  String getType() {
    return types[this.type];
  }

  String getPromo() {
    return 'P${this.promo}';
  }

  String getNameInitials() {
    return this.firstName[0] + this.lastName[0];
  }

  Widget getCircleAvatar({double radius = 60.0}) {
    if (this.picUrl.startsWith('gs://')) {
      return CircleAvatar(
        backgroundImage: FirebaseImage(this.picUrl),
        radius: radius,
      );
    }
    return CachedNetworkImage(
      imageUrl: this.picUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: Colors.blue.shade800,
        child: Text(
          this.getNameInitials(),
          style: TextStyle(
            fontSize: radius,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

String createPicUrl(String lastName, String promo) {
  String lName = capitalize(lastName);
  String picUrlNameTemp = lName.replaceAll("-", "");
  String picUrlName;
  if (picUrlNameTemp.length > 8) {
    picUrlName = picUrlNameTemp.substring(0, 8).toLowerCase();
  } else {
    picUrlName = picUrlNameTemp.toLowerCase();
  }
  return 'https://eleves.mines-paris.eu/static//img/trombi/$promo$picUrlName.jpg';
}

String capitalize(String s) =>
    s[0].toUpperCase() + s.substring(1).toLowerCase();
