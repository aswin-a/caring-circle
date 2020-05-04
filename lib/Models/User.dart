import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String _name = 'Aswin';
  String _imageURL;
  UserLocation _location = UserLocation();

  User({Map<String, Object> data}) {
    if (data != null) {
      this._name = data['name'];
      this._imageURL = data['imageURL'];

      if (data.containsKey('location')) {
        this._location = UserLocation(data: data['location']);
      }
    }
  }

  String get name => this._name;
  set name(String name) => this._name = name;

  String get imageURL => this._imageURL;
  set imageURL(String imageURL) => this._imageURL = imageURL;

  Map<String, Object> get userData =>
      {'name': this._name, 'imageURL': this._imageURL};

  UserLocation get location => this._location;

  Map<String, Map<String, GeoPoint>> get locationData =>
      {'location': this._location.data};

  Map<String, Object> get data =>
      {}..addAll(this.userData)..addAll(this.locationData);
}

class UserLocation {
  GeoPoint _home;
  GeoPoint _office;

  UserLocation({data}) {
    if (data != null) {
      this._home = data['home'];
      this._office = data['office'];
    }
  }

  GeoPoint get home => this._home;
  void setHomeLocation(double latitude, double longitude) =>
      this._home = GeoPoint(latitude, longitude);

  GeoPoint get office => this._office;
  void setOfficeLocation(double latitude, double longitude) =>
      this._office = GeoPoint(latitude, longitude);

  Map<String, GeoPoint> get data =>
      {'home': this._home, 'office': this._office};
}
