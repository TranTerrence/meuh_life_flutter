import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:meuh_life/models/ChatRoom.dart';
import 'package:meuh_life/models/Comment.dart';
import 'package:meuh_life/models/Member.dart';
import 'package:meuh_life/models/Message.dart';
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/models/Post.dart';
import 'package:meuh_life/models/Profile.dart';

import 'HivePrefs.dart';

class DatabaseService {
  final FirebaseStorage storage =
      FirebaseStorage(storageBucket: 'gs://meuhlife.appspot.com/');

  // -start- PROFILE Getters

  Future<Profile> getProfile(String userID) async {
    CollectionReference userCollection = Firestore.instance.collection('users');
    DocumentSnapshot document = await userCollection.document(userID).get();
    return Profile.fromDocSnapshot(document);
  }

  Stream<Profile> getProfileStream(String userID) {
    CollectionReference userCollection = Firestore.instance.collection('users');
    return userCollection
        .document(userID)
        .snapshots()
        .map(_profileFromSnapshot);
  }

  Profile _profileFromSnapshot(DocumentSnapshot snapshot) {
    return Profile.fromDocSnapshot(snapshot);
  }

  Stream<List<Profile>> getProfileListStream(
      {String orderBy = 'creationDate'}) {
    // TODO Later: Add optional query params
    CollectionReference userCollection = Firestore.instance.collection('users');
    return userCollection
        .orderBy(orderBy, descending: true)
        .snapshots()
        .map(_profileListFromSnapshot);
  }

