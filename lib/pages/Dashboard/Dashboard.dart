import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../components/TitleBar.dart';
import '../../components/SubtitleBar.dart';
import '../UserSettings/UserSettings.dart';
import '../../constants.dart';
import '../../Models/User.dart';
import '../../utils/GeofencingUtils.dart';
import './DashboardChart.dart';
import './DashboardCirclesList.dart';

class Dashboard extends StatelessWidget {
  static const routeName = '/dashboard';
  static const pageTitle = 'Dashboard';

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        minimum: EdgeInsets.symmetric(horizontal: 15),
        child: _DashboardContent(),
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  @override
  __DashboardContentState createState() => __DashboardContentState();
}

class __DashboardContentState extends State<_DashboardContent> {
  final Stream userSnapshotStream = Firestore.instance
      .collection(Constants().firestoreUsersCollection)
      .document(Constants().currentUserId)
      .snapshots();

  User user;
  bool geofenceInitialised = false;

  @override
  void initState() {
    super.initState();
    initialiseGeofenceManager();
  }

  void initialiseGeofences() {
    if (geofenceInitialised) return;
    checkLocationPermission().then((granted) {
      if (granted) {
        if (this.user.location.home != null) {
          final homeLocation = this.user.location.home;
          initialiseHomeGeofence(homeLocation.latitude, homeLocation.longitude);
        }
        if (this.user.location.office != null) {
          final officeLocation = this.user.location.office;
          initialiseOfficeGeofence(
              officeLocation.latitude, officeLocation.longitude);
        }
        this.geofenceInitialised = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: userSnapshotStream,
      builder: (context, snapshot) {
        ImageProvider imageProvider =
            AssetImage(Constants().defaultUserAvatarBlueAssetPath);
        if (snapshot.connectionState == ConnectionState.active) {
          this.user = User(data: snapshot.data.data);
          if (this.user.imageURL != null) {
            imageProvider = CachedNetworkImageProvider(this.user.imageURL);
          }
          this.initialiseGeofences();
        }
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TitleBar(
              Dashboard.pageTitle,
              showAvatar: true,
              avatarImageProvider: imageProvider,
              avatarOnTapFn: () => Navigator.of(context).pushNamed(
                  UserSettings.routeName,
                  arguments: {'fromPage': 'Dashboard'}),
            ),
            SizedBox(height: 10),
            SubtitleBar('Outdoor Time'),
            DashboardChart(),
            SizedBox(height: 10),
            SubtitleBar('Circles', showRightButton: true),
            this.user != null
                ? Expanded(child: DashboardCirclesList(user: this.user))
                : Container(),
          ],
        );
      },
    );
  }
}
