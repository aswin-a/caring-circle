import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './pages/Dashboard/Dashboard.dart';
import './pages/UserSettings/UserSettings.dart';
import './providers/User.dart';

void main() => runApp(CaringCircle());

class CaringCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => User(isLoggedin: true),
          child: MaterialApp(
        title: 'Caring Circle',
        theme: ThemeData(scaffoldBackgroundColor: Color(0xFF0098BC)),
        routes: {
          Dashboard.routeName: (ctx) => Dashboard(),
          UserSettings.routeName: (ctx) => UserSettings(),
        },
      ),
    );
  }
}
