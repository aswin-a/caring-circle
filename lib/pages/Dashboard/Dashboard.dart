import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../components/TitleBar.dart';
import '../../components/RoundedSquareBox.dart';
import '../../components/ExpandedRoundedRectangleBox.dart';
import '../../components/SubtitleBar.dart';
import './DashboardCircleCard.dart';
import '../UserSettings/UserSettings.dart';
import '../../providers/User.dart';

class Dashboard extends StatelessWidget {
  static const routeName = '/';
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
  const _DashboardContent({
    @required this.pageTitle,
  });

  final String pageTitle;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TitleBar(
          Dashboard.pageTitle,
          showAvatar: true,
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
                  RoundedSquareBox(
                      'Score', user.score.toString(), '${user.streak} days steady'),
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
  }
}
