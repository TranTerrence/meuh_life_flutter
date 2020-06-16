import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meuh_life/models/ChatRoom.dart';
import 'package:meuh_life/providers/CurrentUser.dart';
import 'package:meuh_life/screens/chat_screen_me_tab.dart';
import 'package:meuh_life/services/DatabaseService.dart';
import 'package:provider/provider.dart';

import 'chat_screen_organisation_tab.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseService _database = DatabaseService();
  List<ChatRoom> _chatRooms;
  CurrentUser currentUser;
  bool _dialIsOpen = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      currentUser = Provider.of<CurrentUser>(context, listen: false);
      print('GOT CURRENT USER $currentUser');
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Tab> tab = [
      Tab(text: 'Moi'), //icon: Icon(Icons.event),
      Tab(text: 'Organisation'), //icon: Icon(Icons.announcement),
    ];
    List<Widget> tabContent = [
      Container(
        child: MyChatsTab(
          userID: currentUser.id,
        ),
      ),
      Center(
        child: OrganisationChatsTab(
          userID: currentUser.id,
        ),
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
      ),
    );
  }
}
