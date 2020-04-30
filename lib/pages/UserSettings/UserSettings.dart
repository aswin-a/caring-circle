import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants.dart';
import '../../styles/TextStyles.dart' as TextStyles;
import '../../components/TitleBar.dart';
import '../../components/LargeAvatar.dart';

class UserSettings extends StatelessWidget {
  static const routeName = '/user-settings';
  static const pageTitle = 'User Settings';

  Widget build(BuildContext context) {
    print('User Settings rebuilt');
    final routeArgs = ModalRoute.of(context).settings.arguments as Map;
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 15),
        child: _UserSettingsStreamContent(routeArgs: routeArgs),
      ),
    );
  }
}

class _UserSettingsStreamContent extends StatelessWidget {
  final routeArgs;

  _UserSettingsStreamContent({@required this.routeArgs});

  @override
  Widget build(BuildContext context) {
    print('User Settings Stream rebuilt');
    return StreamBuilder<Object>(
        stream: Firestore.instance
            .collection('users')
            .document(Constants().currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          Map userData;
          if (snapshot.connectionState == ConnectionState.active) {
            final documentSnapshot = snapshot.data as DocumentSnapshot;
            userData = documentSnapshot.data;
          }
          return _UserSettingsContent(routeArgs: routeArgs, userData: userData);
        });
  }
}

class _UserSettingsContent extends StatefulWidget {
  final routeArgs;
  final Map userData;

  _UserSettingsContent({@required this.routeArgs, @required this.userData});

  @override
  _UserSettingsContentState createState() => _UserSettingsContentState();
}

class _UserSettingsContentState extends State<_UserSettingsContent> {
  var editMode = false;
  String name;
  ImageProvider imageProvider =
      AssetImage('assets/images/defaultAvatarLarge.png');

  @override
  void didUpdateWidget(_UserSettingsContent oldWidget) {
    // TODO: Understand the complete working
    print('didUpdateWidget');

    if (widget.userData != null) {
      if (widget.userData.containsKey('name')) {
        this.name = widget.userData['name'];
      }

      if (widget.userData.containsKey('imageURL') &&
          widget.userData['imageURL'] != null) {
        this.imageProvider =
            CachedNetworkImageProvider(widget.userData['imageURL']);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  void leftButtonOnTap() {
    if (this.editMode) {
      setState(() {
        this.editMode = false;
        this.name = widget.userData['name'];
        if (widget.userData.containsKey('imageURL') &&
            widget.userData['imageURL'] != null) {
          this.imageProvider =
              CachedNetworkImageProvider(widget.userData['imageURL']);
        }
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void rightButtonOnTap() async {
    if (this.editMode) {
      setState(() {
        this.editMode = false;
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
      } else if (this.imageProvider is CachedNetworkImageProvider) {
        imageURL = (this.imageProvider as CachedNetworkImageProvider).url;
      }

      Firestore.instance
          .collection('users')
          .document(Constants().currentUserId)
          .updateData({'name': this.name, 'imageURL': imageURL});

      if(imageURL != null) {
        this.imageProvider = CachedNetworkImageProvider(imageURL);
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
    print('Name: $name');
    this.name = name;
  }

  @override
  Widget build(BuildContext context) {
    print('User Settings Content rebuilt');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TitleBar(
          UserSettings.pageTitle,
          showLeftButton: true,
          showLeftChevron: !this.editMode,
          leftButtonTitle:
              this.editMode ? 'Cancel' : widget.routeArgs['fromPage'],
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
                    onPressed: () {},
                    child: Text(
                      'Logout',
                      style: TextStyles.flatButtonStyle,
                    ),
                  )
                : Container(),
          ),
        )
      ],
    );
  }
}
