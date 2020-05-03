import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meuh_life/models/Post.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/screens/create_post_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  //final String userID = getUserID();
  String _locale = 'fr';
  DateFormat format = DateFormat('EEEE dd MMMM à HH:mm');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostScreen()),
          ),
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue.shade800,
      ),
      body: showPostList(),
    );
  }

  Widget showPostList() {
    return (Container(
      child: StreamBuilder(
        stream: Firestore.instance.collection('posts').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text('No data'),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) =>
                  buildItem(context, snapshot.data.documents[index]),
              itemCount: snapshot.data.documents.length,
            );
          }
        },
      ),
    ));
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    Post post = new Post.fromDocSnapshot(document);
    DateFormat format = DateFormat('EE\ndd/MM\nHH:mm');

    return Container(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: <Widget>[
            Text(post.startDate != null
                ? format.format((post.startDate))
                : format.format((post.creationDate))),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  document['title'],
                  style: TextStyle(fontSize: 40.0),
                ),
                Text(
                  document['description'],
                  maxLines: 4,
                  overflow: TextOverflow.fade,
                  softWrap: true,
                  style: TextStyle(fontSize: 24.0),
                ),
                StreamBuilder(
                    stream: Firestore.instance
                        .collection('users')
                        .document(document['author'])
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return new Text("Chargement ... ");
                      }
                      Profile profile = Profile.fromDocSnapshot(snapshot.data);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Text(profile.getFullName()),
                          Text('P' + profile.promo),
                          profile.getCircleAvatar(radius: 40.0),
                        ],
                      );
                    }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

getUserID() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userID = prefs.getString('userID');
  return userID;
}
