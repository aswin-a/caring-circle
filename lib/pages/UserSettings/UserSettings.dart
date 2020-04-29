import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
          String userName;
          if (snapshot.connectionState == ConnectionState.active) {
            final documentSnapshot = snapshot.data as DocumentSnapshot;
            userName = documentSnapshot.data['name'];
          }
          return _UserSettingsContent(routeArgs: routeArgs, userName: userName);
        });
  }
}

class _UserSettingsContent extends StatefulWidget {
  final routeArgs;
  final String userName;

  _UserSettingsContent({@required this.routeArgs, @required this.userName});

  @override
  _UserSettingsContentState createState() => _UserSettingsContentState();
}

class _UserSettingsContentState extends State<_UserSettingsContent> {
  var editMode = false;
  String name;
  final nameController = TextEditingController(text: '');
  ImageProvider imageProvider =
      AssetImage('assets/images/defaultAvatarLarge.png');

  
  @override
  void didUpdateWidget(_UserSettingsContent oldWidget) {
    this.nameController.text = widget.userName;
    super.didUpdateWidget(oldWidget);
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

  void rightButtonOnTap() {
    if (this.editMode) {
      setState(() {
        this.editMode = false;
      });

      Firestore.instance
          .collection('users')
          .document(Constants().currentUserId)
          .updateData({'name': this.nameController.text});
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

  void onNameChanged (String name) {
    print('Changed: $name');
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
          nameController: this.nameController,
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
