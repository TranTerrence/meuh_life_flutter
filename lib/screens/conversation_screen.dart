import 'dart:io';

import 'package:bubble/bubble.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meuh_life/models/ChatRoom.dart';
import 'package:meuh_life/models/Message.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/screens/image_view_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';

class ConversationScreen extends StatefulWidget {
  final ChatRoom chatRoom;
  final Profile toProfile; // Profile talking to
  final String userID; //Current userID

  const ConversationScreen(
      {Key key, @required this.chatRoom, @required this.userID, this.toProfile})
      : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<Message> _messages;
  DatabaseService _database = DatabaseService();
  Widget _appBarTitle = Container();
  File _imageFile;
  final TextEditingController textEditingController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    if (!widget.chatRoom.isChatGroup) {
      setState(() {
        _appBarTitle = Row(
          children: <Widget>[
            widget.toProfile.getCircleAvatar(radius: 20.0),
            SizedBox(
              width: 8.0,
            ),
            Text(widget.toProfile.getFullName())
          ],
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade800,
        title: _appBarTitle,
      ),
      body: Column(
        children: <Widget>[
          showMessageList(),
          showInput(),
        ],
      ),
    );
  }

  Widget showMessageList() {
    return StreamBuilder(
      stream: _database.getMessageListStream(chatRoomID: widget.chatRoom.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        _messages = snapshot.data;
        return Flexible(
          child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                Message message = _messages[index];
                bool isLeftMessage = message.author != widget.userID;

                if (isLeftMessage) {
                  return buildLeftItem(message, isLastMessageLeft(index));
                } else {
                  return buildRightItem(message, isLastMessageRight(index));
                }
              }),
        );
      },
    );
  }

  Widget buildLeftItem(Message message, bool isLastMessageLeft) {
    return StreamBuilder<Object>(
        stream: _database.getProfileStream(message.author),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return new Text(" ... ");
          }
          Profile profile = snapshot.data;

          double avatarRadius = 12.0;
          return Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 4, right: 4),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (isLastMessageLeft)
                  profile.getCircleAvatar(radius: avatarRadius),
                if (!isLastMessageLeft)
                  SizedBox(
                    width: avatarRadius * 2,
                  ),
                Expanded(
                  child: Bubble(
                    alignment: Alignment.topLeft,
                    color: Colors.grey.shade200,
                    child: Column(
                      children: <Widget>[
                        if (message.type == 'IMAGE')
                          Image(
                            image: FirebaseImage(message.imageURL),
                          ),
                        Text(
                          message.content,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget buildRightItem(Message message, bool isLastMessageRight) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Bubble(
            margin: BubbleEdges.only(top: 10),
            alignment: Alignment.topRight,
            color: Colors.amber.shade800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (message.type == 'IMAGE')
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ImageViewScreen(imageURL: message.imageURL),
                        ),
                      );
                    },
                    child: Image(
                      image: FirebaseImage(message.imageURL),
                      width: 200,
                    ),
                  ),
                Text(
                  message.content,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget showInput() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          border:
              Border(top: BorderSide(color: Colors.grey.shade200, width: 0.5)),
          color: Colors.white),
      child: Row(
        children: <Widget>[
          // Button  image
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(
                  Icons.image,
                  color: Colors.amber.shade800,
                ),
                onPressed: () {
                  _showSelectPictureMenu();
                },
                color: Colors.blue.shade800,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (_imageFile != null)
                  Stack(
                    fit: StackFit.loose,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageViewScreen(
                                imageFile: _imageFile,
                              ),
                            ),
                          );
                        },
                        child: Image.file(
                          _imageFile,
                          height: 100,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: InkWell(
                          child: Container(
                            color: Colors.grey,
                            child: Icon(
                              Icons.clear,
                              color: Colors.black,
                              size: 16.0,
                            ),
                          ),
                          onTap: () {
                            setState(() => _imageFile = null);
                          },
                        ),
                      ),
                    ],
                  ),
                TextField(
                  minLines: 1,
                  maxLines: 8,
                  style: TextStyle(fontSize: 15.0),
                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Ecrire un message...',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  focusNode: focusNode,
                ),
              ],
            ),
          ),

          // Button send message
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send, color: Colors.amber.shade800),
                onPressed: () {
                  if (textEditingController.text.isNotEmpty) {
                    Message newMessage = Message(
                        content: textEditingController.text,
                        creationDate: DateTime.now(),
                        author: widget.userID);
                    sendMessage(newMessage, widget.chatRoom);
                  }
                },
                color: Colors.blue.shade800,
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  void sendMessage(Message message, ChatRoom chatRoom) {
    bool isFirstMessage =
        chatRoom.lastMessage == '' || chatRoom.lastMessage == null;
    if (isFirstMessage) {
      chatRoom.lastMessage = message.content;
      chatRoom.lastMessageDate = message.creationDate;
      chatRoom.creatorID = message.author;
      _database.createChatRoom(chatRoom);
    }
    if (_imageFile != null) {
      message.type = 'IMAGE';
      _database.sendMessage(
          message: message, chatRoomID: chatRoom.id, imageFile: _imageFile);
      setState(() {
        _imageFile = null;
      });
    } else {
      message.type = 'TEXT';
      _database.sendMessage(message: message, chatRoomID: chatRoom.id);
    }
    textEditingController.clear();
  }

  bool isCurrentUserMessage(Message message) {
    if (message.author == widget.userID) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            _messages != null &&
            _messages[index - 1].author == widget.userID) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            _messages != null &&
            _messages[index - 1].author != widget.userID) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _showSelectPictureMenu() {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Envoyer une photo'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FlatButton.icon(
                  label: Text(
                    'Importer depuis la gallerie',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                  icon: Icon(
                    Icons.photo_library,
                    color: Colors.blue.shade800,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                FlatButton.icon(
                  label: Text('Prendre une photo',
                      style: TextStyle(color: Colors.blue.shade800)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                  icon: Icon(
                    Icons.photo_camera,
                    color: Colors.blue.shade800,
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Fermer'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected =
        await ImagePicker.pickImage(source: source, imageQuality: 50);
    if (selected != null) {
      setState(() {
        _imageFile = selected;
        _cropImage();
      });
    }
  }

  Future<void> _cropImage() async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: _imageFile.path,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Recadrer',
          toolbarColor: Colors.blue.shade800,
          //activeWidgetColor: Colors.blue.shade800,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.amber.shade800,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        title: 'Recadrer',
        doneButtonTitle: 'Valider',
        cancelButtonTitle: 'Retour',
        minimumAspectRatio: 1.0,
      ),
    );

    setState(() {
      _imageFile = cropped ?? _imageFile;
    });
  }
}
