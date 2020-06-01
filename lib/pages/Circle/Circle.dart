import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

import './CricleUsersList.dart';
import '../../constants.dart';
import '../../components/TitleBar.dart';
import '../../components/SubtitleBar.dart';
import '../../components/OutdoorTimeChart.dart';
import '../../providers/CircleProvider.dart';
import '../../providers/CircleActivitiesProvider.dart';
import '../../providers/BaseActivitiesProvider.dart';

class Circle extends StatelessWidget {
  static const routeName = '/circle';
  static const pageTitle = 'Circle';

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: _CircleContent(),
      ),
    );
  }
}

class _CircleContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final routeArguments = ModalRoute.of(context).settings.arguments as Map;
    final circleId = routeArguments['circleId'];
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CircleProvider>.value(
          value: CircleProvider(circleId),
        ),
        ChangeNotifierProvider<BaseActivitiesProvider>.value(
          value: CircleActivitiesProvider(circleId),
        ),
      ],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Consumer<CircleProvider>(
            builder: (context, circleProvider, _) {
              ImageProvider imageProvider = circleProvider.circle?.imageURL == null
                  ? AssetImage(Constants().defaultCircleAvatarBlueAssetPath)
                  : CachedNetworkImageProvider(circleProvider.circle.imageURL);
              return TitleBar(
                circleProvider.circle?.name ?? '',
                showAvatar: true,
                avatarImageProvider: imageProvider,
                showLeftButton: true,
                showLeftChevron: true,
                leftButtonTitle: routeArguments['fromPage'],
                leftButtonOnTapFn: () => Navigator.of(context).pop(),
                // TODO: Circle Settings
                // avatarOnTapFn: () => Navigator.of(context).pushNamed(
                //     UserSettings.routeName,
                //     arguments: {'fromPage': 'Dashboard'}),
              );
            },
          ),
          Expanded(
            child: ListView(
              children: <Widget>[
                StickyHeader(
                  header: SubtitleBar('Outdoor Time'),
                  content: OutdoorTimeChart(),
                ),
                SizedBox(height: 10),
                StickyHeader(
                  header: SubtitleBar('People'),
                  content: CircleUsersList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
