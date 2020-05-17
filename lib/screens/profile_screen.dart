import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meuh_life/components/RoundedDialog.dart';
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/screens/create_organisation_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';
import 'package:meuh_life/services/authentication.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen(this.userID, this.auth, this.signOut);

  final BaseAuth auth;
  final String userID;
  final VoidCallback signOut;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile _profile;
  DatabaseService database = DatabaseService();
  File _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: StreamBuilder(
            stream: database.getProfileStream(widget.userID),
            builder: (context, snapshot) {
              print('Rebuilding the tree');
              if (!snapshot.hasData) {
                return new Text("Chargement ... ");
              }
              _profile = snapshot.data;
              return Column(
                children: [
                  showAvatar(),
                  Text(
                    _profile.getFullName(),
                    style: TextStyle(fontSize: 30, fontFamily: 'Marker'),
                  ),
                  Card(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Email',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(_profile.email),
                        ],
                      ),
                    ),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        showPromo(),
                        showType(),
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      showGapYear(),
                      showIsPAM(),
                    ],
                  ),
                  Card(
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Description',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _profile.description,
                                  maxLines: 12,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: Colors.blue.shade800,
                            ),
                            onPressed: () => _showEditDescription(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  showOrganisations(),
                  ButtonBar(
                    alignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      RaisedButton(
                        padding: EdgeInsets.all(12.0),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Colors.blue.shade800,
                        child: new Text('Paramétres'),
                        onPressed: () => print('Click Parametres'),
                      ),
                      RaisedButton(
                        padding: EdgeInsets.all(12.0),
                        shape: new RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Colors.blue.shade800,
                        child: new Text('Se déconnecter'),
                        onPressed: () => widget.signOut(),
                      ),
                    ],
                  ),
                ],
              );
            }),
      ),
    );
  }

  Widget showAvatar() {
    const double avatarRadius = 60.0;
    const double iconSize = 18.0;
    print('Show Avatar');
    return GestureDetector(
      onTap: () => _showSelectPictureMenu(),
      child: Stack(
        children: <Widget>[
          Center(child: _profile.getCircleAvatar(radius: avatarRadius)),
          Container(
            padding: EdgeInsets.only(
                top: avatarRadius * sqrt(3) - iconSize,
                left: avatarRadius + iconSize),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(6.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                    )
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  Icons.edit,
                  size: iconSize,
                  color: Colors.blue.shade800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget showPromo() {
    return Expanded(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Promo',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('P' + _profile.promo),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showType() {
    return Expanded(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Parcours',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_profile.getType()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showGapYear() {
    return Expanded(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Césurien',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_profile.gapYear ? 'Oui' : 'Non'),
                ],
              ),
              SizedBox(
                height: 16.0,
                child: Checkbox(
                    activeColor: Colors.blue.shade800,
                    value: _profile.gapYear,
                    onChanged: (bool value) => database
                        .updateProfile(widget.userID, {"gapYear": value})),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget showIsPAM() {
    return Expanded(
      child: Card(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'PAM',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(_profile.isPAM ? 'Oui' : 'Non'),
                ],
              ),
              SizedBox(
                height: 16.0,
                child: Checkbox(
                    activeColor: Colors.blue.shade800,
                    value: _profile.isPAM,
                    onChanged: (bool value) => database
                        .updateProfile(widget.userID, {"isPAM": value})),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSelectPictureMenu() {
    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return RoundedDialog(
            noAvatar: true,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Changer de photo',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 16.0,
                ),
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
                Align(
                  alignment: Alignment.bottomRight,
                  child: FlatButton(
                    child: Text(
                      'Fermer',
                      style: TextStyle(color: Colors.blue.shade800),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> _showEditDescription() {
    final textInputController =
        TextEditingController(text: _profile.description);

    return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return RoundedDialog(
            noAvatar: true,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Modifier la description',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: TextField(
                    minLines: 2,
                    maxLines: 5,
                    cursorColor: Colors.blue.shade800,
                    controller: textInputController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      helperText: "Présente toi",
                      labelText: 'Description',
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: ButtonBar(
                    children: <Widget>[
                      FlatButton(
                        child: Text(
                          'Annuler',
                          style: TextStyle(color: Colors.blue.shade800),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text(
                          'Sauvegarder',
                          style: TextStyle(color: Colors.blue.shade800),
                        ),
                        onPressed: () {
                          //Avoid writing to the DB if it's not necessary
                          if (textInputController.text !=
                              _profile.description) {
                            database.updateProfile(widget.userID,
                                {"description": textInputController.text});
                          }
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget showOrganisations() {
    return Card(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Organisations',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Container(
              child: StreamBuilder(
                  stream: database.getMemberListStream(
                      on: 'userID', onValueEqualTo: widget.userID),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Text('No Member data for ${widget.userID}'),
                      );
                    } else {
                      List<Member> members = snapshot.data;
                      return ListView.builder(
                          shrinkWrap: true,
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            Member member = members[index];
                            return buildMember(context, member);
                          });
                    }
                  }),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: OutlineButton.icon(
                  onPressed: () =>
                  {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CreateOrganisationScreen(widget.userID)),
                    ),
                  },
                  icon: Icon(
                    Icons.add,
                    color: Colors.blue.shade800,
                  ),
                  label: Text('Créer une organisation'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _cropImage(File imageFile) async {
    File cropped = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      cropStyle: CropStyle.circle,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
      ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Recadrer',
          toolbarColor: Colors.blue.shade800,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: Colors.amber.shade800,
          initAspectRatio: CropAspectRatioPreset.original,
          hideBottomControls: true,
          lockAspectRatio: true),
      iosUiSettings: IOSUiSettings(
        title: 'Recadrer',
        doneButtonTitle: 'Valider',
        cancelButtonTitle: 'Retour',
        minimumAspectRatio: 1.0,
      ),
    );

    // TODO: Check if a photo has been selected before updating (save 1 write and 1 upload)
    setState(() {
      _imageFile = cropped ?? _imageFile;
      String folder = 'profiles_images';
      String fileName = widget.userID;
      database.uploadFile(_imageFile, folder, fileName);
      database.updateProfile(
          widget.userID, {'picUrl': database.getFileURL(folder, fileName)});
      _profile.picUrl = database.getFileURL(folder, fileName);
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    File selected =
    await ImagePicker.pickImage(source: source, imageQuality: 50);
    if (selected != null) {
      setState(() {
        _imageFile = selected;
        _cropImage(selected);
      });
    }
  }

  Widget buildMember(BuildContext context, Member member) {
    return StreamBuilder(
        stream: database.getOrganisationStream(member.organisationID),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text('No Organisation Data for this member'),
            );
          } else {
            Organisation organisation = snapshot.data;
            return Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: InkWell(
                  onTap: () =>
                      organisation.showDetailedDialog(context, organisation),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      organisation.getCircleAvatar(radius: 24.0),
                      SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(organisation.fullName,
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            if (member.position != '') Text(member.position),
                            Text(member.getRole()),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${organisation.members.length}',
                            style: TextStyle(
                                fontSize: 18.0, color: Colors.blue.shade800),
                          ),
                          Icon(
                            organisation.members.length == 1
                                ? Icons.person
                                : Icons.people,
                            color: Colors.blue.shade800,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        });
  }
}
