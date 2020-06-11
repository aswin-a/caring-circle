import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/Activities.dart';
import './CircleProvider.dart';
import './UserActivitiesProvider.dart';
import './BaseActivitiesProvider.dart';

class CircleActivitiesProvider extends ChangeNotifier implements BaseActivitiesProvider {
  static final Map<String, CircleActivitiesProvider> _cache =
      Map<String, CircleActivitiesProvider>();

  factory CircleActivitiesProvider(String circleId) {
    return _cache.putIfAbsent(
        circleId, () => CircleActivitiesProvider._internal(circleId));
  }

  ActivitiesDuration _activitiesDuration;
  StreamSubscription<List<QuerySnapshot>> _streamSubscription;

  Map<String, UserActivitiesProvider> _userActivitiesProviderMap =
      Map<String, UserActivitiesProvider>();

  CircleActivitiesProvider._internal(circleId) {
    // TODO: Remove listener on CircleProvider
    // TODO: Refresh listeners at the start of day, week and month
    onCircleProviderUpdate(CircleProvider circleProvider) {
      if (circleProvider.circle == null) return;

      _userActivitiesProviderMap.values.forEach((userActivitiesProvider) =>
          userActivitiesProvider.removeListener(this._updateDurationData));
      _userActivitiesProviderMap = Map<String, UserActivitiesProvider>();

      circleProvider.circle.users.forEach((circleUser) {
        final userActivitiesProvider = UserActivitiesProvider(circleUser.id);
        _userActivitiesProviderMap
            .addEntries([MapEntry(circleUser.id, userActivitiesProvider)]);
        userActivitiesProvider.addListener(this._updateDurationData);
      });
      this._updateDurationData();
    }

    final circleProvider = CircleProvider(circleId);
    onCircleProviderUpdate(circleProvider);
    circleProvider.addListener(() => onCircleProviderUpdate(circleProvider));
  }

  _updateDurationData() {
    List<double> todayData, weekData, monthData;
    for (UserActivitiesProvider userActivitiesProvider
        in _userActivitiesProviderMap.values) {
      if (userActivitiesProvider.activitiesDuration != null) {
        final userActivitiesDuration =
            userActivitiesProvider.activitiesDuration;
        todayData = todayData == null
            ? userActivitiesDuration.todayData
            : IterableZip([todayData, userActivitiesDuration.todayData])
                .map((e) => e[0] + e[1])
                .toList();
        weekData = weekData == null
            ? userActivitiesDuration.weekData
            : IterableZip([weekData, userActivitiesDuration.weekData])
                .map((e) => e[0] + e[1])
                .toList();
        monthData = monthData == null
            ? userActivitiesDuration.monthData
            : IterableZip([monthData, userActivitiesDuration.monthData])
                .map((e) => e[0] + e[1])
                .toList();
      }
    }

    final nUser = _userActivitiesProviderMap.length;
    todayData = todayData?.map((e) => e/nUser)?.toList();
    weekData = weekData?.map((e) => e/nUser)?.toList();
    monthData = monthData?.map((e) => e/nUser)?.toList();

    this._activitiesDuration =
        ActivitiesDuration(todayData, weekData, monthData);
    notifyListeners();
  }

  destruct() {
    _streamSubscription.cancel();
  }

  // TODO: Call this function
  static void destroy() {
    for (var circleActivitiesProvider in _cache.values) {
      circleActivitiesProvider.destruct();
    }
  }

  ActivitiesDuration get activitiesDuration => this._activitiesDuration;
}
