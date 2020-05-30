import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meuh_life/models/ChatRoom.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/screens/conversation_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';
import 'package:meuh_life/services/utils.dart';

class ContactsScreen extends StatefulWidget {
  final String userID;

  const ContactsScreen({Key key, this.userID}) : super(key: key);

  @override
  _ContactsScreenState createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  String _subTitle = '';
  List<Profile> _profiles;
  DatabaseService _database = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Contacts'),
            if (_subTitle != '')
              Text(
                _subTitle,
                style: TextStyle(fontSize: 12.0),
              ),
          ],
        ),
      ),
      body: showContactList(),
    );
  }

  Future<List<Profile>> getProfiles() async {
    List<Profile> profiles = await _database.getProfileList();
    setState(() {
      _profiles = profiles;
      _subTitle = '${_profiles.length} contacts';
    });
    return profiles;
  }

  Widget showContactList() {
    return FutureBuilder(
      future: getProfiles(),
      builder: (context, AsyncSnapshot<List<Profile>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        _profiles = snapshot.data;
        return ListView.builder(
            itemCount: _profiles.length,
            itemBuilder: (BuildContext context, int index) {
              Profile profile = _profiles[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    String chatRoomID =
                        getChatRoomID(profile.id, widget.userID);
                    ChatRoom chatRoom = ChatRoom(
                        id: chatRoomID,
                        isChatGroup: false,
                        users: [profile.id, widget.userID]);
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ConversationScreen(
                                chatRoom: chatRoom,
                                userID: widget.userID,
                                toProfile: profile,
                              )),
                    );
                  },
                  child: Row(
                    children: <Widget>[
                      profile.getCircleAvatar(radius: 24.0),
                      SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              profile.getFullName() +
                                  ' (${profile.getPromo()})',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            profile.description != null &&
                                    profile.description.length > 0
                                ? Text(
                                    profile.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }
}
