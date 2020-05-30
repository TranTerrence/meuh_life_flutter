import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meuh_life/components/RoundedDialog.dart';
import 'package:meuh_life/models/Member.dart';
import 'package:meuh_life/screens/image_view_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';

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

  Organisation.fromMap(Map<String, dynamic> map, String organisationID) {
    this.id = organisationID;
    this.fullName = map['fullName'];
    this.imageURL = map['imageURL'];
    this.description = map['description'];
    this.creatorID = map['creatorID']; //userID of the creator
    this.isVerified = map['isVerified'];
    this.members = List<String>.from(map['members']); // List of members
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
                  color: Colors.white,
                  size: 32.0,
                ),
        ),
      );
    }
  }

  Future<void> showDetailedDialog(
      BuildContext context, Organisation organisation) async {
    DatabaseService database = DatabaseService();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return RoundedDialog(
          circleAvatar: InkWell(
              onTap: () {
                if (this.imageURL != null && this.imageURL != '') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ImageViewScreen(imageURL: this.imageURL),
                    ),
                  );
                }
              },
              child: organisation.getCircleAvatar(radius: 60.0)),
          circleRadius: 60.0,
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Center(
                child: Text(
                  organisation.fullName,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                organisation.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 24.0),
              Text(
                'Membres',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              StreamBuilder(
                  stream: database.getMemberListStream(
                      on: 'organisationID', onValueEqualTo: organisation.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Text(
                            'No Member data for organisation  ${organisation
                                .id}'),
                      );
                    } else {
                      List<Member> members = snapshot.data;
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            Member member = members[index];
                            return member.getListItemProfile(database);
                          });
                    }
                  }),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // To close the dialog
                  },
                  child: Text(
                    'Fermer',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  Widget getListItem() {
    return Container(
      padding: EdgeInsets.only(top: 8.0),
      child: Row(
        children: <Widget>[
          this.getCircleAvatar(radius: 24.0),
          SizedBox(
            width: 8.0,
          ),
          Text(
            this.fullName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
