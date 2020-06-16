import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String id;
  String content;
  String author; // userID of  the author
  String
      organisationID; // not null if it's sent from an organisation (= asOrganisation == true)
  bool asOrganisation = false;
  String imageURL;
  String type = "TEXT";

  DateTime creationDate;

  static const TYPES = {
    'TEXT': 'TEXT',
    'IMAGE': 'IMAGE',
  };

  Message(
      {this.id,
      this.content,
      this.author,
        this.organisationID,
        this.asOrganisation,
      this.imageURL,
      this.type,
      this.creationDate});

  Message.fromDocSnapshot(DocumentSnapshot document) {
    this.id = document.documentID;
    this.content = document['content'];
    this.author = document['author'];
    this.organisationID = document['organisationID'];
    this.asOrganisation = document['asOrganisation'];
    this.imageURL = document['imageURL'];
    this.type = document['type'];
    this.creationDate = document['creationDate'] != null
        ? document['creationDate'].toDate()
        : null;
  }

  Map<String, dynamic> toJson() {
    return {
      "content": this.content,
      "author": this.author,
      "organisationID": this.organisationID,
      "asOrganisation": this.asOrganisation,
      "imageURL": this.imageURL,
      "type": this.type,
      "creationDate": this.creationDate
    };
  }
}
