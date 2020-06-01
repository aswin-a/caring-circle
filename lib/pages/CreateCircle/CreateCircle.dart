import 'dart:io';

import 'package:caring_circle/Models/Circle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';

import '../Circle/Circle.dart' as CirclePage;
import '../../constants.dart';
import '../../components/TitleBar.dart';
import '../../components/LargeAvatar.dart';
import '../../components/NameTextField.dart';
import '../../providers/CircleProvider.dart';
import '../../providers/UserProvider.dart';

class CreateCircle extends StatelessWidget {
  static const routeName = '/create-circle';
  static const pageTitle = 'Create New Circle';

  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: _CreateCircleContent(),
      ),
    );
  }
}

class _CreateCircleContent extends StatefulWidget {
  @override
  _CreateCircleContentState createState() => _CreateCircleContentState();
}

class _CreateCircleContentState extends State<_CreateCircleContent> {
  String name;
  File uploadedImageFile;
  bool isLoading = false;

  String newCircleId;

  @override
  void initState() {
    Firestore.instance
        .collection(Constants().firestoreCirclesCollection)
        .add(Circle().data)
        .then((circleDocumentReference) {
      circleDocumentReference
          .updateData({'id': circleDocumentReference.documentID});
      this.setState(() {
        this.newCircleId = circleDocumentReference.documentID;
      });
    });
    super.initState();
  }

  void onCreate(BuildContext context, CircleProvider circleProvider) async {
    if (name?.length == 0) return;

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

    await UserProvider(Constants().currentUserId)
        .addCircle(circleProvider.circle.id);

    circleProvider.circle.users.add(
        CircleUser(data: {'id': Constants().currentUserId, 'admin': true}));
    await circleProvider.uploadData();

    setState(() {
      this.isLoading = false;
    });

    Navigator.pushReplacementNamed(
      context,
      CirclePage.Circle.routeName,
      arguments: {
        'fromPage': 'Dashboard',
        'circleId': circleProvider.circle.id,
      },
    );
  }

  void onCancel(CircleProvider circleProvider) async {
    await circleProvider.deleteCircle();
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
    return ChangeNotifierProvider<CircleProvider>.value(
      value: CircleProvider(this.newCircleId),
      child: Consumer<CircleProvider>(
        builder: (context, circleProvider, _) {
          return WillPopScope(
            onWillPop: () async {
              await circleProvider.deleteCircle();
              return true;
            },
            child: LoadingOverlay(
              isLoading: this.isLoading,
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TitleBar(
                    'Create New Circle',
                    showLeftButton: true,
                    leftButtonTitle: 'Cancel',
                    leftButtonOnTapFn: () => onCancel(circleProvider),
                    showRightButton: true,
                    rightButtonTitle: 'Create',
                    rightButtonOnTapFn: () => onCreate(context, circleProvider),
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
            ),
          );
        },
      ),
    );
  }
}
