import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meuh_life/components/SelectPublisher.dart';
import 'package:meuh_life/models/Comment.dart';
import 'package:meuh_life/models/Post.dart';
import 'package:meuh_life/services/DatabaseService.dart';
import 'package:meuh_life/services/HivePrefs.dart';

class CommentScreen extends StatefulWidget {
  final Post post;

  const CommentScreen({Key key, this.post}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  List<Comment> comments = [];
  Comment _newComment = Comment(asOrganisation: '');
  DatabaseService database = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(text: _newComment.text);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue.shade800,
          title: Text('Commentaires'),
        ),
        body: Column(
          children: <Widget>[
            Expanded(child: showCommentList()),
            showSelectPublisher(),
            TextField(
              minLines: 1,
              maxLines: 5,
              cursorColor: Colors.blue.shade800,
              controller: textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Ajouter un commentaire",
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.send,
                  ),
                  onPressed: () {
                    _newComment.text = textController.text;
                    database.addComment(widget.post.id, _newComment.toJson());
                    textController.clear();
                  },
                ),
              ),
            )
          ],
        ));
  }

  Future<String> getUserID() async {
    final preferences = await HivePrefs.getInstance();
    String userID = preferences.getUserID();
    return userID;
  }

  Widget showCommentList() {
    return (StreamBuilder(
      stream: database.getCommentListStream(postID: widget.post.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('No Comments'),
          );
        } else {
          List<Comment> comments = snapshot.data;
          comments.insert(
              0,
              Comment(
                  text: widget.post.description,
                  author: widget.post.author,
                  asOrganisation: widget.post.asOrganisation,
                  creationDate: widget.post.creationDate));
          return ListView.builder(
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            itemBuilder: (context, index) {
              Comment comment = comments[index];
              return comment.getCard(context, database);
            },
            itemCount: comments.length,
          );
        }
      },
    ));
  }

  Widget showSelectPublisher() {
    return FutureBuilder(
        future: getUserID(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text('No user'),
            );
          } else {
            String userID = snapshot.data;
            _newComment.author = userID;
            void callback(newValue) {
              setState(() {
                _newComment.asOrganisation = newValue;
              });
            }

            return SelectPublisher(
              userID: userID,
              value: _newComment.asOrganisation,
              callback: callback,
            );
          }
        });
  }
}
