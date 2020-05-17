import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meuh_life/models/Post.dart';
import 'package:meuh_life/screens/create_post_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';

class MarketScreen extends StatefulWidget {
  MarketScreen(this.userID);

  final String userID;

  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with TickerProviderStateMixin<MarketScreen> {
  AnimationController _hideFabAnimation;
  DatabaseService database = DatabaseService();

  @override
  initState() {
    super.initState();
    _hideFabAnimation =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);
    _hideFabAnimation.forward();
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
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreatePostScreen(widget.userID)),
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
                return post.getCard(context, database);
              },
              itemCount: posts.length,
            );
          }
        },
      ),
    ));
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
