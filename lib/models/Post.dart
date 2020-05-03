import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String key;
  String title;
  String description;
  String author;
  DateTime creationDate;
  DateTime startDate;
  DateTime endDate;

  Post();

  Post.create({this.startDate});

  Post.fromDocSnapshot(DocumentSnapshot document) {
    key = document.documentID;
    title = document['title'];
    description = document['description'];
    author = document['author'];
    creationDate = document['creationDate'] != null
        ? document['creationDate'].toDate()
        : null;
    startDate =
        document['startDate'] != null ? document['startDate'].toDate() : null;
    endDate = document['endDate'] != null ? document['endDate'].toDate() : null;
  }

  toJson() {
    return {
      "title": this.title,
      "description": this.description,
      "author": this.author,
      "creationDate": FieldValue.serverTimestamp(),
      "startDate": this.startDate,
      "endDate": this.endDate
    };
  }
}
