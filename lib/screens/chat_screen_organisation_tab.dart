import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:meuh_life/models/ChatRoom.dart';
import 'package:meuh_life/models/Member.dart';
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/screens/contacts_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';

import 'conversation_screen.dart';
import 'organisations_screen.dart';

class OrganisationChatsTab extends StatefulWidget {
  final String userID;

  const OrganisationChatsTab({Key key, @required this.userID})
      : super(key: key);

  @override
  _OrganisationChatsTabState createState() => _OrganisationChatsTabState();
}

class _OrganisationChatsTabState extends State<OrganisationChatsTab> {
  final DatabaseService _database = DatabaseService();
  List<ChatRoom> _chatRooms = [];
  Map _organisations; // List of all organisation that the current user belongs to

  bool _dialIsOpen = false;

  // Get organisations of the user
  // Get all chatrooms for each organisations
  // Order by last message date
  // display

  @override
  void initState() {
    super.initState();
    setState(() {
      getChatRooms();
    });
  }

  void getChatRooms() async {
    print('Getting organisations list');
    List<Organisation> organisations =
        await _database.getOrganisationListOf(widget.userID);
    setState(() {
      print('Organisations: $_organisations');

      _organisations =
          Map.fromIterable(organisations, key: (e) => e.id, value: (e) => e);
      print(_organisations);
    });
    List<ChatRoom> chatRooms = [];

    for (var entry in _organisations.entries) {
      Organisation organisation = entry.value;

      print('Getting chat for Organisation: ${organisation.id}');

      List<ChatRoom> chats = await _database.getOrganisationChatRoomList(
          organisationID: organisation.id);
      print('ChatRooms : ${chats}');
      if (chats != null) chatRooms.addAll(chats);
      print('CHATS : ${chatRooms}');
    }
    setState(() {
      _chatRooms = chatRooms;
      print('Setting chatrooms');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_chatRooms == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView.builder(
        itemCount: _chatRooms.length,
        itemBuilder: (BuildContext context, int index) {
          ChatRoom chatRoom = _chatRooms[index];
          return buildChatRoomItem(chatRoom);
        });
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

  //TODO: Change the behaviour: here only Organisation chat with people
  // THe current is AS Organisation Message always
  Widget buildChatRoomItem(ChatRoom chatRoom) {
    if (chatRoom.type == null || chatRoom.type == 'GROUP') {
      return Container(
        child: Text('TEST'),
      );
    } else {
      // There is only Single Organisation or Group chat possible
      Widget item = getOrganisationToUserItem(chatRoom, widget.userID);
      print('SINGLE ORGA');

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

  Widget getOrganisationToUserItem(ChatRoom chatRoom, String currentUserID) {
    String toOrganisationID = chatRoom.getToOrganisationID();
    String toUserID = chatRoom
        .getToUserID(currentUserID); // Return the first userID that is not null

    Organisation organisation = _organisations[toOrganisationID];
    double avatarRadius = 18.0;
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
                          toOrganisation: organisation,
                          userID: currentUserID,
                          asOrganisation: organisation.id,
                        )),
              );
            },
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: 8.0,
                ),
                organisation.getCircleAvatar(radius: avatarRadius),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  width: 1.0,
                  height: 30.0,
                  color: Colors.grey,
                ),
                profile.getCircleAvatar(radius: avatarRadius),
                SizedBox(
                  width: 8.0,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        profile.fullName + '\n' + organisation.fullName,
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

  Widget showOrganisations() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Organisations',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              child: StreamBuilder(
                  stream: _database.getMemberListStream(
                      on: 'userID', onValueEqualTo: widget.userID),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Text('No Member data '),
                      );
                    } else {
                      List<Member> members = snapshot.data;
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            Member member = members[index];
                            return buildMember(context, member);
                          });
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMember(BuildContext context, Member member) {
    return StreamBuilder(
        stream: _database.getOrganisationStream(member.organisationID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text('No Organisation Data for this member'),
            );
          } else {
            Organisation organisation = snapshot.data;
            return Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: InkWell(
                  onTap: () =>
                      organisation.showDetailedDialog(context, organisation),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      organisation.getCircleAvatar(radius: 24.0),
                      SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(organisation.fullName,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            if (member.position != '') Text(member.position),
                            Text(member.getRole()),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${organisation.members.length}',
                            style: TextStyle(
                                fontSize: 18.0, color: Colors.blue.shade800),
                          ),
                          Icon(
                            organisation.members.length == 1
                                ? Icons.person
                                : Icons.people,
                            color: Colors.blue.shade800,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
