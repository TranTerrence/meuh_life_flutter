import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:meuh_life/models/Post.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/screens/create_post_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with TickerProviderStateMixin<MarketScreen> {
  //final String userID = await SharedPref.getUserID();
  String _locale = 'fr';
  DateFormat format = DateFormat('EEEE dd MMMM à HH:mm');
  AnimationController _hideFabAnimation;
  DatabaseService database = DatabaseService();

  @override
  initState() {
    super.initState();
    _hideFabAnimation =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);
  }

  @override
  void dispose() {
    _hideFabAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: Scaffold(
        floatingActionButton: ScaleTransition(
          scale: _hideFabAnimation,
          child: FloatingActionButton(
            onPressed: () =>
            {
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
        ),
        body: showPostList(),
      ),
    );
  }

  Widget showPostList() {
    return (Container(
      child: StreamBuilder(
        stream: database.getPostListStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text('No Post data'),
            );
          } else {
            List<Post> posts = snapshot.data;
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) {
                Post post = posts[index];
                return buildPost(context, post);
              },
              itemCount: posts.length,
            );
          }
        },
      ),
    ));
  }

  Widget buildPost(BuildContext context, Post post) {
    DateFormat format = DateFormat('EE\ndd/MM\nHH:mm');

    return Container(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Text(
                post.startDate != null
                    ? format.format(post.startDate)
                    : format.format(post.creationDate),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                width: 8.0,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post.title,
                      style: TextStyle(fontSize: 40.0),
                    ),
                    Text(
                      post.description,
                      softWrap: true,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 18.0),
                    ),
                    if (post.imageURL != null && post.imageURL.length > 0)
                      Image(
                        image: FirebaseImage(post.imageURL),
                      ),
                    StreamBuilder(
                        stream: database.getProfileStream(post.author),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return new Text("Chargement ... ");
                          }
                          Profile profile = snapshot.data;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Text(
                                '${profile.firstName} ${profile.lastName[0]}.'
                                    '\n(P${profile.promo})',
                              ),
                              SizedBox(
                                width: 8.0,
                              ),
                              profile.getCircleAvatar(radius: 40.0),
                            ],
                          );
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0) {
      if (notification is UserScrollNotification) {
        final UserScrollNotification userScroll = notification;
        switch (userScroll.direction) {
          case ScrollDirection.forward:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              _hideFabAnimation.forward();
            }
            break;
          case ScrollDirection.reverse:
            if (userScroll.metrics.maxScrollExtent !=
                userScroll.metrics.minScrollExtent) {
              _hideFabAnimation.reverse();
            }
            break;
          case ScrollDirection.idle:
            break;
        }
      }
    }
    return false;
  }
}
