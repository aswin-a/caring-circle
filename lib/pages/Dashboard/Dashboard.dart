import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geofencing/geofencing.dart';

import '../../components/TitleBar.dart';
import '../../components/RoundedSquareBox.dart';
import '../../components/ExpandedRoundedRectangleBox.dart';
import '../../components/SubtitleBar.dart';
import './DashboardCircleCard.dart';
import '../UserSettings/UserSettings.dart';
import '../../constants.dart';
import '../../Models/User.dart';
import './GeofencingUtils.dart';

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
  var message = 'Nothing';

  @override
  void initState() {
    super.initState();
    initialiseGeofenceManager();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: userSnapshotStream,
      builder: (context, snapshot) {
        ImageProvider imageProvider =
            AssetImage(Constants().defaultUserAvatarAssetPath);
        if (snapshot.connectionState == ConnectionState.active) {
          this.user = User(data: snapshot.data.data);
          if (this.user.imageURL != null) {
            imageProvider = CachedNetworkImageProvider(this.user.imageURL);
          }
          if (this.user.location.home != null) {
            final homeLocation = this.user.location.home;
            initialiseHomeGeofence(homeLocation.latitude, homeLocation.longitude);
          }
          if (this.user.location.office != null) {
            final officeLocation = this.user.location.office;
            initialiseOfficeGeofence(officeLocation.latitude, officeLocation.longitude);
          }
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
            Column(
              children: <Widget>[
                Text(this.message),
                RaisedButton(
                  onPressed: () {
                    removeHomeGeofence();
                    removeOfficeGeofence();
                  },
                  child: Text('Remove Geofences'),
                ),
                RaisedButton(
                  onPressed: () async {
                    final list =
                        await GeofencingManager.getRegisteredGeofenceIds();
                    this.setState(() {
                      this.message = 'IDs: $list';
                    });
                    print(this.message);
                  },
                  child: Text('List IDs'),
                ),
              ],
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RoundedSquareBox('Score', '123', '2 days steady'),
                      SizedBox(width: 10),
                      ExpandedRoundedRectangleBox('Today', '1hr 15mins'),
                      SizedBox(width: 10),
                      RoundedSquareBox('COVID-19', '1203', 'Gurgaon'),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      ExpandedRoundedRectangleBox('Today', '1hr 15mins'),
                    ],
                  ),
                  SizedBox(height: 10),
                  StickyHeader(
                    // overlapHeaders: true,
                    header: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: SubtitleBar('Circles', showRightButton: true),
                    ),
                    content: Column(
                      children: List.generate(15, (idx) {
                        return idx % 2 == 0
                            ? DashboardCircleCard()
                            : SizedBox(height: 10);
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
