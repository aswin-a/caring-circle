import 'package:quiver/core.dart';

class User {
  String _name = 'Aswin';
  String _imageURL;

  User({Map<String, Object> data}) {
    if (data != null) {
      this._name = data['name'];
      this._imageURL = data['imageURL'];
    }
  }

  @override
  bool operator ==(other) =>
      other is User &&
      this.name == other.name &&
      this.imageURL == other.imageURL;
  
  @override
  get hashCode => hash2(this._name.hashCode, this._imageURL.hashCode);

  String get name => this._name;
  set name(String name) => this._name = name;

  String get imageURL => this._imageURL;
  set imageURL(String imageURL) => this._imageURL = imageURL;

  Map<String, Object> get data =>
      {'name': this._name, 'imageURL': this._imageURL};
}
