import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:meuh_life/models/Post.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  Post _post = Post.create(startDate: DateTime.now());
  String _locale = 'fr';
  DateFormat format = DateFormat('EEEE dd MMMM à HH:mm');
  File _imageFile;

  /// Cropper plugin
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
          activeWidgetColor: Colors.blue.shade800,
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

  /// Select an image via gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    File selected =
    await ImagePicker.pickImage(source: source, imageQuality: 50);

    setState(() {
      _imageFile = selected;
    });
  }

  /// Remove image
  void _clear() {
    setState(() => _imageFile = null);
  }

  @override
  void initState() {
    super.initState();

    initializeDateFormatting(_locale, null).then((_) {
      setState(() {
        format = DateFormat('EEEE dd MMMM à HH:mm', _locale);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Text('Ajouter un post'),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
            child: Column(
              children: <Widget>[
                showTitleField(),
                showDescriptionField(),
                SizedBox(
                  height: 16.0,
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: _imageFile != null
                            ? Colors.blue.shade800
                            : Colors.grey,
                        width: _imageFile != null ? 3.0 : 1.0),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5.0),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Ajouter une image',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      showImagePickerButtons(),
                      if (_imageFile != null) showSelectedImage(),
                    ],
                  ),
                ),
                showDateStartField(),
                showSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showTitleField() {
    return TextFormField(
      onSaved: (String value) {
        _post.title = value;
      },
      decoration: const InputDecoration(
        labelText: 'Titre du poste',
      ),
      validator: (value) {
        if (value.isEmpty) {
          return 'Le titre ne peut pas être vide';
        }
        return null;
      },
    );
  }

  Widget showDescriptionField() {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: TextFormField(
        minLines: 2,
        maxLines: 5,
        cursorColor: Colors.blue.shade800,
        onSaved: (String value) {
          _post.description = value;
        },
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          helperText: 'Entre les détails de ton post',
          labelText: 'Description',
        ),
      ),
    );
  }

  Widget showDateStartField() {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: TextField(
        controller: TextEditingController()
          ..text = format.format(_post.startDate),
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Date de début',
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                showDatePicker(
                  locale: Locale(_locale),
                  context: context,
                  initialDate: _post.startDate,
                  firstDate: DateTime(2019),
                  lastDate: DateTime(2022),
                ).then((date) {
                  setState(() {
                    _post.startDate = date;
                  });
                  showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_post.startDate),
                    builder: (BuildContext context, Widget child) {
                      return Localizations.override(
                        context: context,
                        locale: Locale(_locale),
                        child: child,
                      );
                    },
                  ).then((time) {
                    setState(() {
                      _post.startDate = new DateTime(
                          _post.startDate.year,
                          _post.startDate.month,
                          _post.startDate.day,
                          time.hour,
                          time.minute);
                    });
                  });
                });
              }),
        ),
      ),
    );
  }

  Widget showImagePickerButtons() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.photo_camera,
            size: 30,
          ),
          onPressed: () => _pickImage(ImageSource.camera),
          color: Colors.blue.shade800,
        ),
        IconButton(
          icon: Icon(
            Icons.photo_library,
            size: 30,
          ),
          onPressed: () => _pickImage(ImageSource.gallery),
          color: Colors.amber.shade800,
        ),
      ],
    );
  }

  Widget showSelectedImage() {
    return Column(children: <Widget>[
      Image.file(_imageFile),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FlatButton(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue.shade800,
            child: Icon(Icons.crop, color: Colors.white),
            onPressed: _cropImage,
          ),
          FlatButton(
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.red.shade800,
            child: Icon(
              Icons.delete_forever,
              color: Colors.white,
            ),
            onPressed: _clear,
          ),
        ],
      ),
    ]);
  }

  Widget showSubmitButton() {
    return new Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: SizedBox(
          height: 40.0,
          child: RaisedButton(
            elevation: 4.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.blue.shade800,
            textColor: Colors.white,
            onPressed: () {
              // Validate returns true if the form is valid, or false
              // otherwise.

              if (_formKey.currentState.validate()) {
                _formKey.currentState.save();
                uploadDataToFirebase();
                Navigator.pop(context);
                print(
                    'title: ${_post.title} and description: ${_post.description} startDate ${_post.startDate}');
              }
            },
            child: Text(
              'Créer le post',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ),
    );
  }

  void uploadDataToFirebase() async {
    print('SENDING DATA TO FIRESTORE');
    print(_post);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    _post.author = prefs.getString('userID');

    DocumentReference docRef =
    Firestore.instance.collection('posts').document();

    docRef.setData(_post.toJson());

    if (_imageFile != null) {
      _post.imageURL =
      'gs://meuh-life.appspot.com/posts_images/${docRef.documentID}';
      FirebaseStorage storage =
      FirebaseStorage(storageBucket: 'gs://meuh-life.appspot.com/');
      String filePath = 'posts_images/${docRef.documentID}';
      StorageUploadTask uploadTask =
      storage.ref().child(filePath).putFile(_imageFile);
    }
    docRef.setData(_post.toJson());
  }

  void uploadPostImage() async {
    print('SENDING DATA TO Storage');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userID = prefs.getString('userID');
    FirebaseStorage storage =
    FirebaseStorage(storageBucket: 'gs://meuh-life.appspot.com/');
    String filePath = 'posts_images/$userID';
    storage.ref().child(filePath).putFile(_imageFile);
  }
}
