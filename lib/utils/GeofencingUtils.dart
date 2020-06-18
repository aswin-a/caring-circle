import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geofencing/geofencing.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_permissions/location_permissions.dart';

import '../constants.dart';
import '../Models/User.dart';

const HOME_GEOFENCE_ID = 'home';
const OFFICE_GEOFENCE_ID = 'office';

const double GEOFENCE_RADIUS = 50;

const List<GeofenceEvent> triggers = <GeofenceEvent>[
  GeofenceEvent.enter,
  GeofenceEvent.exit,
];

final AndroidGeofencingSettings androidSettings = AndroidGeofencingSettings(
  initialTrigger: <GeofenceEvent>[
    GeofenceEvent.enter,
    GeofenceEvent.exit,
  ],
  notificationResponsiveness: 60000,
);

void callback(List<String> ids, Location l, GeofenceEvent e) async {
  print('Fences: $ids Location $l Event: $e');

  final firebaseUser = await FirebaseAuth.instance.currentUser();
  if (firebaseUser == null) return;

  final userDocumentReference = Firestore.instance
      .collection(Constants().firestoreUsersCollection)
      .document(firebaseUser.uid);

  final user = User.fromData((await userDocumentReference.get()).data);

  final activityCollectionReference = userDocumentReference
      .collection(Constants().firestoreUserActivitiesCollection);

  final latestActivityQuerySnapshot = await activityCollectionReference
      .orderBy(Constants().firestoreUserActivitiesExitField, descending: true)
      .limit(1)
      .getDocuments();

  if (latestActivityQuerySnapshot.documents.length > 0) {
    final latestActivityDocumentSnapshot =
        latestActivityQuerySnapshot.documents.first;
    final latestActivity =
        UserActivity(data: latestActivityDocumentSnapshot.data);

    if (latestActivity.entry == null) {
      latestActivity.entry = Timestamp.fromDate(DateTime.now().toUtc());
      latestActivityDocumentSnapshot.reference.updateData(latestActivity.data);
    }
  }

  if (e == GeofenceEvent.exit) {
    final distanceFromHome = await Geolocator().distanceBetween(
      user.location.home.latitude,
      user.location.home.longitude,
      l.latitude,
      l.longitude,
    );
    var distanceFromOffice = double.infinity;
    if (user.location.office != null) {
      distanceFromOffice = await Geolocator().distanceBetween(
        user.location.office.latitude,
        user.location.office.longitude,
        l.latitude,
        l.longitude,
      );
    }

    if ((ids.first == HOME_GEOFENCE_ID &&
            distanceFromOffice > GEOFENCE_RADIUS) ||
        (ids.first == OFFICE_GEOFENCE_ID &&
            distanceFromHome > GEOFENCE_RADIUS)) {
      userDocumentReference
          .updateData({'locationStatus': LocationStatus.outside.toString()});

      final newActivity = UserActivity();
      newActivity.exit = Timestamp.fromDate(DateTime.now().toUtc());
      activityCollectionReference.add(newActivity.data);
    }
  } else if (e == GeofenceEvent.enter) {
    if (ids[0] == HOME_GEOFENCE_ID) {
      userDocumentReference
          .updateData({'locationStatus': LocationStatus.home.toString()});
    } else if (ids[0] == OFFICE_GEOFENCE_ID) {
      userDocumentReference
          .updateData({'locationStatus': LocationStatus.office.toString()});
    }
  }
}

Future<void> initialiseGeofenceManager() async {
  await GeofencingManager.initialize();
}

void initialiseHomeGeofence(double latitude, double longitude) {
  _initialiseGeofence(latitude, longitude, GEOFENCE_RADIUS, HOME_GEOFENCE_ID);
}

void initialiseOfficeGeofence(double latitude, double longitude) {
  _initialiseGeofence(latitude, longitude, GEOFENCE_RADIUS, OFFICE_GEOFENCE_ID);
}

void _initialiseGeofence(
  double latitude,
  double longitude,
  double radius, [
  String geofenceId = HOME_GEOFENCE_ID,
]) async {
  final geofenceIds = await GeofencingManager.getRegisteredGeofenceIds();

  if (geofenceIds.indexOf(geofenceId) == -1) {
    await GeofencingManager.registerGeofence(
      GeofenceRegion(
        geofenceId,
        latitude,
        longitude,
        radius,
        triggers,
        androidSettings: androidSettings,
      ),
      callback,
    );
  }
}

Future<bool> removeHomeGeofence() async {
  await _removeGeofence(HOME_GEOFENCE_ID);
  final geofenceIds = await GeofencingManager.getRegisteredGeofenceIds();
  return geofenceIds.indexOf(HOME_GEOFENCE_ID) == -1;
}

Future<bool> removeOfficeGeofence() async {
  await _removeGeofence(OFFICE_GEOFENCE_ID);
  final geofenceIds = await GeofencingManager.getRegisteredGeofenceIds();
  return geofenceIds.indexOf(OFFICE_GEOFENCE_ID) == -1;
}

Future<void> _removeGeofence([String geofenceId = HOME_GEOFENCE_ID]) async {
  await GeofencingManager.removeGeofenceById(geofenceId);
}

Future<bool> checkLocationPermission() async {
  var permissionStatus = await LocationPermissions()
      .checkPermissionStatus(level: LocationPermissionLevel.locationAlways);
  if (permissionStatus != PermissionStatus.granted) {
    permissionStatus = await LocationPermissions().requestPermissions(
        permissionLevel: LocationPermissionLevel.locationAlways);
  }
  return permissionStatus == PermissionStatus.granted;
}
