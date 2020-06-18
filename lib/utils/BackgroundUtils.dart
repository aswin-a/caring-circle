import 'package:background_fetch/background_fetch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import './ActivityUtils.dart';
import '../constants.dart';
import '../Models/User.dart';

const double GEOFENCE_RADIUS = 100;

final BackgroundFetchConfig backgroundFetchConfig = BackgroundFetchConfig(
  minimumFetchInterval: 10,
  enableHeadless: true,
  forceAlarmManager: true,
  requiredNetworkType: NetworkType.ANY,
  requiresBatteryNotLow: false,
  requiresCharging: false,
  requiresDeviceIdle: false,
  requiresStorageNotLow: false,
  startOnBoot: true,
  stopOnTerminate: false,
);

Future<void> callback(String taskId) async {
  print('CaCi: Callback started: $taskId');

  final firebaseUser = await FirebaseAuth.instance.currentUser();
  if (firebaseUser == null) {
    print('CaCi: Callback failed: FirebaseUser: null');
    BackgroundFetch.finish(taskId);
    return;
  }

  print('CaCi: FirebaseAuth accessible');

  // TODO: Remove this
  Firestore.instance.collection('temp').add({
    'time': Timestamp.fromDate(DateTime.now().toUtc()),
    'phone': firebaseUser.phoneNumber
  });

  print('CaCi: FireStore accessible');

  final userDocumentReference = Firestore.instance
      .collection(Constants().firestoreUsersCollection)
      .document(firebaseUser.uid);
  final user = User.fromData((await userDocumentReference.get()).data);

  final Position currentLocation = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  print('CaCi: Geolocator accessible');

  final distanceFromHome = await Geolocator().distanceBetween(
    user.location.home.latitude,
    user.location.home.longitude,
    currentLocation.latitude,
    currentLocation.longitude,
  );
  final distanceFromOffice = user.location.office == null
      ? double.infinity
      : await Geolocator().distanceBetween(
          user.location.office.latitude,
          user.location.office.longitude,
          currentLocation.latitude,
          currentLocation.longitude,
        );

  LocationStatus currentLocationStatus;
  if (distanceFromHome > GEOFENCE_RADIUS &&
      distanceFromOffice > GEOFENCE_RADIUS) {
    currentLocationStatus = LocationStatus.outside;
  } else if (distanceFromHome < GEOFENCE_RADIUS) {
    currentLocationStatus = LocationStatus.home;
  } else if (distanceFromOffice < GEOFENCE_RADIUS) {
    currentLocationStatus = LocationStatus.office;
  }

  print('CaCi: Location Status: $currentLocationStatus');
  print('CaCi: Past Location Status: ${user.locationStatus}');

  await userDocumentReference
      .updateData({'locationStatus': currentLocationStatus.toString()});

  if (currentLocationStatus != user.locationStatus) {
    final currentActivityQuerySnapshot =
        await getCurrentActivityFuture(firebaseUser.uid);

    if (user.locationStatus == LocationStatus.outside) {
      if (currentActivityQuerySnapshot.documents.length == 0) return;

      final latestActivityDocumentSnapshot =
          currentActivityQuerySnapshot.documents.first;
      final latestActivity =
          UserActivity(data: latestActivityDocumentSnapshot.data);
      if (latestActivity.entry == null) {
        latestActivity.entry = Timestamp.fromDate(DateTime.now().toUtc());
        await latestActivityDocumentSnapshot.reference
            .updateData(latestActivity.data);
      }
    } else if (currentLocationStatus == LocationStatus.outside) {
      final newActivity = UserActivity();
      newActivity.exit = Timestamp.fromDate(DateTime.now().toUtc());
      await userDocumentReference
          .collection(Constants().firestoreUserActivitiesCollection)
          .add(newActivity.data);
    }
  }

  BackgroundFetch.finish(taskId);
}

Future<void> stopBackgroundTask() async => await BackgroundFetch.stop();

void executeBackgroundTask([int delay = 0]) {
  BackgroundFetch.scheduleTask(TaskConfig(
    taskId: "background.task.single.execution",
    delay: delay,
  ));
}

void initializeBackgroundTask() async {
  await BackgroundFetch.stop();
  await BackgroundFetch.configure(backgroundFetchConfig, callback);
  executeBackgroundTask(1000);
}
