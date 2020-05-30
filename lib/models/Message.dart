import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String id;
  String content;
  String author; // userID of  the author
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
      this.imageURL,
      this.type,
      this.creationDate});

  Message.fromDocSnapshot(DocumentSnapshot document) {
    this.id = document.documentID;
    this.content = document['content'];
    this.author = document['author'];
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
      "imageURL": this.imageURL,
      "type": this.type,
      "creationDate": this.creationDate
    };
  }
}
