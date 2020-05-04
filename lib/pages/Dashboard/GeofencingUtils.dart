import 'package:geofencing/geofencing.dart';

const HOME_GEOFENCE_ID = 'home';
const OFFICE_GEOFENCE_ID = 'office';

const List<GeofenceEvent> triggers = <GeofenceEvent>[
  GeofenceEvent.enter,
  GeofenceEvent.exit,
];

void callback(List<String> ids, Location l, GeofenceEvent e) async {
  print('Fences: $ids Location $l Event: $e');
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
