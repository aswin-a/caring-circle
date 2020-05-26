class Constants {
  static final Constants _singleton = Constants._internal();

  factory Constants() {
    return _singleton;
  }

  Constants._internal();

  String _currentUserId;
  String get currentUserId => this._currentUserId;
  set currentUserId (String uid) => this._currentUserId = uid;

  String firestoreUsersCollection = 'users';
  String firestoreUserActivitiesCollection = 'activities';
  String firestoreUserActivitiesExitField = 'exit';
  String firestoreUserActivitiesEntryField = 'entry';

  String firebaseStorageUserImagesPath = 'userImages';

  String defaultUserAvatarAssetPath = 'assets/images/defaultAvatarLarge.png';
  String locationPermissionAssetPath = 'assets/images/location_permission.png';
  String logoAssetPath = 'assets/logo.png';
}

enum LocationStatus {home, office, outside}