  List<Profile> _profileListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Profile.fromDocSnapshot(doc);
    }).toList();
  }

  Future<List<Profile>> getProfileList() async {
    CollectionReference userCollection = Firestore.instance.collection('users');
    QuerySnapshot querySnapshot = await userCollection.getDocuments();
    List<Profile> list = _profileListFromSnapshot(querySnapshot);
    return list;
  }

  updateProfile(String userID, Map<String, dynamic> data) {
    DocumentReference ref = Firestore.instance.document("users/" + userID);
    ref.updateData(data);
  }

  // -end- PROFILE Getters

  // -start- POST Getters
  Stream<List<Post>> getPostListStream(
      {String orderBy = 'creationDate', String on, String onValueEqualTo}) {
    // TODO Later: Add optional query params
    CollectionReference postCollection = Firestore.instance.collection('posts');
    if (on != null && onValueEqualTo != null) {
      return postCollection
          .where(on, isEqualTo: onValueEqualTo)
          .orderBy(orderBy, descending: true)
          .snapshots()
          .map(_postListFromSnapshot);
    } else {
      return postCollection
          .orderBy(orderBy, descending: true)
          .snapshots()
          .map(_postListFromSnapshot);
    }
  }

  List<Post> _postListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      Post p = Post();
      //Will cast the Post into the right children (Event, internship, ...)
      return p.castFromDocSnapshot(doc);
    }).toList();
  }

  Future<void> deletePost(Post post) async {
    CollectionReference commentCollection = Firestore.instance
        .collection('posts')
        .document(post.id)
        .collection('comments');
    await deleteCollection(commentCollection);

    CollectionReference reactionCollection = Firestore.instance
        .collection('posts')
        .document(post.id)
        .collection('reactions');
    await deleteCollection(reactionCollection);

    CollectionReference postCollection = Firestore.instance.collection('posts');
    postCollection.document(post.id).delete();
    if (post.imageURL != null) {
      StorageReference imageRef =
          storage.ref().child("posts_images/${post.id}");
      imageRef.delete().then((value) => null).catchError((e) {
        print(e);
      });
    }
  }

  Future<void> deleteCollection(CollectionReference collection) async {
    collection.getDocuments().then((snapshot) async {
      if (snapshot != null) {
        for (DocumentSnapshot ds in snapshot.documents) {
          await ds.reference.delete();
        }
        return;
      }
    });
  }

  Stream<List<Comment>> getCommentListStream(
      {String orderBy = 'creationDate',
      String on,
      String onValueEqualTo,
      @required String postID}) {
    // TODO Later: Add optional query params
    CollectionReference commentCollection = Firestore.instance
        .collection('posts')
        .document(postID)
        .collection('comments');
    if (on != null && onValueEqualTo != null) {
      return commentCollection
          .where(on, isEqualTo: onValueEqualTo)
          .orderBy(orderBy, descending: false)
          .snapshots()
          .map(_commentListFromSnapshot);
    } else {
      return commentCollection
          .orderBy(orderBy, descending: false)
          .snapshots()
          .map(_commentListFromSnapshot);
    }
  }

  List<Comment> _commentListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Comment.fromDocSnapshot(doc);
    }).toList();
  }

  void addComment(String postID, Map<String, dynamic> data) async {
    CollectionReference commentCollection = Firestore.instance
        .collection('posts')
        .document(postID)
        .collection('comments');
    await commentCollection.add(data);
  }

  Future<bool> updateReactionToPost(
      {@required String postID, String reaction}) async {
    final preferences = await HivePrefs.getInstance();
    String currentUserID = preferences.getUserID();
    DocumentReference reactionDocument = Firestore.instance
        .collection('posts')
        .document(postID)
        .collection('reactions')
        .document(currentUserID);
    if (reaction == null) {
      await reactionDocument.delete();
      return false;
    } else {
      await reactionDocument.setData({"reaction": reaction});
      return true;
    }
  }

  Future<Stream<String>> getCurrentUserReactionToPostStream(
      String postID) async {
    final preferences = await HivePrefs.getInstance();
    String currentUserID = preferences.getUserID();
    DocumentReference reactionDocument = Firestore.instance
        .collection('posts')
        .document(postID)
        .collection('reactions')
        .document(currentUserID);
    return reactionDocument.snapshots().map((doc) => doc['reaction']);
  }

  Future<String> getCurrentUserReactionToPost(String postID) async {
    final preferences = await HivePrefs.getInstance();
    String currentUserID = preferences.getUserID();
    DocumentReference reactionDocument = Firestore.instance
        .collection('posts')
        .document(postID)
        .collection('reactions')
        .document(currentUserID);

    DocumentSnapshot snapShot = await reactionDocument.get();
    if (snapShot == null || !snapShot.exists) {
      return null;
    } else {
      return snapShot.data['reaction'];
    }
  }

  // -end- POST Getters

  // -start- ORGANISATION Getters
  Future<Organisation> getOrganisation(String organisationID) async {
    CollectionReference organisationCollection =
    Firestore.instance.collection('organisations');
    DocumentSnapshot document =
    await organisationCollection.document(organisationID).get();
    Organisation organisation = Organisation.fromDocSnapshot(document);
    return organisation;
  }

  Stream<Organisation> getOrganisationStream(String organisationID) {
    CollectionReference organisationCollection =
        Firestore.instance.collection('organisations');
    return organisationCollection
        .document(organisationID)
        .snapshots()
        .map(_organisationFromSnapshot);
  }

  Organisation _organisationFromSnapshot(DocumentSnapshot snapshot) {
    return Organisation.fromDocSnapshot(snapshot);
  }

  Stream<List<Organisation>> getOrganisationListStream(
      {String orderBy = 'fullName'}) {
    // TODO Later: Add optional query params
    CollectionReference organisationCollection =
        Firestore.instance.collection('organisations');
    return organisationCollection
        .orderBy(orderBy, descending: true)
        .snapshots()
        .map(_organisationListFromSnapshot);
  }

  Future<List<Organisation>> getOrganisationList() async {
    CollectionReference userCollection =
    Firestore.instance.collection('organisations');
    QuerySnapshot querySnapshot = await userCollection.getDocuments();
    List<Organisation> list = _organisationListFromSnapshot(querySnapshot);
    return list;
  }

  List<Organisation> _organisationListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Organisation.fromDocSnapshot(doc);
    }).toList();
  }

  Future<DocumentReference> createOrganisation(
      Organisation organisation) async {
    CollectionReference organisationCollection =
        Firestore.instance.collection('organisations');
    DocumentReference docRef =
        await organisationCollection.add(organisation.toJson());
    return docRef;
  }

  void createOrganisationAndMembers(
      Organisation organisation, List<Member> members, File imageFile) async {
    //create the Organisation document, then create all members document, get the ID and put it into the orga document

    CollectionReference organisationCollection =
        Firestore.instance.collection('organisations');

    final preferences = await HivePrefs.getInstance();
    String currentUserID = preferences.getUserID();

    DocumentReference orgRef = organisationCollection.document();
    String organisationID = orgRef.documentID;
    CollectionReference memberCollection =
    Firestore.instance.collection('members');
    await Future.forEach(members, (member) async {
      member.organisationID = organisationID;
      member.addedBy = currentUserID;
      member.joiningDate = DateTime.now();
      DocumentReference memberRef = await memberCollection.add(member.toJson());
      organisation.members.add(memberRef.documentID);
    });

    if (imageFile != null) {
      String collection = 'organisations_images';
      String fileName = organisationID;
      organisation.imageURL = getFileURL(collection, fileName);
      this.uploadFile(imageFile, collection, fileName);
    }
    organisation.creatorID = currentUserID;
    await orgRef.setData(organisation.toJson());
  }

  // -end- ORGANISATION Getters

  // -start- MEMBER Getters
  //Get the member list of a user or an organisation
  Stream<List<Member>> getMemberListStream(
      {String on, String onValueEqualTo, String orderBy = 'joiningDate'}) {
    // TODO Later: Add optional query params
    CollectionReference memberCollection =
        Firestore.instance.collection('members');

    return memberCollection
        //.orderBy(orderBy, descending: true)
        .where(on, isEqualTo: onValueEqualTo)
        .snapshots()
        .map(_memberListFromSnapshot);
  }

  Future<List<Member>> getMemberList({String on, String onValueEqualTo}) async {
    // TODO Later: Add optional query params
    List<Member> memberList = [];
    CollectionReference memberCollection =
    Firestore.instance.collection('members');
    QuerySnapshot querySnapshot = await memberCollection
        .where(on, isEqualTo: onValueEqualTo)
        .getDocuments();

    querySnapshot.documents.forEach((result) {
      memberList.add(Member.fromMap(result.data, result.documentID));
    });
    return memberList;
  }

  Future<List<Organisation>> getOrganisationListOf(String userID) async {
    List<Member> memberList = [];
    List<Organisation> organisationList = [];

    CollectionReference memberCollection =
    Firestore.instance.collection('members');
    QuerySnapshot querySnapshot = await memberCollection
        .where('userID', isEqualTo: userID)
        .getDocuments();
    querySnapshot.documents.forEach((result) {
      memberList.add(Member.fromMap(result.data, result.documentID));
    });

    for (Member member in memberList) {
      Organisation organisation = await getOrganisation(member.organisationID);
      organisationList.add(organisation);
    }
    return organisationList;
  }

  List<Member> _memberListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Member.fromDocSnapshot(doc);
    }).toList();
  }

