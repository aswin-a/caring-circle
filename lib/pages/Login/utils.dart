import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Permission/Permission.dart';
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
        snapshot.data == null ? GetStarted.routeName : Permission.routeName;
    Navigator.of(context)
        .pushNamedAndRemoveUntil(routeName, (Route<dynamic> route) => false);
  });
}
