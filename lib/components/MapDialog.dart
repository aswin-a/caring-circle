import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../utils/GeofencingUtils.dart';

void showMapDialog(BuildContext context, String title, Function onComplete,
    Function(LatLng) onCameraUpdate,
    [LatLng startLocation]) async {
  if (startLocation == null) {
    if (await checkLocationPermission(context)) {
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      startLocation = LatLng(position.latitude, position.longitude);
    } else {
      startLocation = LatLng(27.174991, 78.042123);
    }
  }

  onCameraUpdate(startLocation);

  showDialog(
    context: context,
    builder: (ctx) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
              onPressed: () {
                onComplete();
                Navigator.of(context).pop();
              },
            )
          ],
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(title),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            GoogleMap(
              initialCameraPosition:
                  CameraPosition(target: startLocation, zoom: 19),
              onCameraMove: (cameraPosition) {
                onCameraUpdate(cameraPosition.target);
              },
              myLocationEnabled: true,
              tiltGesturesEnabled: false,
            ),
            Positioned(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.location_on,
                    size: 44,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  SizedBox(
                    height: 44,
                  )
                ],
              ),
            )
          ],
        ),
      );
    },
  );
}
