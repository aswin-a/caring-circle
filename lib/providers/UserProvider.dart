import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Models/User.dart';
import '../constants.dart';

class UserProvider extends ChangeNotifier {
  static final Map<String, UserProvider> _cache = Map<String, UserProvider>();

  factory UserProvider(String userId) {
    return _cache.putIfAbsent(userId, () => UserProvider._internal(userId));
  }

  User _user;
  StreamSubscription<DocumentSnapshot> _streamSubscription;

  UserProvider._internal(String userId) {
    _streamSubscription = Firestore.instance
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
  }

  Future<void> uploadData({
    onlyUserData: false,
    onlyCirclesData: false,
    onlyLocationData: false,
  }) async {
    Map _uploadData;

    if (onlyUserData) {
      _uploadData = this._user.userData;
    } else if (onlyCirclesData) {
      _uploadData = this._user.circlesData;
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

  Future<void> removeCircle(String circleId) async {
    this.user.circles.removeWhere((id) => id == circleId);
    await this.uploadData(onlyCirclesData: true);
  }

  destruct() {
    _streamSubscription.cancel();
  }

  // TODO: Call this function
  static void destroy() {
    for (var userProvider in _cache.values) {
      userProvider.destruct();
    }
  }

  User get user => this._user;
}
