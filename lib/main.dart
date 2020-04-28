import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './pages/Splash/Splash.dart';
import './pages/Login/Login.dart';
import './pages/Login/OTP.dart';
import './pages/Dashboard/Dashboard.dart';
import './pages/UserSettings/UserSettings.dart';
import './providers/User.dart';
import './styles/textThemes.dart';

void main() => runApp(CaringCircle());

class CaringCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => User()),
      ],
      child: MaterialApp(
        title: 'Caring Circle',
        theme: ThemeData(
          scaffoldBackgroundColor: Color(0xFF0098BC),
          textTheme: textTheme,
        ),
        home: FutureBuilder(
          future: FirebaseAuth.instance.currentUser(),
          builder: (ctx, AsyncSnapshot<FirebaseUser> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              print(snapshot.data);
              if (snapshot.data != null) {
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
          Dashboard.routeName: (ctx) => Dashboard(),
          UserSettings.routeName: (ctx) => UserSettings(),
        },
      ),
    );
  }
}
