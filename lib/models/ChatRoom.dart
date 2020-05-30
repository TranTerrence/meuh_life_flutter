import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  String id; //If not a groupchat, then use the concat of the 2 userID
  String roomName; // null if !isChatGroup in the DB
  String lastMessage;
  String imageURL; // null if !isChatGroup in the DB
  String creatorID;
  bool isChatGroup;
  List<String> users;
  DateTime lastMessageDate;
  DateTime creationDate;

  ChatRoom(
      {this.id,
      this.roomName,
      this.lastMessage,
      this.imageURL,
      this.creatorID,
      this.isChatGroup,
      this.users,
      this.lastMessageDate,
      this.creationDate});

  Map<String, dynamic> toJson() {
    return {
      "roomName": this.roomName,
      "lastMessage": this.lastMessage,
      "imageURL": this.imageURL,
      "creatorID": this.creatorID,
      "isChatGroup": this.isChatGroup,
      "users": this.users,
      "lastMessageDate": this.lastMessageDate ?? FieldValue.serverTimestamp(),
      "creationDate": this.creationDate ?? FieldValue.serverTimestamp()
    };
  }

  ChatRoom.fromDocSnapshot(DocumentSnapshot document) {
    print(document.data.toString());
    id = document.documentID;
    roomName = document['roomName'];
    lastMessage = document['lastMessage'];
    imageURL = document['imageURL'];
    creatorID = document['creatorID'];
    isChatGroup = document['isChatGroup'];
    users = List<String>.from(document['users']); //
    lastMessageDate = document['lastMessageDate'] != null
        ? document['lastMessageDate'].toDate()
        : null;
    creationDate = document['creationDate'] != null
        ? document['creationDate'].toDate()
        : null;
  }

  String getToUserID(String currentUserID) {
    if (this.isChatGroup) {
      throw Exception('Try to get ToUserID of a chatGroup');
    } else {
      for (var i = 0; i < users.length; i++) {
        String userID = users[i];
        if (currentUserID != userID) return userID;
      }

      return currentUserID;
    }
  }
}
