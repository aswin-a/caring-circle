import 'package:flutter/material.dart';

class User with ChangeNotifier {
  int id;
  String name = 'Aswin';
  String imageURL;
  int score = 134;
  int streak = 21;

  User();

  updateName(String name) {
    this.name = name;
    notifyListeners();
  }
}
