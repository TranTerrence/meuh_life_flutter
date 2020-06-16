import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_image/firebase_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:meuh_life/components/SelectPublisher.dart';
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/models/Post.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/providers/CurrentUser.dart';
import 'package:meuh_life/services/DatabaseService.dart';
import 'package:meuh_life/services/HivePrefs.dart';

class EditPostScreen extends StatefulWidget {
  final dynamic post; //need to be cast to the right type
  final CurrentUser currentUser;

  const EditPostScreen(
      {Key key, @required this.post, @required this.currentUser})
      : super(key: key);

  @override
  _EditPostScreenState createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  String appBarTitle = 'Modifier une annonce';
  String submitButtonName = "Valider les changements";
  Post _post;

  //Event attributes
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  double _price;
  String _location;

  //End Event attributes

  DatabaseService database = DatabaseService();

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

  /// Select an image via gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    File selected =
        await ImagePicker.pickImage(source: source, imageQuality: 50);

    setState(() {
      _imageFile = selected;
      _cropImage();
    });
  }

  /// Remove image
  void _clear() {
    setState(() => _imageFile = null);
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _post = widget.post;
      //TODO: Manage edit post Event
      if (_post.type == 'EVENT') {
        _startDate = widget.post.startDate;
        _endDate = widget.post.endDate;
        _price = widget.post.price;
        _location = widget.post.location;
      }

      print(_post.imageURL);
    });

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
        title: Text(appBarTitle),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
            child: Column(
              children: <Widget>[
                showSelectPublisher(),
                showTitleField(),
                showDescriptionField(),
                SizedBox(
                  height: 16.0,
                ),
                Container(
                  //padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                  child: Column(
                    children: <Widget>[
                      showImagePickerButtons(),
                      showSelectedImage(),
                    ],
                  ),
                ),
                showTypeField(),
                if (widget.post.type == 'EVENT') showEventFields(),
                if (widget.post.type == 'INTERNSHIP') showStageFields(),
                showSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget showSelectPublisher() {
    void callback(newValue) {
      setState(() {
        widget.post.asOrganisation = newValue;
      });
    }

    return SelectPublisher(
        userID: widget.currentUser.id,
        value: widget.post.asOrganisation,
        callback: callback);
  }

  Future<List<DropdownMenuItem<String>>> getDropDownAs() async {
    double avatarRadius = 24.0;
    double itemHeight = 54.0;
    List<DropdownMenuItem<String>> list = [];
    List<Organisation> organisations =
        await database.getOrganisationListOf(widget.currentUser.id);
    organisations.forEach((organisation) {
      list.add(DropdownMenuItem<String>(
        value: organisation.id,
        child: Row(
          children: <Widget>[
            SizedBox(
              height: itemHeight,
            ),
            organisation.getCircleAvatar(radius: avatarRadius),
            SizedBox(
              width: 8.0,
            ),
            Text(organisation.fullName),
          ],
        ),
      ));
    });
    Profile profile = await database.getProfile(widget.currentUser.id);
    list.add(DropdownMenuItem<String>(
        value: '',
        child: Row(
          children: <Widget>[
            SizedBox(
              height: itemHeight,
            ),
            profile.getCircleAvatar(radius: avatarRadius),
            SizedBox(
              width: 8.0,
            ),
            Text(profile.fullName),
          ],
        )));
    return list;
  }

  Widget showTitleField() {
    return TextFormField(
      initialValue: _post.title,
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

  Widget showTypeField() {
    List<DropdownMenuItem<String>> list = [];
    Post.TYPES.forEach((key, value) {
      list.add(DropdownMenuItem<String>(
        value: key,
        child: Row(
          children: <Widget>[
            Post.TYPES_ICON[key],
            SizedBox(
              width: 8.0,
            ),
            Text(value),
          ],
        ),
      ));
    });
    return Row(
      children: <Widget>[
        Text(
          'Type de post: ',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            items: list,
            value: _post.type,
            icon: Icon(Icons.arrow_drop_down),
            onChanged: (String newValue) {
              setState(() {
                _post.type = newValue;
                switch (_post.type) {
                  case 'EVENT':
                    {
                      appBarTitle = "Modifier l'événement";
                    }
                    break;
                  case 'ANNOUNCE':
                    {
                      appBarTitle = "Modifier l'annonce";
                    }
                    break;

                  case 'INTERNSHIP':
                    {
                      appBarTitle = 'Modifier le stage';
                    }
                    break;
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget showDescriptionField() {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: TextFormField(
        initialValue: _post.description,
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
        controller: TextEditingController()..text = format.format(_startDate),
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
                  initialDate: _startDate,
                  firstDate: DateTime(2019),
                  lastDate: DateTime(2022),
                ).then((date) {
                  setState(() {
                    if (date != null) _startDate = date;
                  });
                  showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_startDate),
                    builder: (BuildContext context, Widget child) {
                      return Localizations.override(
                        context: context,
                        locale: Locale(_locale),
                        child: child,
                      );
                    },
                  ).then((time) {
                    setState(() {
                      _startDate = new DateTime(
                          _startDate.year,
                          _startDate.month,
                          _startDate.day,
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

  Widget showDateEndField() {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: TextFormField(
        controller: TextEditingController()..text = format.format(_endDate),
        readOnly: true,
        validator: (value) {
          if (_endDate.isBefore(_startDate)) {
            return "La date de fin doit être aprés la date de début";
          }
          return null;
        },
        decoration: InputDecoration(
          labelText: 'Date de fin',
          border: OutlineInputBorder(),
          suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                showDatePicker(
                  locale: Locale(_locale),
                  context: context,
                  initialDate: _endDate,
                  firstDate: DateTime.now().subtract(Duration(days: 31)),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                ).then((date) {
                  setState(() {
                    if (date != null) _endDate = date;
                  });
                  showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_endDate),
                    builder: (BuildContext context, Widget child) {
                      return Localizations.override(
                        context: context,
                        locale: Locale(_locale),
                        child: child,
                      );
                    },
                  ).then((time) {
                    setState(() {
                      _endDate = new DateTime(_endDate.year, _endDate.month,
                          _endDate.day, time.hour, time.minute);
                    });
                  });
                });
              }),
        ),
      ),
    );
  }

  Widget showLocationField() {
    return TextFormField(
      initialValue: _location,
      onSaved: (String value) {
        _location = value;
      },
      decoration: const InputDecoration(
        labelText: 'Lieu (optionnel)',
        prefixIcon: Icon(Icons.place),
      ),
    );
  }

  Widget showPriceField() {
    return TextFormField(
      initialValue: _price == null ? null : _price.toString(),
      onSaved: (String value) {
        if (value != '') _price = double.parse(value);
      },
      keyboardType: TextInputType.number,
      inputFormatters: [
        new WhitelistingTextInputFormatter(
            new RegExp('[0-9]*([\.])?[0-9]*')) // Allow only numbers and dots
      ],
      decoration: const InputDecoration(
        labelText: 'Prix (optionnel)',
        prefixIcon: Icon(Icons.euro_symbol),
      ),
      validator: (value) {
        if ('.'.allMatches(value).length > 1) {
          return "Le prix entrée n'est pas valide";
        }
        return null;
      },
    );
  }

  Widget showEventFields() {
    return Column(
      children: <Widget>[
        showDateStartField(),
        showDateEndField(),
        showLocationField(),
        showPriceField()
      ],
    );
  }

  Widget showStageFields() {
    return Column(
      children: <Widget>[
        showDateStartField(),
        showDateEndField(),
        showLocationField(),
      ],
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
    if (_imageFile != null) {
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
    } else if (_post.imageURL != null) {
      print('show Firebase image');
      print(_post.imageURL);
      return Image(
        image: FirebaseImage(_post.imageURL),
      );
    } else {
      return Container();
    }
  }

  Widget showSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Wrap(
        children: <Widget>[
          SizedBox(
            height: 40.0,
            child: RaisedButton(
              elevation: 4.0,
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(30.0)),
              color: Colors.red.shade800,
              textColor: Colors.white,
              onPressed: () {
                deletePost(_post);
                Navigator.pop(context);
              },
              child: Text(
                'Supprimer',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
          SizedBox(
            width: 8.0,
          ),
          SizedBox(
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
                }
              },
              child: Text(
                submitButtonName,
                style: TextStyle(fontSize: 16.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void deletePost(Post post) async {
    DatabaseService database = DatabaseService();
    database.deletePost(post);
  }

  void uploadDataToFirebase() async {
    print('SENDING DATA TO FIRESTORE');
    print(_post);
    //Cast the post to it's right child class
    switch (_post.type) {
      case 'EVENT':
        {
          //_post is now of type Event which extends post
          _post = _post.toEvent(
              startDate: _startDate,
              endDate: _endDate,
              price: _price,
              location: _location);
        }
        break;
      case 'ANNOUNCE':
        {}
        break;

      case 'INTERNSHIP':
        {}
        break;
    }

    _post.author = widget.currentUser.id;

    DocumentReference docRef =
        Firestore.instance.collection('posts').document(_post.id);

    print(_post.toJson());

    if (_imageFile != null) {
      _post.imageURL = 'gs://meuhlife.appspot.com/posts_images/${_post.id}';
      FirebaseStorage storage =
          FirebaseStorage(storageBucket: 'gs://meuhlife.appspot.com/');
      String filePath = 'posts_images/${_post.id}';
      storage.ref().child(filePath).putFile(_imageFile);
    }
    docRef.setData(_post.toJson());
  }

  void uploadPostImage() async {
    print('SENDING DATA TO Storage');
    final preferences = await HivePrefs.getInstance();
    String userID = preferences.getUserID();

    FirebaseStorage storage =
        FirebaseStorage(storageBucket: 'gs://meuhlife.appspot.com/');
    String filePath = 'posts_images/$userID';
    storage.ref().child(filePath).putFile(_imageFile);
  }
}
