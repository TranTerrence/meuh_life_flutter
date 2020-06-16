import 'package:flutter/material.dart';
import 'package:meuh_life/models/Organisation.dart';
import 'package:meuh_life/models/Profile.dart';
import 'package:meuh_life/services/DatabaseService.dart';

class SelectPublisher extends StatefulWidget {
  final String userID;
  final String value;
  final Function callback;

  const SelectPublisher({Key key, this.userID, this.value, this.callback})
      : super(key: key);

  @override
  _SelectPublisherState createState() => _SelectPublisherState();
}

class _SelectPublisherState extends State<SelectPublisher> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DropdownMenuItem<String>>>(
        future: getDropDownAs(),
        builder:
            (context, AsyncSnapshot<List<DropdownMenuItem<String>>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<DropdownMenuItem<String>> list = snapshot.data;
            //Get each organisation for each membership
            return Container(
              decoration: new BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  border: new Border.all(color: Colors.grey)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  items: list,
                  value: widget.value,
                  icon: Icon(Icons.arrow_drop_down),
                  onChanged: (String newValue) {
                    if (newValue != null) {
                      widget.callback(newValue);
                    }
                  },
                ),
              ),
            );
          }
        });
  }

  Future<List<DropdownMenuItem<String>>> getDropDownAs() async {
    DatabaseService database = DatabaseService();
    double avatarRadius = 24.0;
    double itemHeight = 54.0;
    List<DropdownMenuItem<String>> list = [];
    List<Organisation> organisations =
        await database.getOrganisationListOf(widget.userID);
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
    Profile profile = await database.getProfile(widget.userID);
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
}
