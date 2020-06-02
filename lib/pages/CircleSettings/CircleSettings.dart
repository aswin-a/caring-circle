import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './CircleSettingsEdit.dart';
import '../../constants.dart';
import '../../components/TitleBar.dart';
import '../../components/LargeAvatar.dart';
import '../../Models/Circle.dart';
import '../../pages/Dashboard/Dashboard.dart';
import '../../providers/CircleProvider.dart';
import '../../providers/UserProvider.dart';

class CircleSettings extends StatelessWidget {
  static const routeName = '/circle-settings';
  static const pageTitle = 'Circle Settings';

  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: _CircleSettingsContent(),
      ),
    );
  }
}

class _CircleSettingsContent extends StatelessWidget {
  void leaveCircle(BuildContext context, CircleProvider circleProvider) {
    UserProvider(Constants().currentUserId)
        .removeCircle(circleProvider.circle.id);
    circleProvider.removeUser(Constants().currentUserId);
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Dashboard.routeName, (_) => false);
  }

  void deleteCircle(BuildContext context, CircleProvider circleProvider) {
    circleProvider.circle.users.forEach((circleUser) {
      UserProvider(circleUser.id).removeCircle(circleProvider.circle.id);
    });
    circleProvider.deleteCircle();
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Dashboard.routeName, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final routeArguments = ModalRoute.of(context).settings.arguments as Map;
    final circleId = routeArguments['circleId'];
    return ChangeNotifierProvider<CircleProvider>.value(
      value: CircleProvider(circleId),
      child: Consumer<CircleProvider>(
        builder: (context, circleProvider, _) {
          final bool isAdmin = circleProvider.circle.users
              .singleWhere(
                  (circleUser) => circleUser.id == Constants().currentUserId,
                  orElse: () => CircleUser())
              .isAdmin;
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TitleBar(
                CircleSettings.pageTitle,
                showLeftButton: true,
                showLeftChevron: true,
                leftButtonTitle: routeArguments['fromPage'],
                leftButtonOnTapFn: () => Navigator.of(context).pop(),
                showRightButton: true,
                rightButtonTitle: 'Edit',
                rightButtonOnTapFn: () => Navigator.of(context).pushNamed(
                  CircleSettingsEdit.routeName,
                  arguments: {'circleId': circleProvider.circle.id},
                ),
              ),
              Center(
                child: LargeAvatar(
                  imageURL: circleProvider.circle?.imageURL,
                  imageAssetPath:
                      Constants().defaultCircleAvatarLargeBlueAssetPath,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  circleProvider.circle.name,
                  style: Theme.of(context).textTheme.display3,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(bottom: 20),
                  child: FlatButton(
                    onPressed: isAdmin
                        ? () => deleteCircle(context, circleProvider)
                        : () => leaveCircle(context, circleProvider),
                    child: Text(
                      isAdmin ? 'Delete Circle' : 'Leave Circle',
                      style: Theme.of(context).textTheme.button,
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
