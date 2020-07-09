![Meuh Life logo](https://github.com/TranTerrence/meuh_life_flutter/blob/master/images/logo.png)
# Meuh Life

Meuh Life is a mobile App aiming to become the new social network of the school MINES ParisTech. 
It provides a space to facilitate communication and inclusion within the school.
This repository contains all the files for the mobile App Meuh Life.

## About the project
Meuh Life is born to provide a project to train and learn flutter for the students.
To facilitate the development, we have used Firebase as a Backend.

## Getting Started

### 1 - Learn Flutter 
If you want to learn flutter rapidly, we highly recommend following this **free tutorial**:
[App brewery - Introduction to Flutter](https://www.appbrewery.co/p/intro-to-flutter)
It's a 10h course that will teach you everything you need to get started no prior experience required. They also give you a certification at the end for free.
Tip: Speed up the video on the configuration at the bottom right corner of each video.

### 2 - Install Android Studio and the Flutter plugins
Follow the tutorial from above, they are explaining quite well how to install everything on Section 2: [How to setup Android Studio and flutter](https://www.appbrewery.co/courses/intro-to-flutter/lectures/15448537)
### 3 - Clone the repository
If you have Android Studio: Follow this video to learn [how to clone the project in 4 min](https://www.youtube.com/watch?v=_ey3pZt9Afs)

### 4 - Launch the code on your phone or on the emulator
Execute the `pub get` command to download the packages from `pubspec.yaml`.
Then follow the [Section 4 of the tutorial](https://www.appbrewery.co/courses/851555/lectures/15448509) to run the code on your device or on an emulator.

#### 4.1 - Run on iOS
References: 
* [https://flutter.dev/docs/get-started/install/macos](https://flutter.dev/docs/get-started/install/macos)
* [https://firebase.google.com/docs/flutter/setup](https://firebase.google.com/docs/flutter/setup)

Download GoogleService-Info.plist from Firebase, and add it to your project through XCode.  
 (It must be done through XCode, otherwise it won't compile: [https://github.com/flutter/flutter/issues/16871](https://github.com/flutter/flutter/issues/16871)).
 
 You should then be good to go, just launch the emulator and run the following command:
 
 ```bash
 flutter run
 ```

## Structure of the files
|FIle |Description|
|---|---|
|functions|All the cloud functions of Firebase: managing notifications, comments and like counts|
|lib|All the flutter codes|

## Useful links
A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
[App brewery - Introduction to Flutter](https://www.appbrewery.co/p/intro-to-flutter)

[Pub.dev the library to intall packages](https://pub.dev/)
