import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void showAlert(
  BuildContext context,
  String title,
  String buttonText, {
  String description = '',
  Function onPressedButton,
  bool showCloseButton = false,
}) {
  Alert(
    context: context,
    title: title,
    desc: description,
    closeFunction: () {},
    buttons: [
      DialogButton(
        height: 50,
        radius: BorderRadius.circular(10),
        child: Text(
          buttonText,
          style: Theme.of(context).textTheme.display3,
        ),
        onPressed: () {
          if (onPressedButton != null) onPressedButton();
          Navigator.pop(context);
        },
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    ],
    style: AlertStyle(isCloseButton: showCloseButton),
  ).show();
}
