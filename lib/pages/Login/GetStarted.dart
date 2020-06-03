import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../Permission/Permission.dart';
import '../../constants.dart';
import '../../components/LargeAvatar.dart';
import '../../components/MapDialog.dart';
import '../../components/NameTextField.dart';
import '../../components/SubtitleBar.dart';
import '../../components/SettingsBlock.dart';
import '../../Models/Circle.dart';
import '../../Models/User.dart';
import '../../providers/CircleProvider.dart';

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
      AssetImage(Constants().defaultUserAvatarLargeBlueAssetPath);

  LatLng homeLocation;
  LatLng officeLocation;
  LatLng tempLocation;

  validate() {
    bool isValid = false;
    if (this.name != null && this.name.length > 0 && this.isHomeLocationSet) {
      isValid = true;
    }

    if (!isValid && this.isValid) {
      this.setState(() {
        this.isValid = false;
      });
    } else if (isValid && !this.isValid) {
      this.setState(() {
        this.isValid = true;
      });
    }

    return isValid;
  }

  void onTapContinue(BuildContext context) async {
    if (!this.validate()) {
      return;
    }

    this.setState(() {
      this.isLoading = true;
    });

    final user = User();
    user.name = this.name;

    if (this.imageProvider is FileImage) {
      user.imageURL = await (await FirebaseStorage.instance
              .ref()
              .child(
                  '${Constants().firebaseStorageUserImagesPath}/${Constants().currentUserId}')
              .putFile((this.imageProvider as FileImage).file)
              .onComplete)
          .ref
          .getDownloadURL();
    }

    if (this.homeLocation != null) {
      user.location.setHomeLocation(
          this.homeLocation.latitude, this.homeLocation.longitude);
    }
    if (this.officeLocation != null) {
      user.location.setOfficeLocation(
          this.officeLocation.latitude, this.officeLocation.longitude);
    }

    final firebaseUser = await FirebaseAuth.instance.currentUser();
    final newUserData = user.data;
    newUserData.addEntries([
      MapEntry('id', firebaseUser.uid),
      MapEntry('phone', firebaseUser.phoneNumber),
    ]);

    final List<DocumentSnapshot> unAuthUserDocumentSnapshotList =
        (await Firestore.instance
                .collection(Constants().firestoreUnAuthenticatedUsersCollection)
                .where(Constants().firestoreUnAuthenticatedUserPhoneField,
                    isEqualTo: firebaseUser.phoneNumber)
                .getDocuments())
            .documents;
    if (unAuthUserDocumentSnapshotList.length == 1) {
      final unAuthUserCirclesList = unAuthUserDocumentSnapshotList.first
          .data[Constants().firestoreUnAuthenticatedUserCriclesField] as List;
      final List<String> newUserCirclesList = [];

      unAuthUserCirclesList.forEach(
        (circleId) {
          newUserCirclesList.add(circleId);

          final circleProvider = CircleProvider(circleId);
          Timer.periodic(Duration(milliseconds: 50), (t) async {
            if (circleProvider.circle != null) {
              t.cancel();
              await circleProvider.removeUnAuthUser(firebaseUser.phoneNumber);
              await circleProvider.addUser(
                  CircleUser(data: {'id': firebaseUser.uid, 'admin': false}));
            }
          });
        },
      );

      newUserData.addEntries([
        MapEntry('circles', newUserCirclesList),
      ]);

      await unAuthUserDocumentSnapshotList.first.reference.delete();
    }

    await Firestore.instance
        .collection(Constants().firestoreUsersCollection)
        .document(firebaseUser.uid)
        .setData(newUserData);

    Navigator.of(context).pushNamedAndRemoveUntil(
        Permission.routeName, (Route<dynamic> route) => false);
  }

  void onNameChanged(String name) {
    this.name = name;
    this.validate();
  }

  void onImageUpdated(File imageFile) {
    this.setState(() {
      this.imageProvider = FileImage(imageFile);
    });
  }

  void updateTempLocation(LatLng location) {
    this.tempLocation = location;
  }

  void getHomeLocation() {
    void updateHomeLocation() {
      this.homeLocation = this.tempLocation;
      this.validate();
    }

    showMapDialog(
      context,
      'Home Location',
      updateHomeLocation,
      this.updateTempLocation,
      homeLocation,
    );
  }

  void getOfficeLocation() {
    void updateOfficeLocation() {
      this.officeLocation = this.tempLocation;
      this.validate();
    }

    showMapDialog(
      context,
      'Office Location',
      updateOfficeLocation,
      this.updateTempLocation,
      officeLocation,
    );
  }

  bool get isHomeLocationSet => this.homeLocation != null;
  bool get isOfficeLocationSet => this.officeLocation != null;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 44),
                        Text('Let\'s get started.',
                            style: Theme.of(context).textTheme.display4),
                        SizedBox(height: 10),
                        Center(
                          child: LargeAvatarEdit(
                            imageAssetPath:
                                Constants().defaultUserAvatarLargeBlueAssetPath,
                            onImageUpdated: this.onImageUpdated,
                            imageFile: (this.imageProvider is FileImage)
                                ? (this.imageProvider as FileImage).file
                                : null,
                          ),
                        ),
                        Center(
                          child: NameTextField(
                            onNameChanged: this.onNameChanged,
                          ),
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      SubtitleBar('Location'),
                      SettingsBlock(
                        'Home*',
                        showRightChevron: true,
                        leftIcon: Icons.home,
                        onTap: () => this.getHomeLocation(),
                        rightTextData: !this.isHomeLocationSet ? 'unset' : null,
                      ),
                      SizedBox(height: 10),
                      SettingsBlock(
                        'Office',
                        showRightChevron: true,
                        leftIcon: Icons.business_center,
                        onTap: () => this.getOfficeLocation(),
                        rightTextData:
                            !this.isOfficeLocationSet ? 'unset' : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.symmetric(vertical: this.isLoading ? 20 : 5),
            child: this.isLoading
                ? CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  )
                : FlatButton(
                    onPressed:
                        this.isValid ? () => this.onTapContinue(context) : null,
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
        ],
      ),
    );
  }
}
