import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/models/Post.dart';
import 'package:meuh_life/models/Profile.dart';

import 'utils.dart';

class DatabaseService {
  final FirebaseStorage storage =
      FirebaseStorage(storageBucket: 'gs://meuh-life.appspot.com/');

  // -start- PROFILE Getters
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

  // -end- PROFILE Getters

  // -start- POST Getters
  Stream<List<Post>> getPostListStream({String orderBy = 'creationDate'}) {
    // TODO Later: Add optional query params
    CollectionReference postCollection = Firestore.instance.collection('posts');
    return postCollection
        .orderBy(orderBy, descending: true)
        .snapshots()
        .map(_postListFromSnapshot);
  }

  List<Post> _postListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Post.fromDocSnapshot(doc);
    }).toList();
  }

  // -end- POST Getters

  // -start- ORGANISATION Getters

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

  Future<DocumentReference> createOrganisationAndMembers(
      Organisation organisation, List<Member> members, File imageFile) async {
    //TODO: create the Organisation document, then create all members document, get the ID and put it into the orga document
    CollectionReference organisationCollection =
        Firestore.instance.collection('organisations');
    CollectionReference memberCollection =
        Firestore.instance.collection('members');
    String currentUserID = await SharedPref.getUserID();
    DocumentReference orgRef = organisationCollection.document();
    String organisationID = orgRef.documentID;
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
      organisation.imageURL =
          'gs://meuh-life.appspot.com/$collection/$fileName';
      this.uploadFile(imageFile, collection, fileName);
    }
    organisation.creatorID = currentUserID;
    await orgRef.setData(organisation.toJson());
  }

  // -end- ORGANISATION Getters

  // -start- MEMBER Getters
  //Get the member list of a user
  Stream<List<Member>> getMemberListStream(
      {String userID, String orderBy = 'joiningDate'}) {
    // TODO Later: Add optional query params
    CollectionReference memberCollection =
        Firestore.instance.collection('members');

    return memberCollection
        //.orderBy(orderBy, descending: true)
        .where('userID', isEqualTo: userID)
        .snapshots()
        .map(_memberListFromSnapshot);
  }

  List<Member> _memberListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Member.fromDocSnapshot(doc);
    }).toList();
  }

// -end- MEMBER Getters

  StorageUploadTask uploadFile(File file, String collection, String fileName) {
    if (file != null) {
      String filePath = '$collection/$fileName';
      StorageUploadTask uploadTask =
          storage.ref().child(filePath).putFile(file);
      return uploadTask;
    } else {
      throw ('Given fie is null');
    }
  }
}
