import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meuh_life/components/RoundedDialog.dart';
import 'package:meuh_life/models/ChatRoom.dart';
import 'package:meuh_life/models/Member.dart';
import 'package:meuh_life/providers/CurrentUser.dart';
import 'package:meuh_life/screens/conversation_screen.dart';
import 'package:meuh_life/screens/image_view_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';
import 'package:meuh_life/services/utils.dart';
import 'package:provider/provider.dart';

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
    this.picUrl = createPicUrl(lastName, promo, type);
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

  Profile.fromJSON(Map map) {
    this.id = map['id'];
    this.email = map['email'];
    this.promo = map['promo'];
    this.firstName = map['firstName'];
    this.lastName = map['lastName'];
    this.picUrl = map['picUrl'];
    this.gapYear = map['gapYear'];
    this.isEmailVerified = map['isEmailVerified'];
    this.description = map['description'];
    this.isPAM = map['isPAM'];
    this.creationDate =
        map['creationDate'] != null ? map['creationDate'] : null;
    this.type = map['type'];
  }

  toJson() {
    return {
      "id": this.id,
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

  String get fullName {
    return this.firstName + ' ' + this.lastName;
  }

  String getType() {
    return types[this.type];
  }

  String get promoWithP {
    return 'P${this.promo}';
  }

  String getNameInitials() {
    return this.firstName[0] + this.lastName[0];
  }

  Widget getCircleAvatar({double radius = 60.0}) {
    Widget defaultAvatar = CircleAvatar(
      radius: radius,
      backgroundColor: Colors.blue.shade800,
      child: Text(
        this.getNameInitials(),
        style: TextStyle(
          fontSize: radius,
          color: Colors.white,
        ),
      ),
    );
    if (this.picUrl == null || this.picUrl == '') return defaultAvatar;
    if (this.picUrl.startsWith('gs://')) {
      return CircleAvatar(
        backgroundImage: FirebaseImage(this.picUrl),
        radius: radius,
      );
    } else {
      return CachedNetworkImage(
          imageUrl: this.picUrl,
          imageBuilder: (context, imageProvider) => Container(
                width: radius * 2,
                height: radius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image:
                      DecorationImage(image: imageProvider, fit: BoxFit.cover),
                ),
              ),
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => defaultAvatar);
    }
  }

  Widget showPromo() {
    return Expanded(
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('P' + this.promo),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showType() {
    return Card(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Parcours',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(this.getType()),
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
                  Text(this.gapYear ? 'Oui' : 'Non'),
                ],
              ),
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
                  Text(this.isPAM ? 'Oui' : 'Non'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showDetailedDialog(BuildContext context) async {
    DatabaseService database = DatabaseService();
    CurrentUser currentUser = Provider.of<CurrentUser>(context, listen: false);

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return RoundedDialog(
          circleAvatar: InkWell(
              onTap: () {
                if (this.picUrl != null && this.picUrl != '') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ImageViewScreen(imageURL: this.picUrl),
                    ),
                  );
                }
              },
              child: this.getCircleAvatar(radius: 60.0)),
          circleRadius: 60.0,
          content: Column(
            children: <Widget>[
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Center(
                      child: Text(
                        this.fullName + ' (${this.promoWithP})',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (this.description != '')
                      Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                          child: Text(
                            this.description,
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          )),
                    showType(),
                    Row(
                      children: <Widget>[
                        showGapYear(),
                        showIsPAM(),
                      ],
                    ),
                    Text(
                      'Organisations',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    StreamBuilder(
                        stream: database.getMemberListStream(
                            on: 'userID', onValueEqualTo: this.id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: Text(
                                  'No Member data for organisation  ${this.id}'),
                            );
                          } else {
                            List<Member> members = snapshot.data;
                            return ListView.builder(
                                shrinkWrap: true,
                                itemCount: members.length,
                                itemBuilder: (context, index) {
                                  Member member = members[index];
                                  return member
                                      .getListItemOrganisation(database);
                                });
                          }
                        }),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        print('Click talk with ..');
                        String chatRoomID = getMixKey(this.id, currentUser.id);
                        ChatRoom chatRoom = ChatRoom(
                            id: chatRoomID,
                            type: "SINGLE_USER",
                            users: [this.id, currentUser.id]);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ConversationScreen(
                                    chatRoom: chatRoom,
                                    userID: currentUser.id,
                                    toProfile: this,
                                  )),
                        ); // To close the dialog
                      },
                      child: Text(
                        'Contacter',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // To close the dialog
                      },
                      child: Text(
                        'Fermer',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

String createPicUrl(String lastName, String promo, String type) {
  String lName = capitalize(lastName);
  String picUrlNameTemp = lName.replaceAll("-", "");
  String picUrlName;
  String i = '';
  if (picUrlNameTemp.length > 8) {
    picUrlName = picUrlNameTemp.substring(0, 8).toLowerCase();
  } else {
    picUrlName = picUrlNameTemp.toLowerCase();
  }
  if (type == 'ISUPFERE') i = 'i';
  return 'https://eleves.mines-paris.eu/static//img/trombi/$i$promo$picUrlName.jpg';
}

String capitalize(String s) =>
    s[0].toUpperCase() + s.substring(1).toLowerCase();
