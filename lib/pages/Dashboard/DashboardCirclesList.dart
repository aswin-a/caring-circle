import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Models/User.dart';
import '../../Models/Circle.dart';
import '../../constants.dart';
import './DashboardCirclesListItem.dart';

class DashboardCirclesList extends StatelessWidget {
  //TODO: Stream builder on user since we need to detect user changes
  final User user;
  Future combinedFuture;

  DashboardCirclesList({this.user}) {
    final circleIds = this.user.circles;
    this.combinedFuture = Future.wait(circleIds
        .map((e) => Firestore.instance
            .collection(Constants().firestoreCirclesCollection)
            .document(e)
            .get())
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this.combinedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final documentSnapshotList = snapshot.data as List<DocumentSnapshot>;
          final circlesList =
              documentSnapshotList.map((e) => Circle(data: e.data)).toList();
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 15),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            separatorBuilder: (ctx, index) => SizedBox(height: 10),
            itemCount: circlesList.length,
            itemBuilder: (BuildContext ctx, int index) {
              return DashboardCirclesListItem(circlesList[index]);
            },
          );
        }
        return Container();
      },
    );
  }
}
