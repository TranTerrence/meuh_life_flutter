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
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/screens/image_view_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';

class ConversationScreen extends StatefulWidget {
  final ChatRoom chatRoom;
  final Profile
      toProfile; // Profile talking in order to avoid making the call here
  final Organisation
      toOrganisation; // Organisation talking to, avoid making the call here
  final String userID; // ID of the current user talking
  final String
  asOrganisation; // The current user is talking as an organisation, ID of the organisation the one is talking as

  const ConversationScreen({Key key,
    @required this.chatRoom,
    this.toProfile,
    this.toOrganisation,
    this.asOrganisation,
    @required this.userID})
      : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<Message> _messages;
  DatabaseService _database = DatabaseService();
  Widget _appBarTitle = Container();
  File _imageFile;
  Widget _toAvatar;
  String _title = '';
  double _avatarRadius = 20.0;

  final TextEditingController textEditingController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    setState(() {
      switch (widget.chatRoom.type) {
        case 'SINGLE_USER':
          if (widget.toProfile != null) {
            _toAvatar = widget.toProfile.getCircleAvatar(radius: _avatarRadius);
            _title = widget.toProfile.fullName;
          }
          break;

        case 'SINGLE_ORGANISATION':
          if (widget.asOrganisation != null && widget.asOrganisation != '') {
            if (widget.toProfile != null) {
              _toAvatar =
                  widget.toProfile.getCircleAvatar(radius: _avatarRadius);
              _title = widget.toProfile.fullName;
            }
            print('I am  As organisation: ${widget.asOrganisation}');
          } else if (widget.toOrganisation.id != null) {
            _toAvatar =
                widget.toOrganisation.getCircleAvatar(radius: _avatarRadius);
            _title = widget.toOrganisation.fullName;
            print('I am  orga: ${widget.toOrganisation.id}');
          }

          break;

        case 'GROUP':
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber.shade800,
        title: Container(
          child: Row(
            children: <Widget>[
              if (_toAvatar != null) _toAvatar,
              if (_toAvatar != null)
                SizedBox(
                  width: 8.0,
                ),
              Text(_title)
            ],
          ),
        ),
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
                bool isLeftMessage = checkIfLeftMessage(message);

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

  bool checkIfLeftMessage(Message message) {
    bool asOrganisation =
        widget.asOrganisation != null && widget.asOrganisation != '';
    if (asOrganisation) return widget.asOrganisation != message.organisationID;
    bool isLeftMessage = message.author != widget.userID;

    return isLeftMessage;
  }

  Widget buildLeftItem(Message message, bool isLastMessageLeft) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 4, right: 80, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          if (isLastMessageLeft) _toAvatar,
          if (!isLastMessageLeft)
            SizedBox(
              width: _avatarRadius * 2,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Bubble(
                  alignment: Alignment.topLeft,
                  color: Colors.grey.shade200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                if (message.asOrganisation) getAuthorProfile(message.author),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getAuthorProfile(String authorID) {
    return FutureBuilder(
        future: _database.getProfile(authorID),
        builder: (context, AsyncSnapshot<Profile> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          Profile profile = snapshot.data;
          return Padding(
            padding: const EdgeInsets.only(left: 14.0),
            child: Text(
              profile.firstName,
              style: TextStyle(fontSize: 12.0),
            ),
          );
        });
  }

  Widget buildRightItem(Message message, bool isLastMessageRight) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 80, right: 4, bottom: 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              children: <Widget>[
                Bubble(
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
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                if (message.asOrganisation) getAuthorProfile(message.author),
              ],
            ),
          ),
        ],
      ),
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
                      author: widget.userID,
                      asOrganisation: widget.asOrganisation != null &&
                          widget.asOrganisation != '',
                      organisationID: widget.asOrganisation,
                    );
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
