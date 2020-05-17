import 'package:flutter/material.dart';

class RoundedDialog extends StatelessWidget {
  final Widget content;
  final Widget circleAvatar;
  final double circleRadius;
  final bool noAvatar;
  static const double padding = 16.0;

  const RoundedDialog(
      {Key key,
      this.content,
      this.circleAvatar,
      this.circleRadius = 0,
      this.noAvatar = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
              top: noAvatar ? padding : circleRadius + padding,
              bottom: padding / 2,
              left: padding,
              right: padding,
            ),
            margin: EdgeInsets.only(top: noAvatar ? 0 : circleRadius),
            decoration: new BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(padding),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
                ),
              ],
            ),
            child: content,
          ),
          if (!noAvatar)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                circleAvatar,
              ],
            ),
        ],
      ),
    );
  }
}
