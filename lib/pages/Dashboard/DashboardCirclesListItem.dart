import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/CircleProvider.dart';
import '../../providers/CircleActivitiesProvider.dart';
import '../../components/SummaryCard.dart';
import '../../constants.dart';

class DashboardCirclesListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<CircleProvider, CircleActivitiesProvider>(
      builder: (context, circleProvider, circleActivitiesProvider, _) {
        return SummaryCard(
          title: circleProvider.circle?.name ?? '',
          imageURL: circleProvider.circle?.imageURL,
          imageAssetPath: Constants().defaultCircleAvatarWhiteAssetPath,
          activitiesDuration: circleActivitiesProvider.activitiesDuration,
        );
      },
    );
  }
}
