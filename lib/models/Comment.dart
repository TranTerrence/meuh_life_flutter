import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meuh_life/services/DatabaseService.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'Organisation.dart';
import 'Profile.dart';

class Comment {
  String id;
  String text;
  String author;
  String asOrganisation = ''; // let '' for No organisation

  DateTime creationDate;
  static const double padding = 16.0;
  static const double avatarRadius = 20.0;

  Comment(
      {this.id,
      this.text,
      this.author,
      this.asOrganisation,
      this.creationDate});

  Map<String, dynamic> toJson() {
    return {
      "text": this.text,
      "author": this.author,
      "asOrganisation": this.asOrganisation,
      "creationDate": this.creationDate ?? FieldValue.serverTimestamp(),
    };
  }

  Comment.fromDocSnapshot(DocumentSnapshot document) {
    this.id = document.documentID;
    this.text = document['text'];
    this.author = document['author'];
    this.asOrganisation = document['asOrganisation'];
    this.creationDate = document['creationDate'] != null
        ? document['creationDate'].toDate()
        : null;
  }

  Widget showAuthorProfile(DatabaseService database) {
    return StreamBuilder(
        stream: database.getProfileStream(this.author),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text("Chargement ... ");
          }
          Profile profile = snapshot.data;
          return Padding(
            padding: const EdgeInsets.only(right: padding / 2),
            child: InkWell(
              onTap: () => profile.showDetailedDialog(context),
              child: getMainContent(
                  profile.getCircleAvatar(radius: avatarRadius),
                  '${profile.firstName} ${profile.lastName[0]}.'),
            ),
          );
        });
  }

  Widget getMainContent(Widget circleAvatar, String authorName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        circleAvatar,
        SizedBox(
          width: 8.0,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SelectableText.rich(
                TextSpan(
                  style: new TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    new TextSpan(
                        text: authorName + ' ',
                        style: new TextStyle(fontWeight: FontWeight.bold)),
                    new TextSpan(
                      text: this.text,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              showCreationDate(),
            ],
          ),
        ),
      ],
    );
  }

  Widget showOrganisationProfile(DatabaseService database) {
    return StreamBuilder(
        stream: database.getOrganisationStream(this.asOrganisation),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text("Chargement ... ");
          }
          Organisation organisation = snapshot.data;
          return Padding(
            padding: const EdgeInsets.only(right: padding / 2),
            child: InkWell(
                onTap: () =>
                    organisation.showDetailedDialog(context, organisation),
                child: getMainContent(
                    organisation.getCircleAvatar(radius: avatarRadius),
                    organisation.fullName)),
          );
        });
  }

  Widget getCard(BuildContext context, DatabaseService database) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(padding),
            child: this.asOrganisation == '' || this.asOrganisation == null
                ? showAuthorProfile(database)
                : showOrganisationProfile(database),
          ),
        ],
      ),
    );
  }

  Widget showCreationDate() {
    timeago.setLocaleMessages('fr_short', timeago.FrShortMessages());
    if (this.creationDate != null) {
      return Text(
        timeago.format(this.creationDate, locale: 'fr_short') ?? '',
        style: TextStyle(fontSize: 12.0),
      );
    } else {
      return CircularProgressIndicator();
    }
  }
}
