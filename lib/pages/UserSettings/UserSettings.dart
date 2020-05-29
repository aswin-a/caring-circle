import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../constants.dart';
import '../../components/TitleBar.dart';
import '../../components/LargeAvatar.dart';
import '../../components/SubtitleBar.dart';
import '../Login/Login.dart';
import '../../Models/User.dart';
import '../../components/MapDialog.dart';
import '../../components/SettingsBlock.dart';
import '../../utils/GeofencingUtils.dart';
import '../../utils/ActivityUtils.dart' as ActivityUtils;
import 'package:timeago/timeago.dart' as timeago;

class UserSettings extends StatelessWidget {
  static const routeName = '/user-settings';
  static const pageTitle = 'User Settings';

  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
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
      AssetImage(Constants().defaultUserAvatarLargeBlueAssetPath);

  Stream<DocumentSnapshot> documentSnapshotStream;
  User user;

  LatLng tempLocation;

  final currentActivityStream = ActivityUtils.getCurrentActivityStream();
  UserActivity currentActivity;
  String subtext;
  Timer refreshTimer;

  @override
  void initState() {
    documentSnapshotStream = Firestore.instance
        .collection(Constants().firestoreUsersCollection)
        .document(Constants().currentUserId)
        .snapshots();
    super.initState();
  }

  @override
  void dispose() {
    this.refreshTimer?.cancel();
    super.dispose();
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
      if (this.name.length == 0) return;

      this.editMode = false;

      String imageURL;

      if (this.imageProvider is FileImage) {
        this.setState(() {
          this.isLoading = true;
        });
        imageURL = await (await FirebaseStorage.instance
                .ref()
                .child(
                    '${Constants().firebaseStorageUserImagesPath}/${Constants().currentUserId}')
                .putFile((this.imageProvider as FileImage).file)
                .onComplete)
            .ref
            .getDownloadURL();
        this.isLoading = false;
      } else if (this.imageProvider is CachedNetworkImageProvider) {
        imageURL = (this.imageProvider as CachedNetworkImageProvider).url;
      }

      if (this.user.name != this.name || this.user.imageURL != imageURL) {
        this.user.name = this.name;
        this.user.imageURL = imageURL;
        Firestore.instance
            .collection(Constants().firestoreUsersCollection)
            .document(Constants().currentUserId)
            .updateData(this.user.userData);
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

  void updateTempLocation(LatLng location) {
    this.tempLocation = location;
  }

  void getHomeLocation() {
    void updateHomeLocation() async {
      this.user.location.setHomeLocation(
          this.tempLocation.latitude, this.tempLocation.longitude);
      Firestore.instance
          .collection(Constants().firestoreUsersCollection)
          .document(Constants().currentUserId)
          .updateData(this.user.locationData);

      await removeHomeGeofence();
      initialiseHomeGeofence(
          this.user.location.home.latitude, this.user.location.home.longitude);
    }

    LatLng startLocation;
    if (this.isHomeLocationSet) {
      startLocation = LatLng(
          this.user.location.home.latitude, this.user.location.home.longitude);
    }
    showMapDialog(
      context,
      'Home Location',
      updateHomeLocation,
      this.updateTempLocation,
      startLocation,
    );
  }

  void getOfficeLocation() {
    void updateOfficeLocation() async {
      this.user.location.setOfficeLocation(
          this.tempLocation.latitude, this.tempLocation.longitude);
      Firestore.instance
          .collection(Constants().firestoreUsersCollection)
          .document(Constants().currentUserId)
          .updateData(this.user.locationData);

      await removeOfficeGeofence();
      initialiseOfficeGeofence(this.user.location.office.latitude,
          this.user.location.office.longitude);
    }

    LatLng startLocation;
    if (this.isOfficeLocationSet) {
      startLocation = LatLng(this.user.location.office.latitude,
          this.user.location.office.longitude);
    }
    showMapDialog(
      context,
      'Office Location',
      updateOfficeLocation,
      this.updateTempLocation,
      startLocation,
    );
  }

  bool get isHomeLocationSet => this.user?.location?.home != null;
  bool get isOfficeLocationSet => this.user?.location?.office != null;

  updateSubtext() {
    switch (this.user.locationStatus) {
      case LocationStatus.home:
        this.subtext = 'In Home';
        break;
      case LocationStatus.office:
        this.subtext = 'In Office';
        break;
      case LocationStatus.outside:
        if (this.currentActivity != null) {
          final durationText =
              timeago.format(this.currentActivity.exit.toDate());
          this.subtext =
              'Been outdoors for ${durationText.substring(0, durationText.length - 4)}';
        }
        break;
      default:
        this.subtext = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context).settings.arguments as Map;
    return WillPopScope(
      onWillPop: () async {
        if (this.editMode) {
          this.leftButtonOnTap();
          return false;
        } else {
          return true;
        }
      },
      child: StreamBuilder<QuerySnapshot>(
        stream: this.currentActivityStream,
        builder: (context, currentActivitySnapshot) {
          return StreamBuilder<DocumentSnapshot>(
            stream: this.documentSnapshotStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active &&
                  currentActivitySnapshot.connectionState ==
                      ConnectionState.active) {
                this.user = User(data: snapshot.data.data);
                if (!this.editMode && !this.isLoading) {
                  this.name = this.user.name;
                  if (this.user.imageURL != null) {
                    this.imageProvider =
                        CachedNetworkImageProvider(this.user.imageURL);
                  } else {
                    this.imageProvider = AssetImage(
                        Constants().defaultUserAvatarLargeBlueAssetPath);
                  }
                }
                if (currentActivitySnapshot.data.documents.length == 1) {
                  this.currentActivity = UserActivity(
                      data: currentActivitySnapshot.data.documents.first.data);
                  this.refreshTimer?.cancel();
                  this.refreshTimer = Timer.periodic(Duration(minutes: 1),
                      (Timer t) => mounted ? this.setState(() {}) : null);
                } else {
                  this.currentActivity = null;
                  this.refreshTimer?.cancel();
                }
                this.updateSubtext();
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
                      subtext: this.subtext,
                    ),
                    !this.editMode
                        ? Column(
                            children: <Widget>[
                              SubtitleBar('Location'),
                              SettingsBlock(
                                'Home',
                                showRightChevron: true,
                                leftIcon: Icons.home,
                                onTap: () => this.getHomeLocation(),
                                rightTextData:
                                    !this.isHomeLocationSet ? 'unset' : null,
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
                          )
                        : Container(),
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(bottom: 20),
                        child: !this.editMode
                            ? FlatButton(
                                onPressed: () async {
                                  await FirebaseAuth.instance.signOut();
                                  removeHomeGeofence();
                                  removeOfficeGeofence();
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
        },
      ),
    );
  }
}
