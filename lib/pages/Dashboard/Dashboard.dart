import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../components/TitleBar.dart';
import '../../components/RoundedSquareBox.dart';
import '../../components/ExpandedRoundedRectangleBox.dart';
import '../../components/SubtitleBar.dart';
import './DashboardCircleCard.dart';
import '../UserSettings/UserSettings.dart';
import '../../constants.dart';
import '../../Models/User.dart';

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
        child: _DashboardContent(pageTitle: pageTitle),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final Stream userSnapshotStream = Firestore.instance
      .collection(Constants().firestoreUsersCollection)
      .document(Constants().currentUserId)
      .snapshots();

  _DashboardContent({
    @required this.pageTitle,
  });

  final String pageTitle;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: userSnapshotStream,
        builder: (context, snapshot) {
          ImageProvider imageProvider =
              AssetImage(Constants().defaultUserAvatarAssetPath);
          if (snapshot.connectionState == ConnectionState.active) {
            final user = User(data: snapshot.data.data);
            if (user.imageURL != null) {
              imageProvider =
                  CachedNetworkImageProvider(user.imageURL);
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
        });
  }
}
