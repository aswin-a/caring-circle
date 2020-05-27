import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class User {
  String _name;
  String _imageURL;
  UserLocation _location = UserLocation();
  LocationStatus _locationStatus;

  String _todayOutdoorTime = '24 hrs 30 mins';
  String _weekOutdoorTime = '24 hrs 30 mins';
  String _monthOutdoorTime = '24 hrs 30 mins';

  User({Map<String, Object> data}) {
    if (data != null) {
      this._name = data['name'];
      this._imageURL = data['imageURL'];

      final locationStatus = data['locationStatus'];
      if (locationStatus == LocationStatus.home.toString()) {
        this._locationStatus = LocationStatus.home;
      } else if (locationStatus == LocationStatus.office.toString()) {
        this._locationStatus = LocationStatus.office;
      } else if (locationStatus == LocationStatus.outside.toString()) {
        this._locationStatus = LocationStatus.outside;
      }

      if (data.containsKey('location')) {
        this._location = UserLocation(data: data['location']);
      }
    }
  }

  String get name => this._name;
  set name(String name) => this._name = name;

  String get imageURL => this._imageURL;
  set imageURL(String imageURL) => this._imageURL = imageURL;
  
  String get todayOutdoorTime => this._todayOutdoorTime;
  set todayOutdoorTime(String imageURL) => this._todayOutdoorTime = imageURL;

  String get weekOutdoorTime => this._weekOutdoorTime;
  set weekOutdoorTime(String imageURL) => this._weekOutdoorTime = imageURL;

  String get monthOutdoorTime => this._monthOutdoorTime;
  set monthOutdoorTime(String imageURL) => this._monthOutdoorTime = imageURL;

  LocationStatus get locationStatus => this._locationStatus;
  set locationStatus(LocationStatus locationStatus) =>
      this._locationStatus = locationStatus;

  Map<String, String> get locationStatusData =>
      {'locationStatus': this._locationStatus.toString()};

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

class UserActivity {
  Timestamp _entry;
  Timestamp _exit;

  UserActivity({Map<String, dynamic> data}) {
    if (data != null) {
      this._entry = data['entry'] as Timestamp;
      this._exit = data['exit'] as Timestamp;
    }
  }

  Timestamp get entry => this._entry;
  set entry(Timestamp entry) => this._entry = entry;

  Timestamp get exit => this._exit;
  set exit(Timestamp exit) => this._exit = exit;

  Map<String, Timestamp> get data => {'entry': this._entry, 'exit': this._exit};
}
