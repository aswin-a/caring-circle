import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Dashboard/Dashboard.dart';
import './GetStarted.dart';
import '../../constants.dart';

void onSignInSuccess(BuildContext context, AuthResult authResult) {
  Constants().currentUserId = authResult.user.uid;
  Firestore.instance
      .collection(Constants().firestoreUsersCollection)
      .document(Constants().currentUserId)
      .get()
      .then((DocumentSnapshot snapshot) {
    final routeName =
        snapshot.data == null ? GetStarted.routeName : Dashboard.routeName;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(routeName, (Route<dynamic> route) => false);
  });
}
