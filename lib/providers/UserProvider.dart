import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

import '../Models/User.dart';
import '../Models/Activities.dart';
import '../constants.dart';
import '../utils/ActivityUtils.dart' as ActivityUtils;

class UserProvider extends ChangeNotifier {
  static final Map<String, UserProvider> _cache = Map<String, UserProvider>();

  factory UserProvider(String userId) {
    return _cache.putIfAbsent(userId, () => UserProvider._internal(userId));
  }

  User _user;
  Timer _currentActivityRefreshTimer;
  StreamSubscription<List<QuerySnapshot>> _streamSubscription;
  List<Map<String, dynamic>> _activitiesData;
  Map<String, dynamic> _currentActivityData;

  UserProvider._internal(userId) {
    Firestore.instance
        .collection(Constants().firestoreUsersCollection)
        .document(userId)
        .snapshots()
        .listen(
      (userSnapshot) {
        if (this._user == null) {
          this._user = User.fromData(userSnapshot.data);
        } else {
          this._user.updateData(userSnapshot.data);
        }
        notifyListeners();
      },
    );

    this._streamSubscription = CombineLatestStream.list([
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
          // TODO: Increase to 1 minute
          Duration(seconds: 10),
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
    this._user.activitiesDuration =
        ActivitiesDuration(durationData[0], durationData[1], durationData[2]);

    notifyListeners();
  }

  Future<void> uploadData({onlyUserData: false, onlyLocationData: false}) async {
    // TODO: Add circle data
    Map _uploadData;

    if (onlyUserData) {
      _uploadData = this._user.userData;
    } else if (onlyLocationData) {
      _uploadData = this._user.locationData;
    } else {
      _uploadData = this._user.data;
    }

    await Firestore.instance
        .collection(Constants().firestoreUsersCollection)
        .document(this._user.id)
        .updateData(_uploadData);
  }

  destruct() {
    this._currentActivityRefreshTimer?.cancel();
    _streamSubscription.cancel();
  }

  // TODO: Call this function
  static void destroy() {
    for (var userProvider in _cache.values) {
      userProvider.destruct();
    }
  }

  User get user => this._user;

  // TODO: Notify for this also when fixing circles flashing fix (used for current status update)
  DateTime get currentActivityExitTime => this._currentActivityData == null
      ? null
      : UserActivity(data: this._currentActivityData).exit.toDate();
}
