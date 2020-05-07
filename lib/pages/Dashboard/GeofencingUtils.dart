import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geofencing/geofencing.dart';

import '../../constants.dart';
import '../../Models/User.dart';

const HOME_GEOFENCE_ID = 'home';
const OFFICE_GEOFENCE_ID = 'office';

const List<GeofenceEvent> triggers = <GeofenceEvent>[
  GeofenceEvent.enter,
  GeofenceEvent.exit,
];

void callback(List<String> ids, Location l, GeofenceEvent e) async {
  print('Fences: $ids Location $l Event: $e');

  // TODO: IF null, remove the geofence
  final firebaseUser = await FirebaseAuth.instance.currentUser();

  final userDocumentReference = Firestore.instance
      .collection(Constants().firestoreUsersCollection)
      .document(firebaseUser.uid);
  
  final activityCollectionReference = userDocumentReference.collection('activity');

  final latestActivityQuerySnapshot = await activityCollectionReference
          .orderBy('exit', descending: true)
          .limit(1)
          .getDocuments();
  
  if (latestActivityQuerySnapshot.documents.length > 0) {
    final latestActivityDocumentSnapshot = latestActivityQuerySnapshot.documents.first;
    final latestActivity = UserActivity(data: latestActivityDocumentSnapshot.data);

    if (latestActivity.entry == null) {
      latestActivity.entry = Timestamp.fromDate(DateTime.now().toUtc());
      latestActivityDocumentSnapshot.reference.setData(latestActivity.data);
    }
  }

  if (e == GeofenceEvent.exit) {
    userDocumentReference
        .setData({'locationStatus': LocationStatus.outside.toString()}, merge: true);

    final newActivity = UserActivity();
    newActivity.exit = Timestamp.fromDate(DateTime.now().toUtc());
    activityCollectionReference.add(newActivity.data);
  } else if (e == GeofenceEvent.enter) {
    if (ids[0] == HOME_GEOFENCE_ID) {
      userDocumentReference
        .setData({'locationStatus': LocationStatus.home.toString()}, merge: true);
    } else if (ids[0] == OFFICE_GEOFENCE_ID) {
      userDocumentReference
        .setData({'locationStatus': LocationStatus.office.toString()}, merge: true);
    }
  }
}

void initialiseGeofenceManager() async {
  await GeofencingManager.initialize();
}

void initialiseGeofence(
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
        // androidSettings: androidSettings,
      ),
      callback,
    );
  }
}

reomoveGeofence([String geofenceId = HOME_GEOFENCE_ID]) {
  GeofencingManager.removeGeofenceById(geofenceId);
}
