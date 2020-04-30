import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../Dashboard/Dashboard.dart';
import '../../components/LargeAvatar.dart';
import '../../constants.dart';

class GetStarted extends StatelessWidget {
  static const routeName = '/get-started';
  static const pageTitle = 'Get Started';

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        minimum: EdgeInsets.symmetric(horizontal: 15),
        child: GetStartedContent(),
      ),
    );
  }
}

class GetStartedContent extends StatefulWidget {
  @override
  _GetStartedContentState createState() => _GetStartedContentState();
}

class _GetStartedContentState extends State<GetStartedContent> {
  bool isLoading = false;
  bool isValid = false;

  String name;
  ImageProvider imageProvider =
      AssetImage('assets/images/defaultAvatarLarge.png');

  void onTapContinue(BuildContext context) async {
    this.setState(() {
      this.isLoading = true;
    });

    String imageURL;
    if (this.imageProvider is FileImage) {
      imageURL = await (await FirebaseStorage.instance
              .ref()
              .child('userImage/${Constants().currentUserId}')
              .putFile((this.imageProvider as FileImage).file)
              .onComplete)
          .ref
          .getDownloadURL();
    }

    FirebaseAuth.instance.currentUser().then((firebaseUser) {
      Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .setData({'name': this.name, 'imageURL': imageURL});
    });

    Navigator.of(context).pushNamedAndRemoveUntil(
        Dashboard.routeName, (Route<dynamic> route) => false);
  }

  void onNameChanged(String name) {
    this.name = name;
    if (name.length == 0 && this.isValid) {
      this.setState(() {
        this.isValid = false;
      });
    } else if (name.length > 0 && !this.isValid) {
      this.setState(() {
        this.isValid = true;
      });
    }
  }

  void onImageUpdated(File imageFile) {
    this.setState(() {
      this.imageProvider = FileImage(imageFile);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 44),
          Text('Let\'s get started.',
              style: Theme.of(context).textTheme.display4),
          SizedBox(height: 10),
          Center(
            child: LargeAvatar(
              editMode: true,
              autoFocus: true,
              name: this.name,
              onNameChanged: this.onNameChanged,
              onNameSubmitted: (_) => this.onTapContinue(context),
              imageProvider: imageProvider,
              onImageUpdated: this.onImageUpdated,
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(bottom: this.isLoading ? 20 : 10),
              child: this.isLoading
                  ? CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    )
                  : FlatButton(
                      onPressed: this.isValid
                          ? () => this.onTapContinue(context)
                          : null,
                      child: Text(
                        'Continue',
                        style: this.isValid
                            ? Theme.of(context).textTheme.button
                            : Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
