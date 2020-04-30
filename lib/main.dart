import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './pages/Splash/Splash.dart';
import './pages/Login/Login.dart';
import './pages/Login/OTP.dart';
import './pages/Login/GetStarted.dart';
import './pages/Dashboard/Dashboard.dart';
import './pages/UserSettings/UserSettings.dart';
import './styles/textThemes.dart';
import './constants.dart';

void main() => runApp(CaringCircle());

class CaringCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Caring Circle',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF0098BC),
        textTheme: textTheme,
      ),
      home: FutureBuilder(
        future: FirebaseAuth.instance.currentUser(),
        builder: (ctx, AsyncSnapshot<FirebaseUser> firebaseUserSnapshot) {
          if (firebaseUserSnapshot.connectionState == ConnectionState.done) {
            if (firebaseUserSnapshot.data != null) {
              Constants().currentUserId = firebaseUserSnapshot.data.uid;
              return Dashboard();
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
        GetStarted.routeName: (ctx) => GetStarted(),
        Dashboard.routeName: (ctx) => Dashboard(),
        UserSettings.routeName: (ctx) => UserSettings(),
      },
    );
  }
}
