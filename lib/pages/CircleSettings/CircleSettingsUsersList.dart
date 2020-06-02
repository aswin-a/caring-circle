import 'package:caring_circle/components/CCFlatButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../constants.dart';
import '../../Models/Circle.dart';
import '../../providers/UserProvider.dart';
import '../../providers/CircleProvider.dart';
import '../../styles/textStyles.dart' as TextStyles;

class CircleSettingsUsersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<CircleProvider>(
      builder: (context, circleProvider, _) {
        final String adminId = circleProvider.circle.users
            .singleWhere((circleUser) => circleUser.isAdmin,
                orElse: () => CircleUser())
            .id;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: Column(
            children: <Widget>[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (ctx, index) => Divider(
                  height: 1,
                  thickness: 1,
                ),
                itemCount: circleProvider.circle.users.length,
                itemBuilder: (BuildContext ctx, int index) {
                  return ChangeNotifierProvider<UserProvider>.value(
                    value: UserProvider(circleProvider.circle.users[index].id),
                    child: Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        return UserListBlock(
                          adminId: adminId,
                          imageURL: userProvider.user.imageURL,
                          name: userProvider.user.name,
                          phoneNumber: userProvider.user.phoneNumber,
                          userId: userProvider.user.id,
                          circleId: circleProvider.circle.id,
                        );
                      },
                    ),
                  );
                },
              ),
              Divider(
                height: 1,
                thickness: 1,
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (ctx, index) => Divider(
                  height: 1,
                  thickness: 1,
                ),
                itemCount: circleProvider.circle.unAuthUsers.length,
                itemBuilder: (BuildContext ctx, int index) {
                  final unAuthUser = circleProvider.circle.unAuthUsers[index];
                  return UserListBlock(
                    adminId: adminId,
                    name: unAuthUser.name,
                    phoneNumber: unAuthUser.phone,
                    circleId: circleProvider.circle.id,
                    isUnAuthUser: true,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class UserListBlock extends StatelessWidget {
  final String adminId;
  final String imageURL;
  final String name;
  final String phoneNumber;
  final String userId;
  final String circleId;
  final bool isUnAuthUser;

  const UserListBlock({
    this.adminId,
    this.imageURL,
    this.name,
    this.phoneNumber,
    this.userId,
    this.circleId,
    this.isUnAuthUser = false,
  });

  removeUnAuthUser(String circleId) async {
    CircleProvider(circleId).removeUnAuthUser(phoneNumber);

    final List<DocumentSnapshot> unAuthUserDocumentSnapshotList =
        (await Firestore.instance
                .collection(Constants().firestoreUnAuthenticatedUsersCollection)
                .where(Constants().firestoreUnAuthenticatedUserPhoneField,
                    isEqualTo: phoneNumber)
                .getDocuments())
            .documents;

    if (unAuthUserDocumentSnapshotList.length == 1) {
      final unAuthUserCirclesList = unAuthUserDocumentSnapshotList.first
          .data[Constants().firestoreUnAuthenticatedUserCriclesField] as List;
      final List<String> unAuthUserUpdatedCirclesList = [];
      unAuthUserCirclesList.forEach((unAuthUserCircleId) =>
          unAuthUserCircleId != circleId
              ? unAuthUserUpdatedCirclesList.add(unAuthUserCircleId)
              : null);
      unAuthUserDocumentSnapshotList.first.reference.updateData({
        Constants().firestoreUnAuthenticatedUserCriclesField:
            unAuthUserUpdatedCirclesList
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 20,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  backgroundImage: this.imageURL == null
                      ? AssetImage(Constants().defaultUserAvatarWhiteAssetPath)
                      : CachedNetworkImageProvider(this.imageURL),
                ),
              ),
              SizedBox(width: 10),
              Text(
                this.name,
                style: TextStyles.squareBoxValueStyle,
              ),
              Text(
                ' (${this.phoneNumber})',
                style: Theme.of(context)
                    .textTheme
                    .caption
                    .copyWith(color: Colors.black54),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              isUnAuthUser
                  ? CCFlatButton(
                      text: 'INVITE',
                      onPressed: () {},
                      darkTextColor: true,
                    )
                  : Container(),
              userId != adminId
                  ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        if (isUnAuthUser) {
                          removeUnAuthUser(circleId);
                        } else {
                          UserProvider(userId).removeCircle(circleId);
                          CircleProvider(circleId).removeUser(userId);
                        }
                      },
                      color: Colors.red,
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Text(
                        'admin',
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            .copyWith(color: Colors.black54),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
