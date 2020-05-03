import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:meuh_life/models/Post.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

Future getUserID() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userID');
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  Post _post = Post.create(startDate: DateTime.now());
  String _locale = 'fr';
  DateFormat format = DateFormat('EEEE dd MMMM à HH:mm');

  @override
  void initState() {
    // TODO: implement initState
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
                pushDataToFirestore();
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

  void pushDataToFirestore() async {
    print('SENDING DATA TO FIRESTORE');
    print(_post);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _post.author = prefs.getString('userID');
    Firestore.instance.collection('posts').document().setData(_post.toJson());
    Navigator.pop(context);
  }
}
