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

  // TODO: Update this functionality
  // Future<void> uploadData({
  //   onlyUserData: false,
  //   onlyLocationData: false,
  // }) async {
  //   Map _uploadData;

  //   if (onlyUserData) {
  //     _uploadData = this._user.userData;
  //   } else if (onlyLocationData) {
  //     _uploadData = this._user.locationData;
  //   } else {
  //     _uploadData = this._user.data;
  //   }

  //   await Firestore.instance
  //       .collection(Constants().firestoreUsersCollection)
  //       .document(this._user.id)
  //       .updateData(_uploadData);
  // }

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
