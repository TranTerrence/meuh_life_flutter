import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meuh_life/models/Post.dart';
import 'package:meuh_life/providers/CurrentUser.dart';
import 'package:meuh_life/screens/create_post_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';
import 'package:provider/provider.dart';

class MarketScreen extends StatefulWidget {
  @override
  _MarketScreenState createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen>
    with TickerProviderStateMixin<MarketScreen> {
  AnimationController _hideFabAnimation;
  DatabaseService database = DatabaseService();
  CurrentUser currentUser;

  @override
  initState() {
    super.initState();
    _hideFabAnimation =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);
    _hideFabAnimation.forward();
    currentUser = Provider.of<CurrentUser>(context, listen: false);
  }

  @override
  void dispose() {
    _hideFabAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Tab> tab = [
      Tab(text: 'Tout'), //icon: Icon(Icons.announcement),
      Tab(text: 'Evenements'), //icon: Icon(Icons.event),
      Tab(text: 'Annonces'), //icon: Icon(Icons.announcement),
      Tab(text: 'Memes'), //icon: Icon(Icons.color_lens),
    ];
    List<Widget> tabContent = [
      showPostList(),
      showPostList(on: 'type', onValueEqualTo: 'EVENT', key: 'EVENT'),
      showPostList(on: 'type', onValueEqualTo: 'ANNOUNCE', key: 'ANNOUNCE'),
      showPostList(on: 'type', onValueEqualTo: 'MEMES', key: 'MEMES'),
    ];
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: TabBar(
              isScrollable: true,
              tabs: tab,
            ),
          ),
          body: TabBarView(
            children: tabContent,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        CreatePostScreen(userID: currentUser.id)),
              ),
            },
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
            backgroundColor: Colors.blue.shade800,
          ),
        ),
      ),
    );
  }

  Widget showPostList({String on, String onValueEqualTo, String key}) {
    return (Container(
      child: StreamBuilder(
        stream:
            database.getPostListStream(on: on, onValueEqualTo: onValueEqualTo),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<Post> posts = snapshot.data;
            return ListView.builder(
              key: PageStorageKey(key),
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              itemBuilder: (context, index) {
                Post post = posts[index];
                return post.getCard(context, database, currentUser);
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
