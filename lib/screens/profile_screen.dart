import 'dart:io';
import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meuh_life/components/RoundedDialog.dart';
import 'package:meuh_life/models/Member.dart';
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/providers/CurrentUser.dart';
import 'package:meuh_life/screens/create_organisation_screen.dart';
import 'package:meuh_life/screens/edit_organisation_screen.dart';
import 'package:meuh_life/screens/edit_profile_screen.dart';
import 'package:meuh_life/screens/join_organisation_screen.dart';
import 'package:meuh_life/services/DatabaseService.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Profile _profile;
  DatabaseService database = DatabaseService();
  File _imageFile;
  CurrentUser currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = Provider.of<CurrentUser>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        key: PageStorageKey('profile_screen'),
        padding: EdgeInsets.all(16.0),
        child: StreamBuilder(
            stream: database.getProfileStream(currentUser.id),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              _profile = snapshot.data;
              return Column(
                children: [
                  showAvatar(),
                  Text(
                    _profile.fullName,
                    style: TextStyle(fontSize: 30, fontFamily: 'Marker'),
                  ),
                  OutlineButton.icon(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.blue.shade800,
                    ),
                    color: Colors.blue.shade800,
                    label: Text('Modifier le profil'),
                    onPressed: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                                  currentUser: currentUser,
                                  profile: _profile,
                                )),
                      ),
                    },
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
                        child: new Text('Se déconnecter'),
                        onPressed: () => currentUser.signOut(),
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
                  Icons.add_photo_alternate,
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
                FlatButton.icon(
                  label: Text('Supprimer la photo',
                      style: TextStyle(color: Colors.red.shade800)),
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red.shade800,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _clearImage();
                  },
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
                      on: 'userID', onValueEqualTo: currentUser.id),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Text('No Member data for ${currentUser.id}'),
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
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              JoinOrganisationScreen(userID: currentUser.id)),
                    ),
                  },
                  icon: Icon(
                    Icons.group_add,
                    color: Colors.blue.shade800,
                  ),
                  label: Text('Rejoindre une organisation'),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: OutlineButton.icon(
                  onPressed: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CreateOrganisationScreen(currentUser.id)),
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

    _imageFile = cropped ?? _imageFile;
    String folder = 'profiles_images';
    String fileName = currentUser.id;
    StorageUploadTask uploadTask =
        database.uploadFile(_imageFile, folder, fileName);
    await uploadTask.onComplete;
    // TODO: Check if a photo has been selected before updating (save 1 write and 1 upload)
    setState(() {
      database.updateProfile(
          currentUser.id, {'picUrl': database.getFileURL(folder, fileName)});
      _profile.picUrl = database.getFileURL(folder, fileName);
    });
  }

  void _clearImage() {
    setState(() {
      database.updateProfile(currentUser.id, {'picUrl': ''});
      _imageFile = null;
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
    bool isOwner = member.role == 'Owner';
    bool isAdmin = member.role == 'Admin';

    bool canEditOrga = isOwner || isAdmin;
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
                            Text(member.getRole() +
                                (member.state == 'Requested'
                                    ? ' (En Attente de validation)'
                                    : '')),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (canEditOrga)
                            IconButton(
                              icon: Icon(Icons.edit),
                              color: Colors.blue.shade800,
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        EditOrganisationScreen(
                                          userID: currentUser.id,
                                          organisation: organisation,
                                        )),
                              ),
                            ),
                          // TODO create a cloud function to retrieve the number of request
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
