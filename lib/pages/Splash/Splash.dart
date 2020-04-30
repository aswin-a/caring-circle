import 'package:flutter/material.dart';

import '../../constants.dart';

class Splash extends StatelessWidget {
  static const routeName = '/splash';
  static const pageTitle = 'Splash';

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        minimum: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              Constants().logoAssetPath,
              height: 100,
            ),
            Text(
              'Caring Circle',
              style: Theme.of(context).textTheme.display4,
            )
          ],
        ),
      ),
    );
  }
}
