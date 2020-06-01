import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Circle/Circle.dart';
import '../../constants.dart';
import '../../components/SummaryCard.dart';
import '../../providers/UserProvider.dart';
import '../../providers/CircleProvider.dart';
import '../../providers/CircleActivitiesProvider.dart';

class DashboardCirclesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return userProvider.user == null
            ? Container()
            : ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 15),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (ctx, index) => SizedBox(height: 10),
                itemCount: userProvider.user.circles.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider<CircleProvider>.value(
                        value: CircleProvider(userProvider.user.circles[index]),
                      ),
                      ChangeNotifierProvider<CircleActivitiesProvider>.value(
                        value: CircleActivitiesProvider(
                            userProvider.user.circles[index]),
                      )
                    ],
                    child: Consumer2<CircleProvider, CircleActivitiesProvider>(
                      builder: (
                        context,
                        circleProvider,
                        circleActivitiesProvider,
                        _,
                      ) {
                        return SummaryCard(
                          title: circleProvider.circle?.name ?? '',
                          imageURL: circleProvider.circle?.imageURL,
                          imageAssetPath:
                              Constants().defaultCircleAvatarWhiteAssetPath,
                          activitiesDuration:
                              circleActivitiesProvider.activitiesDuration,
                          onTap: circleProvider.circle?.id == null
                              ? null
                              : () => Navigator.pushNamed(
                                      context, Circle.routeName,
                                      arguments: {
                                        'fromPage': 'Dashboard',
                                        'circleId': circleProvider.circle.id,
                                      }),
                        );
                      },
                    ),
                  );
                },
              );
      },
    );
  }
}
