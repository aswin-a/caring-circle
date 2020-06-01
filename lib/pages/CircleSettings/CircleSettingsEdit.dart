import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import './CircleSettings.dart';
import '../../constants.dart';
import '../../components/TitleBar.dart';
import '../../components/LargeAvatar.dart';
import '../../components/NameTextField.dart';
import '../../providers/CircleProvider.dart';

class CircleSettingsEdit extends StatelessWidget {
  static const routeName = '/circle-settings-edit';
  static const pageTitle = 'Edit Circle Settings';

  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: _CircleSettingsEditContent(),
      ),
    );
  }
}

class _CircleSettingsEditContent extends StatefulWidget {
  @override
  _CircleSettingsEditContentState createState() =>
      _CircleSettingsEditContentState();
}

class _CircleSettingsEditContentState
    extends State<_CircleSettingsEditContent> {
  String name;
  File uploadedImageFile;
  bool isLoading = false;

  void onSave(BuildContext context, CircleProvider circleProvider) async {
    if (name != null && name.length == 0) return;

    setState(() {
      this.isLoading = true;
    });

    if (name != null) {
      circleProvider.circle.name = name;
    }

    if (uploadedImageFile != null) {
      circleProvider.circle.imageURL = await (await FirebaseStorage.instance
              .ref()
              .child(
                  '${Constants().firebaseStorageCircleImagesPath}/${circleProvider.circle.id}')
              .putFile(uploadedImageFile)
              .onComplete)
          .ref
          .getDownloadURL();
      await precacheImage(
          CachedNetworkImageProvider(circleProvider.circle.imageURL), context);
    }
    await circleProvider.uploadData(onlyCircleData: true);

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
    final routeArguments = ModalRoute.of(context).settings.arguments as Map;
    final circleId = routeArguments['circleId'];
    return ChangeNotifierProvider<CircleProvider>.value(
      value: CircleProvider(circleId),
      child: Consumer<CircleProvider>(
        builder: (context, circleProvider, _) {
          return LoadingOverlay(
            isLoading: this.isLoading,
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                TitleBar(
                  CircleSettings.pageTitle,
                  showLeftButton: true,
                  leftButtonTitle: 'Cancel',
                  leftButtonOnTapFn: () => Navigator.of(context).pop(),
                  showRightButton: true,
                  rightButtonTitle: 'Save',
                  rightButtonOnTapFn: () => onSave(context, circleProvider),
                ),
                LargeAvatarEdit(
                  imageURL: circleProvider.circle?.imageURL,
                  imageAssetPath:
                      Constants().defaultCircleAvatarLargeBlueAssetPath,
                  onImageUpdated: onImageUpdated,
                ),
                NameTextField(
                  initialValue: circleProvider.circle?.name ?? '',
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
