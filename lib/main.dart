import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:background_fetch/background_fetch.dart';

import './pages/Splash/Splash.dart';
import './pages/Login/Login.dart';
import './pages/Login/OTP.dart';
import './pages/Login/GetStarted.dart';
import './pages/Dashboard/Dashboard.dart';
import './pages/UserSettings/UserSettings.dart';
import './pages/UserSettings/UserSettingsEdit.dart';
import './styles/textThemes.dart';
import './constants.dart';
import './pages/Permission/Permission.dart';
import './pages/Circle/Circle.dart';
import './pages/CircleSettings/CircleSettings.dart';
import './pages/CircleSettings/CircleSettingsEdit.dart';
import './pages/CreateCircle/CreateCircle.dart';
import './utils/BackgroundUtils.dart' as BackgroundUtils;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  Crashlytics.instance.enableInDevMode = false;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  runApp(CaringCircle());

  BackgroundFetch.registerHeadlessTask(BackgroundUtils.callback);
}

class CaringCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage(Constants().logoAssetPath), context);
    return MaterialApp(
      title: 'Caring Circle',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF044B7F),
        textTheme: textTheme,
        accentColor: Color(0xFFCCCCCC),
      ),
      home: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (ctx, AsyncSnapshot<FirebaseUser> firebaseUserSnapshot) {
          if (firebaseUserSnapshot.connectionState == ConnectionState.done) {
            if (firebaseUserSnapshot.data != null) {
              Constants().currentUserId = firebaseUserSnapshot.data.uid;
              return FutureBuilder<DocumentSnapshot>(
                future: Firestore.instance
                    .collection(Constants().firestoreUsersCollection)
                    .document(Constants().currentUserId)
                    .get(),
                builder: (context, documentSnapshot) {
                  if (documentSnapshot.connectionState ==
                      ConnectionState.done) {
                    return documentSnapshot.data.data == null
                        ? GetStarted()
                        : Permission();
                  }
                  return Splash();
                },
              );
            } else {
              return Login();
            }
          }
          return Splash();
        },
      ),
      routes: {
        Splash.routeName: (ctx) => Splash(),
        Login.routeName: (ctx) => Login(),
        OTP.routeName: (ctx) => OTP(),
        Permission.routeName: (ctx) => Permission(),
        GetStarted.routeName: (ctx) => GetStarted(),
        Dashboard.routeName: (ctx) => Dashboard(),
        UserSettings.routeName: (ctx) => UserSettings(),
        UserSettingsEdit.routeName: (ctx) => UserSettingsEdit(),
        Circle.routeName: (ctx) => Circle(),
        CircleSettings.routeName: (ctx) => CircleSettings(),
        CircleSettingsEdit.routeName: (ctx) => CircleSettingsEdit(),
        CreateCircle.routeName: (ctx) => CreateCircle(),
      },
    );
  }
}
