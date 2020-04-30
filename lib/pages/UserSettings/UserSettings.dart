import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_overlay/loading_overlay.dart';

import '../../constants.dart';
import '../../components/TitleBar.dart';
import '../../components/LargeAvatar.dart';
import '../Login/Login.dart';
import '../../Models/User.dart';

class UserSettings extends StatelessWidget {
  static const routeName = '/user-settings';
  static const pageTitle = 'User Settings';

  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 15),
        child: _UserSettingsContent(),
      ),
    );
  }
}

class _UserSettingsContent extends StatefulWidget {
  @override
  _UserSettingsContentState createState() => _UserSettingsContentState();
}

class _UserSettingsContentState extends State<_UserSettingsContent> {
  bool editMode = false;
  bool isLoading = false;

  String name;
  ImageProvider imageProvider =
      AssetImage(Constants().defaultUserAvatarAssetPath);

  Stream<DocumentSnapshot> documentSnapshotStream;
  User user;

  @override
  void initState() {
    documentSnapshotStream = Firestore.instance
        .collection(Constants().firestoreUsersCollection)
        .document(Constants().currentUserId)
        .snapshots();
    super.initState();
  }

  void leftButtonOnTap() {
    if (this.editMode) {
      setState(() {
        this.editMode = false;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void rightButtonOnTap() async {
    if (this.editMode) {
      this.editMode = false;

      final tempUser = User();
      tempUser.name = this.name;

      if (this.imageProvider is FileImage) {
        this.setState(() {
          this.isLoading = true;
        });
        tempUser.imageURL = await (await FirebaseStorage.instance
                .ref()
                .child(
                    '${Constants().firebaseStorageUserImagesPath}/${Constants().currentUserId}')
                .putFile((this.imageProvider as FileImage).file)
                .onComplete)
            .ref
            .getDownloadURL();
        this.isLoading = false;
      } else if (this.imageProvider is CachedNetworkImageProvider) {
        tempUser.imageURL =
            (this.imageProvider as CachedNetworkImageProvider).url;
      }

      if (this.user != tempUser) {
        Firestore.instance
            .collection(Constants().firestoreUsersCollection)
            .document(Constants().currentUserId)
            .updateData(tempUser.data);
      } else {
        this.setState(() {});
      }
    } else {
      setState(() {
        this.editMode = true;
      });
    }
  }

  void onImageUpdated(File imageFile) {
    this.setState(() {
      this.imageProvider = FileImage(imageFile);
    });
  }

  void onNameChanged(String name) {
    this.name = name;
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context).settings.arguments as Map;
    return StreamBuilder<DocumentSnapshot>(
      stream: this.documentSnapshotStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          this.user = User(data: snapshot.data.data);
          if (!this.editMode && !this.isLoading) {
            this.name = this.user.name;
            if (this.user.imageURL != null) {
              this.imageProvider =
                  CachedNetworkImageProvider(this.user.imageURL);
            } else {
              this.imageProvider =
                  AssetImage(Constants().defaultUserAvatarAssetPath);
            }
          }
        }
        return LoadingOverlay(
          isLoading: this.isLoading,
          color: Colors.transparent,
          progressIndicator: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              padding: EdgeInsets.all(10),
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TitleBar(
                UserSettings.pageTitle,
                showLeftButton: true,
                showLeftChevron: !this.editMode,
                leftButtonTitle:
                    this.editMode ? 'Cancel' : routeArgs['fromPage'],
                leftButtonOnTapFn: this.leftButtonOnTap,
                showRightButton: true,
                rightButtonTitle: this.editMode ? 'Save' : 'Edit',
                rightButtonOnTapFn: () => (this.rightButtonOnTap()),
              ),
              LargeAvatar(
                editMode: this.editMode,
                name: this.name,
                onNameChanged: this.onNameChanged,
                imageProvider: this.imageProvider,
                onImageUpdated: this.onImageUpdated,
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(bottom: 20),
                  child: !this.editMode
                      ? FlatButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushNamedAndRemoveUntil(
                                Login.routeName, (_) => false);
                          },
                          child: Text(
                            'Logout',
                            style: Theme.of(context).textTheme.button,
                          ),
                        )
                      : Container(),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
