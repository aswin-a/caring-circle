import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:international_phone_input/international_phone_input.dart';

import './CircleSettingsEdit.dart';
import './CircleSettingsUsersList.dart';
import '../../constants.dart';
import '../../components/Alert.dart';
import '../../components/SubtitleBar.dart';
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

  Future<void> addUser(CircleProvider circleProvider) async {
    final PhoneContact contact = await FlutterContactPicker.pickPhoneContact();
    final phoneNumber = await PhoneService.getNormalizedPhoneNumber(
        contact.phoneNumber.number, 'IN');
    final List<DocumentSnapshot> userDocumentSnapshotList = (await Firestore
            .instance
            .collection(Constants().firestoreUsersCollection)
            .where(Constants().firestoreUserPhoneField, isEqualTo: phoneNumber)
            .getDocuments())
        .documents;

    if (userDocumentSnapshotList.length == 1) {
      final userId = userDocumentSnapshotList.first.data['id'];
      if (!circleProvider.circle.users.any((element) => element.id == userId)) {
        final userProvider = UserProvider(userId);
        Timer.periodic(Duration(milliseconds: 50), (t) {
          if (userProvider.user != null) {
            t.cancel();
            userProvider.addCircle(circleProvider.circle.id);
          }
        });
        circleProvider
            .addUser(CircleUser(data: {'id': userId, 'admin': false}));
      }
    } else {
      final List<DocumentSnapshot> unAuthUserDocumentSnapshotList =
          (await Firestore.instance
                  .collection(
                      Constants().firestoreUnAuthenticatedUsersCollection)
                  .where(Constants().firestoreUnAuthenticatedUserPhoneField,
                      isEqualTo: phoneNumber)
                  .getDocuments())
              .documents;

      if (unAuthUserDocumentSnapshotList.length == 1) {
        final unAuthUserCirclesList = unAuthUserDocumentSnapshotList.first
            .data[Constants().firestoreUnAuthenticatedUserCriclesField] as List;
        if (!unAuthUserCirclesList
            .any((element) => element == circleProvider.circle.id)) {
          final List<String> unAuthUserUpdatedCirclesList = [];
          unAuthUserCirclesList.forEach(
              (circleId) => unAuthUserUpdatedCirclesList.add(circleId));
          unAuthUserUpdatedCirclesList.add(circleProvider.circle.id);
          unAuthUserDocumentSnapshotList.first.reference.updateData({
            Constants().firestoreUnAuthenticatedUserCriclesField:
                unAuthUserUpdatedCirclesList
          });
        }
      } else {
        await Firestore.instance
            .collection(Constants().firestoreUnAuthenticatedUsersCollection)
            .add({
          Constants().firestoreUnAuthenticatedUserPhoneField: phoneNumber,
          Constants().firestoreUnAuthenticatedUserCriclesField: [
            circleProvider.circle.id
          ],
        });
      }

      if (!circleProvider.circle.unAuthUsers
          .any((element) => element.phone == phoneNumber)) {
        circleProvider.addUnAuthUser(CircleUnAuthUser(
            data: {'phone': phoneNumber, 'name': contact.fullName}));
      }
    }
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
              Expanded(
                child: ListView(
                  children: <Widget>[
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
                        style: Theme.of(context).textTheme.headline6,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 10),
                    isAdmin
                        ? StickyHeader(
                            header: SubtitleBar(
                              'People',
                              showRightButton: true,
                              onTap: () => addUser(circleProvider),
                            ),
                            content: CircleSettingsUsersList(),
                          )
                        : Container(),
                    SizedBox(height: 20),
                    isAdmin
                        ? CircleSettingBottomAction(
                            title: 'Delete Circle',
                            onPressed: () =>
                                deleteCircle(context, circleProvider),
                            danger: true,
                          )
                        : Container(),
                  ],
                ),
              ),
              isAdmin
                  ? Container()
                  : CircleSettingBottomAction(
                      title: 'Leave Circle',
                      onPressed: () => leaveCircle(context, circleProvider),
                    )
            ],
          );
        },
      ),
    );
  }
}

class CircleSettingBottomAction extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  final bool danger;
  const CircleSettingBottomAction(
      {this.title, this.onPressed, this.danger = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.only(bottom: 20),
      child: FlatButton(
        onPressed: () {
          showAlert(
            context,
            'Are you sure?',
            'Confirm',
            onPressedButton: onPressed,
            showCloseButton: true,
          );
        },
        child: Text(
          title,
          style: this.danger
              ? Theme.of(context).textTheme.button.copyWith(color: Colors.red)
              : Theme.of(context).textTheme.button,
        ),
      ),
    );
  }
}
