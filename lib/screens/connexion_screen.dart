import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/services/authentication.dart';
import 'package:meuh_life/services/utils.dart';

class ConnexionScreen extends StatefulWidget {
  ConnexionScreen({this.auth, this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<StatefulWidget> createState() => new _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  final _formKey = new GlobalKey<FormState>();

  String _fullName;
  String _password;
  String _promo;
  String _errorMessage;
  String _type = 'ENGINEER';
  bool _gapYear = false;
  bool _isPAM = false;

  bool _isLoginForm;
  bool _isLoading;
  bool _passwordVisible = false;

  // Check if form is valid before perform login or signup
  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      String userId = "";
      var splitFullName = _fullName.split(".");
      String _firstName = splitFullName[0];
      String _lastName = splitFullName[1];

      Profile profile = new Profile(
          firstName: _firstName,
          lastName: _lastName,
          promo: _promo,
          gapYear: _gapYear,
          isPAM: _isPAM,
          type: _type);
      print('LOGGING');

      try {
        if (_isLoginForm) {
          print('Logging in');

          userId = await widget.auth.signIn(profile.email, _password);
          print('Signed in: $userId');
        } else {
          print('Creation of account');

          userId = await widget.auth.signUp(profile.email, _password);
          widget.auth.sendEmailVerification();
          _showVerifyEmailSentDialog(profile.email);
          print('Signed up user: $userId');
          profile.id = userId;
          Firestore.instance
              .collection('users')
              .document(userId)
              .setData(profile.toJson());
        }
        setState(() {
          _isLoading = false;
        });

        if (userId.length > 0 && userId != null && _isLoginForm) {
          widget.loginCallback();
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
          //_formKey.currentState.reset();
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    _passwordVisible = false;

    super.initState();
  }

  void toggleFormMode() {
    setState(() {
      _isLoginForm = !_isLoginForm;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: Stack(
      children: <Widget>[
        _showForm(),
        _showCircularProgress(),
      ],
    ));
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Container();
  }

  void _showVerifyEmailSentDialog(String email) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Vérifie ton email"),
          content: new Text(
              "Le lien pour vérifier ton email a été envoyé à \n$email \nTu auras besoin de le valider pour pour pouvoir utiliser l'application"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Fermer"),
              onPressed: () {
                toggleFormMode();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Widget _showForm() {
    return new SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: new Form(
          key: _formKey,
          child: SafeArea(
            child: new Column(
              children: <Widget>[
                showLogo(),
                SizedBox(height: 16.0),
                showFullNameInput(),
                SizedBox(height: 16.0),
                showPasswordInput(),
                SizedBox(height: 16.0),
                if (!_isLoginForm) showPromoInput(),
                if (!_isLoginForm) showGapYearInput(),
                if (!_isLoginForm) showPAMInput(),
                if (!_isLoginForm) showTypeSelect(),
                showPrimaryButton(),
                showSecondaryButton(),
                showErrorMessage(),
              ],
            ),
          ),
        ));
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget showLogo() {
    return Column(
      children: <Widget>[
        Image.asset(
          'images/logo.png',
          width: 200,
        ),
        Text(
          'Meuh Life',
          style: TextStyle(
            color: Colors.blue.shade800,
            fontFamily: 'Marker',
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
      ],
    );
  }

  Widget showFullNameInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new TextFormField(
          maxLines: 1,
          keyboardType: TextInputType.text,
          autofocus: false,
          inputFormatters: [
            new BlacklistingTextInputFormatter(new RegExp('[ -]'))
          ],
          decoration: new InputDecoration(
              border: new OutlineInputBorder(
                  borderSide: new BorderSide(color: Colors.blue.shade800)),
              labelText: 'prénom.nom',
              icon: new Icon(
                Icons.mail,
                color: Colors.blue.shade800,
              )),
          validator: (value) => value.split('.').length != 2
              ? 'doit être de la forme prénom.nom'
              : null,
          onSaved: (value) => _fullName = value.trim(),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Text(
            '@mines-paristech.fr',
            style: TextStyle(
                color: Colors.blue.shade800, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget showPromoInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.number,
        autofocus: false,
        maxLength: 2,
        inputFormatters: [
          WhitelistingTextInputFormatter.digitsOnly,
        ],
        decoration: new InputDecoration(
            border: new OutlineInputBorder(
                borderSide: new BorderSide(color: Colors.blue.shade800)),
            labelText: 'Promotion',
            hintText: 'Entrer 17 pour 2017',
            icon: new Icon(
              Icons.perm_contact_calendar,
              color: Colors.blue.shade800,
            )),
        validator: (value) => value.isEmpty ? 'Promo can\'t be empty' : null,
        onSaved: (value) => _promo = value.trim(),
      ),
    );
  }

  Widget showGapYearInput() {
    return InkWell(
      onTap: () {
        setState(() {
          _gapYear = !_gapYear;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.airplanemode_active,
            color: Colors.blue.shade800,
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text('Césurien'),
          )),
          Checkbox(
              value: _gapYear,
              onChanged: (bool value) => {
                    setState(() {
                      _gapYear = value;
                    }),
                  })
        ],
      ),
    );
  }

  Widget showPAMInput() {
    return InkWell(
      onTap: () {
        setState(() {
          _gapYear = !_gapYear;
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.home,
            color: Colors.blue.shade800,
          ),
          Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Text('PAM (Pas à la Meuh)'),
              )),
          Checkbox(
              value: _isPAM,
              onChanged: (bool value) =>
              {
                setState(() {
                  _isPAM = value;
                }),
              })
        ],
      ),
    );
  }

  Widget showTypeSelect() {
    return Row(
      children: <Widget>[
        Icon(
          Icons.school,
          color: Colors.blue.shade800,
        ),
        SizedBox(
          width: 16.0,
        ),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _type,
            icon: Icon(Icons.arrow_drop_down),
            onChanged: (String newValue) {
              setState(() {
                _type = newValue;
              });
            },
            items: createDropdownMenuItemList(Profile.types),
          ),
        ),
      ],
    );
  }

  Widget showPasswordInput() {
    return new TextFormField(
      maxLines: 1,
      obscureText: !_passwordVisible,
      autofocus: false,
      decoration: new InputDecoration(
        border: new OutlineInputBorder(
            borderSide: new BorderSide(color: Colors.blue.shade800)),
        labelText: 'Mot de passe',
        hintText: 'Mot de passe',
        suffixIcon: IconButton(
          icon: Icon(
            // Based on passwordVisible state choose the icon
            _passwordVisible ? Icons.visibility : Icons.visibility_off,
            color: Theme
                .of(context)
                .primaryColorDark,
          ),
          onPressed: () {
            // Update the state i.e. toogle the state of passwordVisible variable
            setState(() {
              _passwordVisible = !_passwordVisible;
            });
          },
        ),
        icon: new Icon(
          Icons.lock,
          color: Colors.blue.shade800,
        ),
      ),
      validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
      onSaved: (value) => _password = value.trim(),
    );
  }

  Widget showSecondaryButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: new FlatButton(
          child: new Text(
              _isLoginForm ? 'Créer un compte' : 'Déjà un compte? Connecte toi',
              style:
              new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w300)),
          onPressed: toggleFormMode),
    );
  }

  Widget showPrimaryButton() {
    return new Padding(
      padding: EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 0.0),
      child: SizedBox(
        height: 40.0,
        child: new RaisedButton(
          elevation: 5.0,
          shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(30.0)),
          color: Colors.blue.shade800,
          child: new Text(_isLoginForm ? 'Se connecter' : 'Créer un compte',
              style: new TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: validateAndSubmit,
        ),
      ),
    );
  }
}
