import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meuh_life/models/ChatRoom.dart';
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/screens/conversation_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';
import 'package:meuh_life/services/utils.dart';

class OrganisationsScreen extends StatefulWidget {
  final String userID;

  const OrganisationsScreen({Key key, this.userID}) : super(key: key);

  @override
  _OrganisationsScreenState createState() => _OrganisationsScreenState();
}

class _OrganisationsScreenState extends State<OrganisationsScreen> {
  String _subTitle = '';
  List<Organisation> _organisations;
  DatabaseService _database = DatabaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Organisations'),
            if (_subTitle != '')
              Text(
                _subTitle,
                style: TextStyle(fontSize: 12.0),
              ),
          ],
        ),
      ),
      body: showOrganisationList(),
    );
  }

  Future<List<Organisation>> getOrganisations() async {
    List<Organisation> organisations = await _database.getOrganisationList();
    setState(() {
      _organisations = organisations;
      _subTitle = '${_organisations.length} organisations';
    });
    return organisations;
  }

  Widget showOrganisationList() {
    return FutureBuilder(
      future: getOrganisations(),
      builder: (context, AsyncSnapshot<List<Organisation>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        _organisations = snapshot.data;
        return ListView.builder(
            itemCount: _organisations.length,
            itemBuilder: (BuildContext context, int index) {
              Organisation organisation = _organisations[index];

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                  onTap: () {
                    String chatRoomID =
                        getChatRoomID(organisation.id, widget.userID);
                    ChatRoom chatRoom = ChatRoom(
                        id: chatRoomID,
                        type: "SINGLE_ORGANISATION",
                        users: [widget.userID],
                        organisations: [organisation.id]);

                    Navigator.of(context).pop();
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
                            organisation.description != null &&
                                    organisation.description.length > 0
                                ? Text(
                                    organisation.description,
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
