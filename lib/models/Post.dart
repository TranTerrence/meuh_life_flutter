import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/providers/CurrentUser.dart';
import 'package:meuh_life/screens/comment_screen.dart';
import 'package:meuh_life/screens/edit_post_screen.dart';
import 'package:meuh_life/screens/image_view_screen.dart';
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

  int reactionCount;
  int commentCount;

  DateTime creationDate;
  static const double padding = 16.0;
  static const double avatarRadius = 20.0;

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
      this.creationDate,
      this.reactionCount,
      this.commentCount});

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
    reactionCount = document['reactionCount'] ?? 0;
    commentCount = document['commentCount'] ?? 0;
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
    reactionCount = document['reactionCount'] ?? 0;
    commentCount = document['commentCount'] ?? 0;

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

      case 'INTERNSHIP':
        {
          DateTime startDate = document['startDate'] != null
              ? document['startDate'].toDate()
              : null;
          DateTime endDate =
              document['endDate'] != null ? document['endDate'].toDate() : null;
          String location = document['location'];

          return this.toInternship(
              startDate: startDate, endDate: endDate, location: location);
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
      "reactionCount": this.reactionCount ?? 0,
      "commentCount": this.commentCount ?? 0
    };
  }

  Widget showHeaderRow(DatabaseService database) {
    return Column(
      children: <Widget>[
        this.asOrganisation == '' || this.asOrganisation == null
            ? showAuthorProfile(database)
            : showOrganisationProfile(database),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    this.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 24.0),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 8.0,
            ),
            if (this.type != null) TYPES_ICON[this.type],
          ],
        ),
      ],
    );
  }

  Widget showTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(padding, 0, padding, 0),
      child: Text(
        this.title,
        //maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 18.0),
      ),
    );
  }

  Widget showDescription() {
    if (this.description != null && this.description != '') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(padding, 0, padding, 0),
        child: Text(
          this.description,
          softWrap: true,
          //maxLines: 5,
          //overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14.0),
        ),
      );
    }
    return Container();
  }

  Widget showImage(BuildContext context) {
    if (this.imageURL != null && this.imageURL.length > 0)
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewScreen(imageURL: this.imageURL),
            ),
          );
        },
        child: Image(
          image: FirebaseImage(this.imageURL),
        ),
      );
    return Container();
  }

  Widget showCreationDate() {
    timeago.setLocaleMessages('fr_short', timeago.FrShortMessages());
    return Text(
      timeago.format(this.creationDate, locale: 'fr_short') ?? '',
      style: TextStyle(fontSize: 12.0),
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
            padding: const EdgeInsets.only(right: padding / 2),
            child: InkWell(
              onTap: () => profile.showDetailedDialog(context),
              child: getHeaderRow(
                  profile.getCircleAvatar(radius: avatarRadius),
                  '${profile.firstName} ${profile.lastName[0]}.'
                  ' (P${profile.promo})'),
            ),
          );
        });
  }

  Widget getHeaderRow(Widget circleAvatar, String authorName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        circleAvatar,
        SizedBox(
          width: 8.0,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                authorName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
              showCreationDate(),
            ],
          ),
        ),
        if (this.type != null) TYPES_ICON[this.type],
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
                child: getHeaderRow(
                    organisation.getCircleAvatar(radius: avatarRadius),
                    organisation.fullName)),
          );
        });
  }

  //TODO : Optimize this function the logic for likes is not good
  Widget showActionButtons(BuildContext context, CurrentUser currentUser) {
    bool isLiked;
    DatabaseService database = DatabaseService();

    bool isCurrentUser = this.author == currentUser.id;
    return ButtonBar(
      alignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        FutureBuilder(
            future: database.getCurrentUserReactionToPost(this.id),
            builder: (context, AsyncSnapshot<String> snapshot) {
              String reaction = snapshot.data;
              isLiked = reaction == 'piche';
              return Row(
                children: <Widget>[
                  LikeButton(
                      isLiked: isLiked,
                      onTap: (bool currentState) {
                        print('tapped');
                        return onLikeButtonTapped(currentState);
                      },
                      circleColor: CircleColor(
                          start: Colors.blue.shade800, end: Colors.blue),
                      bubblesColor: BubblesColor(
                        dotPrimaryColor: Colors.blue,
                        dotSecondaryColor: Colors.blue.shade800,
                      ),
                      likeBuilder: (bool isLiked) {
                        return Icon(
                          Icons.thumb_up,
                          color: isLiked ? Colors.blue.shade800 : Colors.grey,
                        );
                      },
                      likeCount: this.reactionCount ?? 0,
                      countBuilder: (int count, bool isLiked, String text) {
                        Color color =
                            isLiked ? Colors.blue.shade800 : Colors.grey;
                        Widget result = Text(
                          count > 0 ? text : '',
                          style: TextStyle(
                              color: color,
                              fontSize: 14.0,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w500),
                        );
                        return result;
                      }),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    'Piche',
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.0,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w500),
                  ),
                ],
              );
            }),
        FlatButton.icon(
          padding: EdgeInsets.all(8.0),
          textColor: Colors.grey,
          label: new Text('Commenter' +
              (this.commentCount != null && this.commentCount > 0
                  ? ' (${this.commentCount})'
                  : '')),
          icon: Icon(Icons.comment),
          onPressed: () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommentScreen(post: this),
                ),
              ),
        ),
        if (isCurrentUser)
          IconButton(
            padding: EdgeInsets.all(8.0),
            icon: Icon(
              Icons.edit,
              color: Colors.grey,
            ),
            onPressed: () =>
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditPostScreen(
                          post: this,
                          currentUser: currentUser,
                        ),
                  ),
                ),
          )
      ],
    );
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    String reaction = isLiked ? null : 'piche';
    DatabaseService database = DatabaseService();
    return database.updateReactionToPost(postID: this.id, reaction: reaction);
  }

  Widget getCard(BuildContext context, DatabaseService database,
      CurrentUser currentUser) {
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
          showTitle(),
          showDescription(),
          showImage(context),
          showActionButtons(context, currentUser),
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
        creationDate: this.creationDate,
        reactionCount: this.reactionCount,
        commentCount: this.commentCount);
  }

  Internship toInternship(
      {DateTime startDate, DateTime endDate, String location}) {
    return Internship(
        startDate: startDate,
        endDate: endDate,
        location: location,
        id: this.id,
        title: this.title,
        description: this.description,
        author: this.author,
        imageURL: this.imageURL,
        asOrganisation: this.asOrganisation,
        type: this.type,
        creationDate: this.creationDate,
        reactionCount: this.reactionCount,
        commentCount: this.commentCount);
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
    int reactionCount,
    int commentCount,
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
    reactionCount: reactionCount,
    commentCount: commentCount,
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
  Widget getCard(BuildContext context, DatabaseService database,
      CurrentUser currentUser) {
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
                child: this.asOrganisation == '' || this.asOrganisation == null
                    ? showAuthorProfile(database)
                    : showOrganisationProfile(database),
              ),
              if (this.location != '') showLocation(),
              showEventDate(),
              showPrice(),
              showTitle(),
              showDescription(),
              showImage(context),
              showActionButtons(context, currentUser),
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
            this.price == null ? "Gratuit" : '${this.price}€',
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

class Internship extends Post {
  DateTime startDate;
  DateTime endDate;
  String location;

  Internship({
    this.startDate,
    this.endDate,
    this.location,
    String id,
    String title,
    String description,
    String author,
    String imageURL,
    String asOrganisation,
    String type,
    int reactionCount,
    int commentCount,
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
    reactionCount: reactionCount,
    commentCount: commentCount,
  );

  Map<String, dynamic> toJson() {
    return {
      "startDate": this.startDate,
      "endDate": this.endDate,
      "location": this.location,
      ...super.toJson() //
    };
  }

  @override
  Widget getCard(BuildContext context, DatabaseService database,
      CurrentUser currentUser) {
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
                child: this.asOrganisation == '' || this.asOrganisation == null
                    ? showAuthorProfile(database)
                    : showOrganisationProfile(database),
              ),
              if (this.location != '' && this.location != null) showLocation(),
              showInternshipDate(),
              showTitle(),
              showDescription(),
              showImage(context),
              showActionButtons(context, currentUser),
            ],
          )
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

  Widget showInternshipDate() {
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
