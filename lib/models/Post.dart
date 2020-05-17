import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/services/DatabaseService.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'Profile.dart';

class Post {
  String id;
  String title;
  String description;
  String author;
  String imageURL;

  String asOrganisation;
  String type = 'ANNOUNCE';

  DateTime creationDate;
  static const double padding = 16.0;

  static const TYPES = {
    'EVENT': 'Evénement',
    'ANNOUNCE': 'Annonce',
    'MEMES': 'Memes',
    'INTERNSHIP': 'Stage'
  };

  static var TYPES_ICON = {
    'EVENT': Icon(
      Icons.event,
      color: Colors.blue.shade800,
    ),
    'ANNOUNCE': Icon(
      Icons.announcement,
      color: Colors.blue.shade800,
    ),
    'MEMES': Icon(
      Icons.color_lens,
      color: Colors.blue.shade800,
    ),
    'INTERNSHIP': Icon(Icons.work, color: Colors.blue.shade800),
  };

  Post(
      {this.id,
      this.title,
      this.description,
      this.author,
      this.imageURL,
      this.asOrganisation,
      this.type,
      this.creationDate});

  Post.fromDocSnapshot(DocumentSnapshot document) {
    id = document.documentID;
    title = document['title'];
    description = document['description'];
    author = document['author'];
    imageURL = document['imageURL'];
    asOrganisation = document['asOrganisation'];
    type = document['type'];
    creationDate = document['creationDate'] != null
        ? document['creationDate'].toDate()
        : null;
  }

  Post castFromDocSnapshot(DocumentSnapshot document) {
    id = document.documentID;
    title = document['title'];
    description = document['description'];
    author = document['author'];
    imageURL = document['imageURL'];
    asOrganisation = document['asOrganisation'];
    type = document['type'];
    creationDate = document['creationDate'] != null
        ? document['creationDate'].toDate()
        : null;
    switch (type) {
      case 'EVENT':
        {
          DateTime startDate = document['startDate'] != null
              ? document['startDate'].toDate()
              : null;
          DateTime endDate =
          document['endDate'] != null ? document['endDate'].toDate() : null;
          double price = document['price'];
          String location = document['location'];

          return this.toEvent(
              startDate: startDate,
              endDate: endDate,
              price: price,
              location: location);
        }
        break;
    }
    return this;
  }

  String getType() {
    return TYPES[this.type];
  }

  Map<String, dynamic> toJson() {
    return {
      "title": this.title,
      "description": this.description,
      "author": this.author,
      "creationDate": this.creationDate ?? FieldValue.serverTimestamp(),
      "type": this.type,
      "asOrganisation": this.asOrganisation,
      "imageURL": this.imageURL,
    };
  }

  Widget showTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        if (this.type != null) TYPES_ICON[this.type],
        SizedBox(
          width: 8.0,
        ),
        Expanded(
          child: Text(
            this.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 24.0),
          ),
        ),
      ],
    );
  }

  Widget showDescription() {
    if (this.description != null && this.description != '') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(padding, 0, padding, 0),
        child: Text(
          this.description,
          softWrap: true,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }
    return Container();
  }

  Widget showImage() {
    if (this.imageURL != null && this.imageURL.length > 0)
      return Image(
        image: FirebaseImage(this.imageURL),
      );
    return Container();
  }

  Widget showCreationDate() {
    timeago.setLocaleMessages('fr_short', timeago.FrShortMessages());
    return Padding(
      padding: const EdgeInsets.only(left: padding),
      child: Text(
        timeago.format(this.creationDate, locale: 'fr_short') ?? '',
        textAlign: TextAlign.center,
      ),
    );
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
            padding:
            const EdgeInsets.only(top: padding / 2, right: padding / 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                profile.getCircleAvatar(radius: 18.0),
                SizedBox(
                  width: 8.0,
                ),
                Text(
                  '${profile.firstName} ${profile.lastName[0]}.'
                      '\n(P${profile.promo})',
                ),
              ],
            ),
          );
        });
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
            padding:
            const EdgeInsets.only(top: padding / 2, right: padding / 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                organisation.getCircleAvatar(radius: 18.0),
                SizedBox(
                  width: 8.0,
                ),
                Text(
                  organisation.fullName,
                ),
              ],
            ),
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
            child: showTitleRow(),
          ),
          showDescription(),
          showImage(),
          this.asOrganisation == '' || this.asOrganisation == null
              ? showAuthorProfile(database)
              : showOrganisationProfile(database),
          showCreationDate(),
        ],
      ),
    );
  }

  Event toEvent(
      {DateTime startDate, DateTime endDate, double price, String location}) {
    return Event(
        startDate: startDate,
        endDate: endDate,
        price: price,
        location: location,
        id: this.id,
        title: this.title,
        description: this.description,
        author: this.author,
        imageURL: this.imageURL,
        asOrganisation: this.asOrganisation,
        type: this.type,
        creationDate: this.creationDate);
  }
}

class Event extends Post {
  DateTime startDate;
  DateTime endDate;
  double price;
  String location;

  Event({
    this.startDate,
    this.endDate,
    this.price,
    this.location,
    String id,
    String title,
    String description,
    String author,
    String imageURL,
    String asOrganisation,
    String type,
    DateTime creationDate,
  }) : super(
    id: id,
    title: title,
    description: description,
    author: author,
    imageURL: imageURL,
    asOrganisation: asOrganisation,
    type: type,
    creationDate: creationDate,
  );

  Map<String, dynamic> toJson() {
    return {
      "startDate": this.startDate,
      "endDate": this.endDate,
      "price": this.price,
      "location": this.location,
      ...super.toJson() //
    };
  }

  @override
  Widget getCard(BuildContext context, DatabaseService database) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(Post.padding),
                child: showTitleRow(),
              ),
              showLocation(),
              showEventDate(),
              showPrice(),
              showDescription(),
              showImage(),
              this.asOrganisation == '' || this.asOrganisation == null
                  ? showAuthorProfile(database)
                  : showOrganisationProfile(database),
              showCreationDate(),
            ],
          )
        ],
      ),
    );
  }

  Widget showPrice() {
    return Padding(
      padding: const EdgeInsets.only(left: Post.padding),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.euro_symbol,
            color: Colors.blue.shade800,
            size: 16.0,
          ),
          SizedBox(
            width: Post.padding / 2,
          ),
          Text(
            '${this.price}€',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget showLocation() {
    return Padding(
      padding: const EdgeInsets.only(left: Post.padding),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.place,
            color: Colors.blue.shade800,
            size: 16.0,
          ),
          SizedBox(
            width: Post.padding / 2,
          ),
          Text(this.location),
        ],
      ),
    );
  }

  Widget showEventDate() {
    timeago.setLocaleMessages('fr_short', timeago.FrShortMessages());
    DateFormat format = DateFormat('dd/MM à HH:mm');

    return Padding(
      padding: const EdgeInsets.only(left: Post.padding),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.access_time,
            color: Colors.blue.shade800,
            size: 16.0,
          ),
          SizedBox(
            width: Post.padding / 2,
          ),
          Text(
            format.format(this.startDate) + ' - ' ?? '',
            textAlign: TextAlign.center,
          ),
          Text(
            format.format(this.endDate) ?? '',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// START all the widget layout for the getCard
