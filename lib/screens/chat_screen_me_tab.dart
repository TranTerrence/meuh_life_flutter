import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:meuh_life/models/ChatRoom.dart';
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/screens/contacts_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';

import 'conversation_screen.dart';
import 'organisations_screen.dart';

class MyChatsTab extends StatefulWidget {
  final String userID;

  const MyChatsTab({Key key, @required this.userID}) : super(key: key);

  @override
  _MyChatsTabState createState() => _MyChatsTabState();
}

class _MyChatsTabState extends State<MyChatsTab> {
  final DatabaseService _database = DatabaseService();
  List<ChatRoom> _chatRooms;
  bool _dialIsOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: showSpeedDial(),
      body: StreamBuilder(
          stream: _database.getChatRoomListStream(userID: widget.userID),
          builder: (context, snapshot) {
            print('BUILDING THE CHAT LIST');
            if (!snapshot.hasData) {
              print('NO CHATROOM DATA');
              return Center(child: CircularProgressIndicator());
            }
            _chatRooms = snapshot.data;
            if (_chatRooms.length == 0) {
              return Center(
                child: Text('Tes futures conversations apparaîtrons ici'),
              );
            }
            return ListView.builder(
                itemCount: _chatRooms.length,
                itemBuilder: (BuildContext context, int index) {
                  ChatRoom chatRoom = _chatRooms[index];
                  return buildChatRoomItem(chatRoom);
                });
          }),
    );
  }

  SpeedDial showSpeedDial() {
    return SpeedDial(
      //animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 24.0),
      child: _dialIsOpen ? Icon(Icons.close) : Icon(Icons.message),
      // If true user is forced to close dial manually
      // by tapping main button and overlay is not rendered.
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black54,
      overlayOpacity: 0.5,
      onOpen: () {
        setState(() {
          _dialIsOpen = true;
        });
      },
      onClose: () {
        setState(() {
          _dialIsOpen = false;
        });
      },
      tooltip: 'Contacter',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Colors.blue.shade800,
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: CircleBorder(),
      children: [
        SpeedDialChild(
            child: Icon(
              Icons.person,
              color: Colors.white,
            ),
            backgroundColor: Colors.blue.shade800,
            label: 'Utilisateurs',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return ContactsScreen(
                      userID: widget.userID,
                    );
                  },
                ),
              );
            }),
        SpeedDialChild(
          child: Icon(
            Icons.account_balance,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue.shade800,
          label: 'Organisations',
          labelStyle: TextStyle(fontSize: 18.0),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return OrganisationsScreen(
                  userID: widget.userID,
                );
              }),
            );
          },
        ),
      ],
    );
  }

  Widget buildChatRoomItem(ChatRoom chatRoom) {
    if (chatRoom.type == null || chatRoom.type == 'GROUP') {
      return Container(
        child: Text('TEST'),
      );
    } else {
      Widget item;
      switch (chatRoom.type) {
        case "SINGLE_USER":
          item = getProfileItem(chatRoom);
          break;

        case 'SINGLE_ORGANISATION':
          item = getOrganisationItem(chatRoom);
          break;
      }
      return Column(
        children: <Widget>[
          SizedBox(
            height: 8.0,
          ),
          item,
          Divider(),
        ],
      );
    }
  }

  Widget getProfileItem(ChatRoom chatRoom) {
    String toUserID = chatRoom.getToUserID(widget.userID);

    return FutureBuilder(
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
                          toProfile: profile,
                          userID: widget.userID,
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
                        profile.fullName + ' (${profile.promoWithP})',
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
        });
  }

  Widget getOrganisationItem(ChatRoom chatRoom) {
    String toOrganisationID = chatRoom.getToOrganisationID();

    return FutureBuilder(
        future: _database.getOrganisation(toOrganisationID),
        builder: (context, AsyncSnapshot<Organisation> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          Organisation organisation = snapshot.data;
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ConversationScreen(
                          chatRoom: chatRoom,
                          toOrganisation: organisation,
                          userID: widget.userID,
                        )),
              );
            },
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 8.0,
                ),
                organisation.getCircleAvatar(radius: 24.0),
                SizedBox(
                  width: 8.0,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        organisation.fullName,
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
        });
  }
}
