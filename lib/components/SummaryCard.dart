import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../styles/textStyles.dart' as TextStyles;
import '../Models/Activities.dart';

class SummaryCard extends StatelessWidget {
  final String title;
  final String imageURL;
  final String imageAssetPath;
  final ActivitiesDuration activitiesDuration;
  final Function onTap;
  final String rightTextData;

  SummaryCard({
    this.title,
    this.imageURL,
    this.imageAssetPath,
    this.activitiesDuration,
    this.onTap,
    this.rightTextData,
  });

  @override
  Widget build(BuildContext context) {
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
                          backgroundImage: this.imageURL != null
                              ? CachedNetworkImageProvider(this.imageURL)
                              : (this.imageAssetPath != null
                                  ? AssetImage(this.imageAssetPath)
                                  : null),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        this.title,
                        style: TextStyles.circleCardTitleStyle,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      this.rightTextData != null
                          ? Text(
                              this.rightTextData,
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(color: Colors.black54),
                            )
                          : Container(),
                      this.onTap != null
                          ? Icon(
                              Icons.chevron_right,
                              size: 33,
                            )
                          : Container(),
                    ],
                  ),
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
                          child: Text(
                              this.activitiesDuration?.todayOutdoorTime ?? '',
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
                          child: Text(
                              this.activitiesDuration?.weekOutdoorTime ?? '',
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
                          child: Text(
                              this.activitiesDuration?.monthOutdoorTime ?? '',
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
