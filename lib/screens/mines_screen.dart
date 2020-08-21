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
  List<String> _chipFilters = ['ALL', 'EVENT', 'ANNOUNCE', 'MEMES'];
  Map _chipLabels = {
    'ALL': 'Tout',
    'EVENT': 'Evenements',
    'ANNOUNCE': 'Annonces',
    'MEMES': 'Memes'
  };
  String _selectedFilter = 'ALL';
  ScrollController _scrollController;

  @override
  initState() {
    super.initState();
    _scrollController = ScrollController();
    _hideFabAnimation =
        AnimationController(vsync: this, duration: kThemeAnimationDuration);
    _hideFabAnimation.forward();
    currentUser = Provider.of<CurrentUser>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _hideFabAnimation.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        key: PageStorageKey('nested-scroll-$_selectedFilter'),
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              backgroundColor: Colors.white,
              title: showChoiceChip(),
              pinned: false,
              floating: true,
              snap: true,
              // Bug: snap needs to be true to let the bar floating. see stackoverflow
              forceElevated: innerBoxIsScrolled,
              //bottom: showChoiceChip(),
            ),
          ];
        },
        body: NotificationListener(
          onNotification: _handleScrollNotification,
          child: showPostList(key: _selectedFilter),
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _hideFabAnimation,
        child: FloatingActionButton(
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
    );
  }

  Widget showChoiceChip() {
    return PreferredSize(
      preferredSize: Size.fromHeight(25.0), // here the desired height
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (var filter in _chipFilters)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.0),
                child: ChoiceChip(
                  padding: EdgeInsets.all(4.0),
                  label: Text(_chipLabels[filter]),
                  selected: _selectedFilter == filter,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget showPostList({String key}) {
    return (StreamBuilder(
      stream: _selectedFilter == 'ALL'
          ? database.getPostListStream()
          : database.getPostListStream(
              on: 'type', onValueEqualTo: _selectedFilter),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          List<Post> posts = snapshot
              .data; //TODO: Maybe filter the data here instead of calling each time
          return ListView.builder(
            key: PageStorageKey('list-view-$key'),
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            itemBuilder: (context, index) {
              Post post = posts[index];
              return post.getCard(context, database, currentUser);
            },
            itemCount: posts.length,
          );
        }
      },
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
