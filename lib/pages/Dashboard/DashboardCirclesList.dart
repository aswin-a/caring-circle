import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './DashboardCirclesListItem.dart';
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
                    child: DashboardCirclesListItem(),
                  );
                },
              );
      },
    );
  }
}
