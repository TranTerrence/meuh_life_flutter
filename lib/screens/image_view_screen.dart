import 'dart:io';

import 'package:firebase_image/firebase_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewScreen extends StatelessWidget {
  final String imageURL;
  final File imageFile;

  const ImageViewScreen({Key key, this.imageURL, this.imageFile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
      ),
      body: Container(
        child: PhotoView(
          imageProvider: getImageProvider(context),
        ),
      ),
    );
  }

  ImageProvider getImageProvider(BuildContext context) {
    if (imageFile != null) {
      return AssetImage(imageFile.path);
    } else if (imageURL != null) {
      return FirebaseImage(imageURL);
    } else {
      Navigator.pop(context);
    }
  }
}
