import 'package:flutter/material.dart';

class User with ChangeNotifier {
  bool isLoggedin = false;
  String userToken;

  int id;
  String name = 'Aswin';
  String imageURL;
  int score = 134;
  int streak = 21;

  User({@required this.isLoggedin, this.userToken});

  updateName(String name) {
    this.name = name;
    notifyListeners();
  }
}
