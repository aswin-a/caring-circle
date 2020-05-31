import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../providers/UserProvider.dart';
import '../../providers/UserActivitiesProvider.dart';
import '../../components/TitleBar.dart';
import '../../components/SubtitleBar.dart';
import '../UserSettings/UserSettings.dart';
import '../../constants.dart';
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
        child: _DashboardContent(),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserProvider>.value(
          value: UserProvider(Constants().currentUserId),
        ),
        ChangeNotifierProvider<UserActivitiesProvider>.value(
          value: UserActivitiesProvider(Constants().currentUserId),
        ),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Consumer<UserProvider>(
            builder: (context, userProvider, _) {
              ImageProvider imageProvider = userProvider.user == null
                  ? AssetImage(Constants().defaultUserAvatarBlueAssetPath)
                  : CachedNetworkImageProvider(userProvider.user.imageURL);
              return TitleBar(
                Dashboard.pageTitle,
                showAvatar: true,
                avatarImageProvider: imageProvider,
                avatarOnTapFn: () => Navigator.of(context).pushNamed(
                    UserSettings.routeName,
                    arguments: {'fromPage': 'Dashboard'}),
              );
            },
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                StickyHeader(
                  header: SubtitleBar('Outdoor Time'),
                  content: DashboardChart(),
                ),
                SizedBox(height: 10),
                StickyHeader(
                  header: SubtitleBar('Circles', showRightButton: true),
                  content: DashboardCirclesList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
