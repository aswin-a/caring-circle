import 'dart:io';

import 'package:caring_circle/providers/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../components/TitleBar.dart';
import '../../components/LargeAvatar.dart';
import '../../components/NameTextField.dart';
import './UserSettings.dart';

class UserSettingsEdit extends StatelessWidget {
  static const routeName = '/user-settings-edit';
  static const pageTitle = 'Edit User Settings';

  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: _UserSettingsEditContent(),
      ),
    );
  }
}

class _UserSettingsEditContent extends StatefulWidget {
  @override
  __UserSettingsEditContentState createState() =>
      __UserSettingsEditContentState();
}

class __UserSettingsEditContentState extends State<_UserSettingsEditContent> {
  String name;
  File uploadedImageFile;
  bool isLoading = false;

  void onSave(BuildContext context, UserProvider userProvider) async {
    if (name != null && name.length == 0) return;

    setState(() {
      this.isLoading = true;
    });

    if (name != null) {
      userProvider.user.name = name;
    }

    if (uploadedImageFile != null) {
      userProvider.user.imageURL = await (await FirebaseStorage.instance
              .ref()
              .child(
                  '${Constants().firebaseStorageUserImagesPath}/${userProvider.user.id}')
              .putFile(uploadedImageFile)
              .onComplete)
          .ref
          .getDownloadURL();
      await precacheImage(
          CachedNetworkImageProvider(userProvider.user.imageURL), context);
    }
    await userProvider.uploadData(onlyUserData: true);

    setState(() {
      this.isLoading = false;
    });

    Navigator.of(context).pop();
  }

  void onImageUpdated(File imageFile) {
    this.uploadedImageFile = imageFile;
  }

  void onNameChanged(String name) {
    this.name = name;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserProvider>.value(
      value: UserProvider(Constants().currentUserId),
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return LoadingOverlay(
            isLoading: this.isLoading,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TitleBar(
                  UserSettings.pageTitle,
                  showLeftButton: true,
                  leftButtonTitle: 'Cancel',
                  leftButtonOnTapFn: () => Navigator.of(context).pop(),
                  showRightButton: true,
                  rightButtonTitle: 'Save',
                  rightButtonOnTapFn: () => onSave(context, userProvider),
                ),
                LargeAvatarEdit(
                  imageURL: userProvider.user?.imageURL,
                  imageAssetPath:
                      Constants().defaultUserAvatarLargeBlueAssetPath,
                  onImageUpdated: onImageUpdated,
                ),
                NameTextField(
                  initialValue: userProvider.user.name,
                  onNameChanged: this.onNameChanged,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
