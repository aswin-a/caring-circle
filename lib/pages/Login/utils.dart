import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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

void showAlert(BuildContext context, String title, String buttonText,
    [String description = '']) {
  Alert(
    context: context,
    title: title,
    desc: description,
    buttons: [
      DialogButton(
        height: 50,
        radius: BorderRadius.circular(10),
        child: Text(
          buttonText,
          style: Theme.of(context).textTheme.display3,
        ),
        onPressed: () => Navigator.pop(context),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    ],
    style: AlertStyle(isCloseButton: false),
  ).show();
}
