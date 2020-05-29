import 'package:flutter/material.dart';

import '../Models/User.dart';
import '../Models/Circle.dart';
import '../constants.dart';
import '../styles/textStyles.dart' as TextStyles;

class SummaryCard extends StatelessWidget {
  final User user;
  final Circle circle;
  final bool forCircle;
  final Function onTap;

  SummaryCard({
    this.user,
    this.circle,
    this.onTap,
    this.forCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    final avatarAssetPath = this.forCircle
        ? Constants().defaultCircleAvatarWhiteAssetPath
        : Constants().defaultUserAvatarWhiteAssetPath;
    final title = this.forCircle ? circle.name : user.name;
    final todayOutdoorTime = this.forCircle
        ? circle.activitiesDuration.todayOutdoorTime
        : user.activitiesDuration.todayOutdoorTime;
    final weekOutdoorTime = this.forCircle
        ? circle.activitiesDuration.weekOutdoorTime
        : user.activitiesDuration.weekOutdoorTime;
    final monthOutdoorTime = this.forCircle
        ? circle.activitiesDuration.monthOutdoorTime
        : user.activitiesDuration.monthOutdoorTime;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: this.onTap,
        child: Ink(
          padding: EdgeInsets.all(15),
          height: 120,
          decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              color: Colors.white),
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 20,
                        backgroundColor:
                            Theme.of(context).scaffoldBackgroundColor,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              Theme.of(context).scaffoldBackgroundColor,
                          backgroundImage: AssetImage(avatarAssetPath),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        title,
                        style: TextStyles.circleCardTitleStyle,
                      ),
                    ],
                  ),
                  this.onTap != null
                      ? Icon(
                          Icons.chevron_right,
                          size: 33,
                        )
                      : Container(),
                ],
              ),
              SizedBox(height: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(width: 1),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text('Today', style: TextStyles.squareBoxTitleStyle),
                        Center(
                          child: Text(todayOutdoorTime,
                              style: TextStyles.squareBoxValueStyle),
                        ),
                      ],
                    ),
                    VerticalDivider(
                      thickness: 1,
                      width: 20,
                      color: Colors.grey,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text('Week', style: TextStyles.squareBoxTitleStyle),
                        Center(
                          child: Text(weekOutdoorTime,
                              style: TextStyles.squareBoxValueStyle),
                        ),
                      ],
                    ),
                    VerticalDivider(
                      thickness: 1,
                      width: 20,
                      color: Colors.grey,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text('Month', style: TextStyles.squareBoxTitleStyle),
                        Center(
                          child: Text(monthOutdoorTime,
                              style: TextStyles.squareBoxValueStyle),
                        ),
                      ],
                    ),
                    SizedBox(width: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