// -end- MEMBER Getters
  //userID of the current USER
  Stream<List<ChatRoom>> getChatRoomListStream(
      {String orderBy = 'lastMessageDate', @required String userID}) {
    CollectionReference chatRoomCollection =
    Firestore.instance.collection('chatRooms');
    return chatRoomCollection
        .orderBy(orderBy, descending: true)
        .where('users', arrayContains: userID)
        .snapshots()
        .map(_chatRoomListFromSnapshot);
  }

  Stream<List<ChatRoom>> getOrganisationChatRoomListStream(
      {String orderBy = 'lastMessageDate', @required String organisationID}) {
    CollectionReference chatRoomCollection =
    Firestore.instance.collection('chatRooms');
    return chatRoomCollection
        .orderBy(orderBy, descending: true)
        .where('organisations', arrayContains: organisationID)
        .snapshots()
        .map(_chatRoomListFromSnapshot);
  }

  Future<List<ChatRoom>> getOrganisationChatRoomList(
      {String orderBy = 'lastMessageDate',
        @required String organisationID}) async {
    CollectionReference chatRoomCollection =
    Firestore.instance.collection('chatRooms');
    List<ChatRoom> chatRoomList = [];

    QuerySnapshot querySnapshot = await chatRoomCollection
        .orderBy(orderBy, descending: true)
        .where('organisations', arrayContains: organisationID)
        .getDocuments();

    querySnapshot.documents.forEach((result) {
      chatRoomList.add(ChatRoom.fromMap(result.data, result.documentID));
    });
    return chatRoomList;
  }

  List<ChatRoom> _chatRoomListFromSnapshot(QuerySnapshot snapshot) {
    print('Mapping ChatRoom List');
    return snapshot.documents.map((doc) {
      return ChatRoom.fromDocSnapshot(doc);
    }).toList();
  }

  Stream<List<Message>> getMessageListStream(
      {String orderBy = 'creationDate', @required String chatRoomID}) {
    CollectionReference messageCollection =
    Firestore.instance.collection('chatRooms/$chatRoomID/messages');
    return messageCollection
        .orderBy(orderBy, descending: true)
        .snapshots()
        .map(_messageListFromSnapshot);
  }

  List<Message> _messageListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Message.fromDocSnapshot(doc);
    }).toList();
  }

  StorageUploadTask uploadFile(File file, String folder, String fileName) {
    if (file != null) {
      String filePath = '$folder/$fileName';
      StorageUploadTask uploadTask =
          storage.ref().child(filePath).putFile(file);
      return uploadTask;
    } else {
      throw ('Given file is null');
    }
  }

  String getFileURL(String folder, String fileName) {
    return 'gs://meuhlife.appspot.com/$folder/$fileName';
  }

  void createChatRoom(ChatRoom chatRoom) async {
    CollectionReference messageCollection =
    Firestore.instance.collection('chatRooms');
    if (chatRoom.id != null && chatRoom.id != '') {
      DocumentReference document = messageCollection.document(chatRoom.id);
      await document.setData(chatRoom.toJson());
    } else {
      await messageCollection.add(chatRoom.toJson());
    }
    return;
  }

  void sendMessage(
      {Message message, String chatRoomID, File imageFile = null}) async {
    CollectionReference messageCollection = Firestore.instance
        .collection('chatRooms')
        .document(chatRoomID)
        .collection('messages');

    DocumentReference msgRef = messageCollection.document();
    String msgID = msgRef.documentID;
    if (imageFile != null) {
      String collection = 'messages_images/$chatRoomID';
      String fileName = msgID;
      message.imageURL = getFileURL(collection, fileName);
      this.uploadFile(imageFile, collection, fileName);
    }
    await msgRef.setData(message.toJson());
  }
}
