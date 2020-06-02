import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../components/SummaryCard.dart';
import '../../Models/Circle.dart';
import '../../providers/UserProvider.dart';
import '../../providers/CircleProvider.dart';
import '../../providers/UserActivitiesProvider.dart';

class CircleUsersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CircleProvider>(
      builder: (context, circleProvider, _) {
        final String adminId = circleProvider.circle.users
            .singleWhere((circleUser) => circleUser.isAdmin,
                orElse: () => CircleUser())
            .id;
        return circleProvider.circle == null
            ? Container()
            : ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 15),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (ctx, index) => SizedBox(height: 10),
                itemCount: circleProvider.circle.users.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return MultiProvider(
                    providers: [
                      ChangeNotifierProvider<UserProvider>.value(
                        value:
                            UserProvider(circleProvider.circle.users[index].id),
                      ),
                      ChangeNotifierProvider<UserActivitiesProvider>.value(
                        value: UserActivitiesProvider(
                            circleProvider.circle.users[index].id),
                      )
                    ],
                    child: Consumer2<UserProvider, UserActivitiesProvider>(
                      builder: (
                        context,
                        userProvider,
                        userActivitiesProvider,
                        _,
                      ) {
                        return SummaryCard(
                          title: userProvider.user?.name ?? '',
                          imageURL: userProvider.user?.imageURL,
                          imageAssetPath:
                              Constants().defaultUserAvatarWhiteAssetPath,
                          activitiesDuration:
                              userActivitiesProvider.activitiesDuration,
                          rightTextData:
                              userProvider.user?.id == adminId ? 'admin' : null,
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
