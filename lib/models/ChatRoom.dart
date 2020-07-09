import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  String
      id; //If not a groupchat, then use the concat of the 2 userID or USerid + orgaID
  String roomName; // null if !isChatGroup in the DB
  String lastMessage;
  String imageURL; // null if !isChatGroup in the DB
  String creatorID;
  String type = "SINGLE_USER";
  List<String> users;
  List<String> organisations;
  DateTime lastMessageDate;
  DateTime creationDate;

  static const TYPES = {
    'SINGLE_USER': 'SINGLE_USER', // One user to another one
    'SINGLE_ORGANISATION':
        'SINGLE_ORGANISATION', // One user to One organisation
    'GROUP': 'GROUP', //A Group of multiple people and/or organisations
  };

  ChatRoom(
      {this.id,
      this.roomName,
      this.lastMessage,
      this.imageURL,
      this.creatorID,
      this.type,
      this.users,
      this.organisations,
      this.lastMessageDate,
      this.creationDate});

  Map<String, dynamic> toJson() {
    return {
      "roomName": this.roomName,
      "lastMessage": this.lastMessage,
      "imageURL": this.imageURL,
      "creatorID": this.creatorID,
      "type": this.type,
      "users": this.users,
      "organisations": this.organisations,
      "lastMessageDate": this.lastMessageDate ?? FieldValue.serverTimestamp(),
      "creationDate": this.creationDate ?? FieldValue.serverTimestamp()
    };
  }

  ChatRoom.fromDocSnapshot(DocumentSnapshot document) {
    id = document.documentID;
    roomName = document['roomName'];
    type = document['type'];
    lastMessage = document['lastMessage'];
    imageURL = document['imageURL'];
    creatorID = document['creatorID'];
    users = List<String>.from(document['users']);
    if (type == 'SINGLE_ORGANISATION' || type == 'GROUP') {
      organisations = List<String>.from(document['organisations']); //
    }
    lastMessageDate = document['lastMessageDate'] != null
        ? document['lastMessageDate'].toDate()
        : null;
    creationDate = document['creationDate'] != null
        ? document['creationDate'].toDate()
        : null;
  }

  ChatRoom.fromMap(Map<String, dynamic> map, String chatRoomID) {
    this.id = chatRoomID;
    roomName = map['roomName'];
    type = map['type'];
    lastMessage = map['lastMessage'];
    imageURL = map['imageURL'];
    creatorID = map['creatorID'];
    users = List<String>.from(map['users']);
    if (type == 'SINGLE_ORGANISATION' || type == 'GROUP') {
      organisations = List<String>.from(map['organisations']); //
    }
    lastMessageDate =
        map['lastMessageDate'] != null ? map['lastMessageDate'].toDate() : null;
    creationDate =
        map['creationDate'] != null ? map['creationDate'].toDate() : null;
  }

  String getToUserID(String currentUserID) {
    if (this.type == "GROUP") {
      throw Exception('Try to get ToUserID of a chatGroup');
    } else {
      for (var i = 0; i < users.length; i++) {
        String userID = users[i];
        if (currentUserID != userID) return userID;
      }
      return currentUserID;
    }
  }

  String getToOrganisationID() {
    if (this.type == "SINGLE_ORGANISATION") {
      return organisations[0];
    } else {
      throw Exception('Try to get ToUserID of a chatGroup');
    }
  }
}
