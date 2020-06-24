import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meuh_life/components/RoundedDialog.dart';
import 'package:meuh_life/models/Member.dart';
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/services/DatabaseService.dart';

class JoinOrganisationScreen extends StatefulWidget {
  final String userID;

  const JoinOrganisationScreen({Key key, this.userID}) : super(key: key);

  @override
  _JoinOrganisationScreenState createState() => _JoinOrganisationScreenState();
}

class _JoinOrganisationScreenState extends State<JoinOrganisationScreen> {
  List<Organisation> _organisations;
  DatabaseService _database = DatabaseService();
  Member _member = Member();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _member.userID = widget.userID;
    _member.state = 'Requested';
    _member.role = 'Member';
  }

  List<Organisation> filterOrganisations(
      List<Organisation> organisations, List<Member> members) {
    print('Start Filtering: ');

    List<String> memberOrgas =
        members.map((member) => member.organisationID).toList();

    print('Members: $memberOrgas');
    List<Organisation> finalOrganisations = [];
    organisations.forEach((orga) {
      if (!memberOrgas.contains(orga.id)) finalOrganisations.add(orga);
    });

    return finalOrganisations;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rejoindre une organisation'),
      ),
      body: showOrganisationList(),
    );
  }

  Future<List<Organisation>> getOrganisations() async {
    //List of all the organisations
    List<Organisation> organisations = await _database.getOrganisationList();

    // List of all Members of the current user
    List<Member> memberOf = await _database.getMemberList(
        on: 'userID', onValueEqualTo: widget.userID);

    // List of organisation that the user does not belongs to
    List<Organisation> filteredOrgas =
        filterOrganisations(organisations, memberOf);

    return filteredOrgas;
  }

  Widget showOrganisationList() {
    return FutureBuilder(
      future: getOrganisations(),
      builder: (context, AsyncSnapshot<List<Organisation>> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.data.length == 0) {
          return Center(child: Text("Pas d'organisation à rejoindre"));
        }
        _organisations = snapshot.data;
        return ListView.builder(
            itemCount: _organisations.length,
            itemBuilder: (BuildContext context, int index) {
              Organisation organisation = _organisations[index];

              return InkWell(
                onTap: () => showJoinDialog(
                    context: context, organisation: organisation),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      organisation.getCircleAvatar(radius: 24.0),
                      SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              organisation.fullName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            organisation.description != null &&
                                    organisation.description.length > 0
                                ? Text(
                                    organisation.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  Future<void> showJoinDialog(
      {BuildContext context, Organisation organisation}) async {
    _member.organisationID = organisation.id;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return RoundedDialog(
          noAvatar: true,
          content: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Center(
                child: Text(
                  'Rejoindre\n${organisation.fullName}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Position',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                ),
              ),
              TextField(
                decoration: const InputDecoration(
                    labelText: "Position dans l'organisation",
                    hintText: 'Président, trésorier, VP...'),
                onChanged: (text) {
                  setState(() {
                    _member.position = text;
                  });
                },
              ),
              SizedBox(
                height: 8.0,
              ),
              Text(
                'Rôle (Permissions)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
              ),
              Text(_member.role),
              Align(
                alignment: Alignment.bottomRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  children: <Widget>[
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // To close the dialog
                      },
                      child: Text(
                        'Annuler',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        _database.createMember(_member);
                        Navigator.of(context).pop(); // To close the dialog
                      },
                      child: Text(
                        'Rejoindre',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
