import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/Circle.dart';
import '../constants.dart';

class CircleProvider extends ChangeNotifier {
  static final Map<String, CircleProvider> _cache =
      Map<String, CircleProvider>();

  factory CircleProvider(String circleId) {
    return _cache.putIfAbsent(
        circleId, () => CircleProvider._internal(circleId));
  }

  Circle _circle;
  StreamSubscription<DocumentSnapshot> _streamSubscription;

  CircleProvider._internal(String circleId) {
    _streamSubscription = Firestore.instance
        .collection(Constants().firestoreCirclesCollection)
        .document(circleId)
        .snapshots()
        .listen(
      (circleSnapshot) {
        if (this._circle == null) {
          this._circle = Circle.fromData(circleSnapshot.data);
        } else {
          this._circle.updateData(circleSnapshot.data);
        }
        notifyListeners();
      },
    );
  }

  Future<void> uploadData({
    onlyCircleData: false,
    onlyUsersData: false,
  }) async {
    Map _uploadData;

    if (onlyCircleData) {
      _uploadData = this._circle.circleData;
    } else if (onlyUsersData) {
      _uploadData = this._circle.usersData;
    } else {
      _uploadData = this._circle.data;
    }

    await Firestore.instance
        .collection(Constants().firestoreCirclesCollection)
        .document(this._circle.id)
        .updateData(_uploadData);
  }

  Future<void> removeUser(String userId) async {
    this._circle.users.removeWhere((circleUser) => circleUser.id == userId);
    await this.uploadData(onlyUsersData: true);
  }

  destruct() {
    _streamSubscription.cancel();
  }

  // TODO: Call this function
  static void destroy() {
    for (var circleProvider in _cache.values) {
      circleProvider.destruct();
    }
  }

  Circle get circle => this._circle;
}
