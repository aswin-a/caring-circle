import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../components/SubtitleBar.dart';
import '../../components/SettingsBlock.dart';
import '../../components/MapDialog.dart';
import '../../providers/UserProvider.dart';
import '../../utils/GeofencingUtils.dart';

class UserSettingsLocation extends StatelessWidget {
  LatLng locationOnMap;

  void getHomeLocation(BuildContext context, UserProvider userProvider) {
    void updateHomeLocation() async {
      userProvider.user.location.setHomeLocation(
          this.locationOnMap.latitude, this.locationOnMap.longitude);
      await userProvider.uploadData(onlyLocationData: true);

      await removeHomeGeofence();
      initialiseHomeGeofence(
        userProvider.user.location.home.latitude,
        userProvider.user.location.home.longitude,
      );
    }

    void updateLocationOnMap(LatLng location) {
      this.locationOnMap = location;
    }

    LatLng startLocation;
    if (userProvider.user.location.home != null) {
      startLocation = LatLng(
        userProvider.user.location.home.latitude,
        userProvider.user.location.home.longitude,
      );
    }

    showMapDialog(
      context,
      'Home Location',
      updateHomeLocation,
      updateLocationOnMap,
      startLocation,
    );
  }

  void getOfficeLocation(BuildContext context, UserProvider userProvider) {
    void updateOfficeLocation() async {
      userProvider.user.location.setOfficeLocation(
          this.locationOnMap.latitude, this.locationOnMap.longitude);
      await userProvider.uploadData(onlyLocationData: true);

      await removeOfficeGeofence();
      initialiseOfficeGeofence(
        userProvider.user.location.office.latitude,
        userProvider.user.location.office.longitude,
      );
    }

    void updateLocationOnMap(LatLng location) {
      this.locationOnMap = location;
    }

    LatLng startLocation;
    if (userProvider.user.location.office != null) {
      startLocation = LatLng(
        userProvider.user.location.office.latitude,
        userProvider.user.location.office.longitude,
      );
    }

    showMapDialog(
      context,
      'Office Location',
      updateOfficeLocation,
      updateLocationOnMap,
      startLocation,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        return Column(
          children: <Widget>[
            SubtitleBar('Location'),
            SettingsBlock(
              'Home',
              showRightChevron: true,
              leftIcon: Icons.home,
              onTap: () => getHomeLocation(context, userProvider),
              rightTextData:
                  userProvider.user?.location?.home == null ? 'unset' : null,
            ),
            SizedBox(height: 10),
            SettingsBlock(
              'Office',
              showRightChevron: true,
              leftIcon: Icons.business_center,
              onTap: () => getOfficeLocation(context, userProvider),
              rightTextData:
                  userProvider.user?.location?.office == null ? 'unset' : null,
            ),
          ],
        );
      },
    );
  }
}
