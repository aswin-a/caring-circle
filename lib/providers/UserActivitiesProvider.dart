import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../Models/User.dart';
import '../Models/Activities.dart';
import '../constants.dart';
import '../utils/ActivityUtils.dart' as ActivityUtils;
import './BaseActivitiesProvider.dart';

class UserActivitiesProvider extends ChangeNotifier
    implements BaseActivitiesProvider {
  static final Map<String, UserActivitiesProvider> _cache =
      Map<String, UserActivitiesProvider>();

  factory UserActivitiesProvider(String userId) {
    return _cache.putIfAbsent(
        userId, () => UserActivitiesProvider._internal(userId));
  }

  ActivitiesDuration _activitiesDuration;
  Timer _currentActivityRefreshTimer;
  StreamSubscription<List<QuerySnapshot>> _streamSubscription;
  List<Map<String, dynamic>> _activitiesData;
  Map<String, dynamic> _currentActivityData;

  UserActivitiesProvider._internal(userId) {
    // TODO: Refresh listeners at the start of day, week and month
    _streamSubscription = CombineLatestStream.list([
      ActivityUtils.getThisMonthActivitiesStream(userId),
      ActivityUtils.getCurrentActivityStream(userId),
    ]).listen((activitiesSnapshotList) {
      this._currentActivityRefreshTimer?.cancel();
      this._activitiesData =
          activitiesSnapshotList[0].documents.map((e) => e.data).toList();
      if (activitiesSnapshotList[1].documents.length == 1) {
        this._currentActivityData =
            activitiesSnapshotList[1].documents.first.data;
        this._currentActivityRefreshTimer = Timer.periodic(
          Duration(minutes: 1),
          (_) => this._updateDurationData(),
        );
      } else {
        this._currentActivityData = null;
      }
      this._updateDurationData();
    });
  }

  _updateDurationData() {
    final activitiesData =
        List<Map<String, dynamic>>.from(this._activitiesData);

    if (this._currentActivityData != null) {
      final currentActivityData =
          Map<String, dynamic>.from(this._currentActivityData);
      currentActivityData[Constants().firestoreUserActivitiesEntryField] =
          Timestamp.fromDate(DateTime.now().toUtc());
      activitiesData.insert(0, currentActivityData);
    }

    final durationData =
        ActivityUtils.getDurationDataFromOrderedActivities(activitiesData);
    this._activitiesDuration =
        ActivitiesDuration(durationData[0], durationData[1], durationData[2]);

    notifyListeners();
  }

  destruct() {
    this._currentActivityRefreshTimer?.cancel();
    _streamSubscription.cancel();
  }

  // TODO: Call this function
  static void destroy() {
    for (var userActivitiesProvider in _cache.values) {
      userActivitiesProvider.destruct();
    }
  }

  ActivitiesDuration get activitiesDuration => this._activitiesDuration;

  DateTime get currentActivityExitTime => this._currentActivityData == null
      ? null
      : UserActivity(data: this._currentActivityData).exit.toDate();
}
