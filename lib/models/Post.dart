import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  String id;
  String title;
  String description;
  String author;
  String imageURL;
  DateTime creationDate;
  DateTime startDate;
  DateTime endDate;

  Post();

  Post.create({this.startDate});

  Post.fromDocSnapshot(DocumentSnapshot document) {
    id = document.documentID;
    title = document['title'];
    description = document['description'];
    author = document['author'];
    imageURL = document['imageURL'];
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
      "imageURL": this.imageURL,
      "startDate": this.startDate,
      "endDate": this.endDate
    };
  }
}
