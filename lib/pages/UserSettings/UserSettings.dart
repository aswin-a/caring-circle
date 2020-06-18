import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/UserProvider.dart';
import '../../providers/UserActivitiesProvider.dart';
import '../../constants.dart';
import '../../components/TitleBar.dart';
import '../../components/LargeAvatar.dart';
import '../Login/Login.dart';
import '../../utils/BackgroundUtils.dart';
import './UserSettingsEdit.dart';
import './UserSettingsLocation.dart';
import '../../utils/FormattingUtils.dart' as FormattingUtils;

class UserSettings extends StatelessWidget {
  static const routeName = '/user-settings';
  static const pageTitle = 'User Settings';

  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: _UserSettingsContent(),
      ),
    );
  }
}

class _UserSettingsContent extends StatelessWidget {
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
      child: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TitleBar(
                UserSettings.pageTitle,
                showLeftButton: true,
                showLeftChevron: true,
                leftButtonTitle: (ModalRoute.of(context).settings.arguments
                    as Map)['fromPage'],
                leftButtonOnTapFn: () => Navigator.of(context).pop(),
                showRightButton: true,
                rightButtonTitle: 'Edit',
                rightButtonOnTapFn: () =>
                    Navigator.of(context).pushNamed(UserSettingsEdit.routeName),
              ),
              Center(
                child: LargeAvatar(
                  imageURL: userProvider.user?.imageURL,
                  imageAssetPath:
                      Constants().defaultUserAvatarLargeBlueAssetPath,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  userProvider.user.name,
                  style: Theme.of(context).textTheme.display3,
                  textAlign: TextAlign.center,
                ),
              ),
              Consumer<UserActivitiesProvider>(
                builder: (context, userActivitiesProvider, _) {
                  return Text(
                    FormattingUtils.getCurrentStatus(
                      userProvider.user.locationStatus,
                      userActivitiesProvider.currentActivityExitTime,
                    ),
                    style: Theme.of(context).textTheme.caption,
                  );
                },
              ),
              SizedBox(height: 10),
              UserSettingsLocation(),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(bottom: 20),
                  child: FlatButton(
                    onPressed: () async {
                      stopBackgroundTask();
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          Login.routeName, (_) => false);
                    },
                    child: Text(
                      'Logout',
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
