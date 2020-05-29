import './Activities.dart';

class Circle {
  String _name;
  String _imageURL;
  List<CircleUser> _users = [];
  ActivitiesDuration _activitiesDuration;

  Circle({Map<String, Object> data}) {
    if (data != null) {
      this._name = data['name'];
      this._imageURL = data['imageURL'];
      for (var circleUser in (data['users'] as List)) {
        this._users.add(CircleUser(circleUser['id'], circleUser['admin']));
      }
    }
  }

  String get name => this._name;
  set name(String name) => this._name = name;

  String get imageURL => this._imageURL;
  set imageURL(String imageURL) => this._imageURL = imageURL;

  List<CircleUser> get users => this._users;

  ActivitiesDuration get activitiesDuration => this._activitiesDuration;
  set activitiesDuration(ActivitiesDuration activitiesDuration) =>
      this._activitiesDuration = activitiesDuration;
}

class CircleUser {
  String _id;
  bool _isAdmin;

  CircleUser(this._id, [this._isAdmin = false]);

  String get id => this._id;
  bool get isAdmin => this._isAdmin;
}
