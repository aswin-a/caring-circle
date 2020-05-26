import 'dart:async';

import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';

import '../../constants.dart';
import '../../utils/GeofencingUtils.dart';
import '../Dashboard/Dashboard.dart';

class Permission extends StatelessWidget {
  static const routeName = '/permission';
  static const pageTitle = 'Permission';

  Future<bool> locationPermission;
  
  Permission() {
    this.locationPermission = checkLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage(Constants().locationPermissionAssetPath), context);
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        minimum: EdgeInsets.symmetric(horizontal: 15),
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: FutureBuilder<bool>(
            future: locationPermission,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container();
              }
              
              if (snapshot.data) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Dashboard.routeName, (Route<dynamic> route) => false);
                });
                return Container();
              }

              Timer.periodic(
                Duration(seconds: 1),
                (Timer t) async {
                  if (await LocationPermissions().checkPermissionStatus(
                          level: LocationPermissionLevel.locationAlways) ==
                      PermissionStatus.granted) {
                    t.cancel();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        Dashboard.routeName, (Route<dynamic> route) => false);
                  }
                },
              );

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      SizedBox(height: 44),
                      Text('Before we proceed...',
                          style: Theme.of(context).textTheme.display4),
                      Text('', style: Theme.of(context).textTheme.display4),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        Constants().locationPermissionAssetPath,
                        height: 150,
                        width: 150,
                      ),
                      SizedBox(height: 22),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'We need your permission to keep track of your time outside.' +
                              ' Please allow us to access your location when not using the app.',
                          style: Theme.of(context).textTheme.display2,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 44),
                    child: FlatButton(
                      onPressed: () {
                        LocationPermissions().openAppSettings();
                      },
                      child: Text('Allow Access',
                          style: Theme.of(context).textTheme.button),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
