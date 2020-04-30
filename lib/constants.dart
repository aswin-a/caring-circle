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

  String firebaseStorageUserImagesPath = 'userImages';

  String defaultUserAvatarAssetPath = 'assets/images/defaultAvatarLarge.png';
  String logoAssetPath = 'assets/logo.png';
}