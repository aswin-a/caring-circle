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
      child: Center(
        child: Image.asset(
          Constants().logoAssetPath,
          height: 139,
          width: 139,
        ),
      ),
    );
  }
}
