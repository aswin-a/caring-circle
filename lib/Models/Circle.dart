class Circle {
  String _id;
  String _name;
  String _imageURL;
  List<CircleUser> _users;

  Circle();

  Circle.fromData(Map<String, Object> data) {
    if (data != null) {
      this.updateData(data);
    }
  }

  updateData(Map<String, Object> data) {
    this._id = data['id'];
    this._name = data['name'];
    this._imageURL = data['imageURL'];

    this._users = [];
    for (var circleUserData in (data['users'] as List)) {
      this._users.add(CircleUser(data: (circleUserData)));
    }
  }

  String get id => this._id;

  String get name => this._name;
  set name(String name) => this._name = name;

  String get imageURL => this._imageURL;
  set imageURL(String imageURL) => this._imageURL = imageURL;

  List<CircleUser> get users => this._users;

  Map<String, Object> get circleData =>
      {'name': this._name, 'imageURL': this._imageURL};

  Map<String, List<Map<String, Object>>> get usersData =>
      {'users': this._users.map((e) => e.data).toList()};

  Map<String, Object> get data =>
      {}..addAll(this.circleData)..addAll(this.usersData);
}

class CircleUser {
  String _id;
  bool _isAdmin = false;

  CircleUser({Map data}) {
    if (data != null) {
      this._id = data['id'];
      this._isAdmin = data['admin'];
    }
  }

  String get id => this._id;
  bool get isAdmin => this._isAdmin;

  Map<String, Object> get data => {'id': this._id, 'admin': this.isAdmin};
}
