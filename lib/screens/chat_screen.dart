import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meuh_life/models/ChatRoom.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/screens/contacts_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';

import 'conversation_screen.dart';

class ChatScreen extends StatefulWidget {
  final String userID;

  const ChatScreen({Key key, this.userID}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseService _database = DatabaseService();
  List<ChatRoom> _chatRooms;

  @override
  Widget build(BuildContext context) {
    List<Tab> tab = [
      Tab(text: 'Moi'), //icon: Icon(Icons.event),
      Tab(text: 'Organisation'), //icon: Icon(Icons.announcement),
    ];
    List<Widget> tabContent = [
      Container(
        child: showChatRooms(),
      ),
      Container(
        child: Text('Organisations content'),
      ),
    ];
    return DefaultTabController(
      length: tab.length,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: TabBar(
            tabs: tab,
          ),
        ),
        body: TabBarView(children: tabContent),
        floatingActionButton: FloatingActionButton(
          onPressed: () => {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ContactsScreen(
                        userID: widget.userID,
                      )),
            ),
          },
          child: Icon(
            Icons.message,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue.shade800,
        ),
      ),
    );
  }

  Widget showChatRooms() {
    return StreamBuilder(
        stream: _database.getChatRoomListStream(userID: widget.userID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          _chatRooms = snapshot.data;
          return ListView.builder(
              itemCount: _chatRooms.length,
              itemBuilder: (BuildContext context, int index) {
                ChatRoom chatRoom = _chatRooms[index];
                return buildChatRoomItem(chatRoom);
              });
        });
  }

  Widget buildChatRoomItem(ChatRoom chatRoom) {
    if (chatRoom.isChatGroup) {
      return Container();
    } else {
      //It 's only with 1:1 chat with another user

      String toUserID = chatRoom.getToUserID(widget.userID);
      print('TO USER ID $toUserID');
      return Column(
        children: <Widget>[
          SizedBox(
            height: 8.0,
          ),
          FutureBuilder(
              future: _database.getProfile(toUserID),
              builder: (context, AsyncSnapshot<Profile> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                Profile profile = snapshot.data;
                return InkWell(
                  onTap: () {
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
                      SizedBox(
                        width: 8.0,
                      ),
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
                            Text(
                              chatRoom.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
          Divider(),
        ],
      );
    }
  }
}
