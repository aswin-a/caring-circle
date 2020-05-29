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

  String firestoreCirclesCollection = 'circles';

  String firebaseStorageUserImagesPath = 'userImages';

  String defaultUserAvatarBlueAssetPath = 'assets/images/defaultUserAvatarBlue.png';
  String defaultUserAvatarWhiteAssetPath = 'assets/images/defaultUserAvatarWhite.png';
  String defaultUserAvatarLargeBlueAssetPath = 'assets/images/defaultUserAvatarLargeBlue.png';
  String defaultUserAvatarLargeWhiteAssetPath = 'assets/images/defaultUserAvatarLargeWhite.png';

  String defaultCircleAvatarBlueAssetPath = 'assets/images/defaultCircleAvatarBlue.png';
  String defaultCircleAvatarWhiteAssetPath = 'assets/images/defaultCircleAvatarWhite.png';
  String defaultCircleAvatarLargeBlueAssetPath = 'assets/images/defaultCircleAvatarLargeBlue.png';
  String defaultCircleAvatarLargeWhiteAssetPath = 'assets/images/defaultCircleAvatarLargeWhite.png';

  String locationPermissionAssetPath = 'assets/images/locationPermission.png';
  String logoAssetPath = 'assets/logo.png';
}

enum LocationStatus {home, office, outside}