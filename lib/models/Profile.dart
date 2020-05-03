import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  bool isEmailVerified = false;
  bool gapYear = false;

  Profile(String firstName, String lastName, String promo, bool gapYear) {
    this.email =
        (firstName + '.' + lastName + '@mines-paristech.fr').toLowerCase();
    this.promo = promo;
    this.firstName = capitalize(firstName);
    this.lastName = capitalize(lastName);
    this.picUrl = createPicUrl(lastName, promo);
    this.gapYear = gapYear;
    this.isEmailVerified = false;
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
      "description": this.description
    };
  }

  String getFullName() {
    return this.firstName + ' ' + this.lastName;
  }

  String getNameInitials() {
    return this.firstName[0] + this.lastName[0];
  }

  Widget getCircleAvatar({double radius = 120.0}) {
    return CachedNetworkImage(
      imageUrl: this.picUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: radius,
        height: radius,
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
        radius: radius / 2,
        backgroundColor: Colors.blue.shade800,
        child: Text(
          this.getNameInitials(),
          style: TextStyle(
            fontSize: radius / 2,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

createPicUrl(lastName, promo) {
  String lName = capitalize(lastName);
  String picUrlNameTemp = lName.replaceAll("-", "");
  String picUrlName;
  if (picUrlNameTemp.length > 8) {
    picUrlName = picUrlNameTemp.substring(0, 8).toLowerCase();
  } else {
    picUrlName = picUrlNameTemp.toLowerCase();
  }
  return 'https://eleves.mines-paris.eu/static//img/trombi/' +
      promo +
      picUrlName +
      '.jpg';
}

String capitalize(String s) =>
    s[0].toUpperCase() + s.substring(1).toLowerCase();
