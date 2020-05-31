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
    for (var circleUser in (data['users'] as List)) {
      this._users.add(CircleUser(circleUser['id'], circleUser['admin']));
    }
  }

  String get id => this._id;

  String get name => this._name;
  set name(String name) => this._name = name;

  String get imageURL => this._imageURL;
  set imageURL(String imageURL) => this._imageURL = imageURL;

  List<CircleUser> get users => this._users;

  // TODO: Add getting data functionality
}

class CircleUser {
  String _id;
  bool _isAdmin;

  CircleUser(this._id, [this._isAdmin = false]);

  String get id => this._id;
  bool get isAdmin => this._isAdmin;
}
