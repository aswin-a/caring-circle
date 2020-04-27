import 'package:flutter/material.dart';
import '../styles/textStyles.dart' as TextStyles;

class SubtitleBar extends StatelessWidget {
  final String data;
  final bool showRightButton;

  SubtitleBar(this.data, {this.showRightButton = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(this.data, style: TextStyles.subtitleStyle),
          Icon(Icons.add, color: Colors.white, size: 28),
        ],
      ),
    );
  }
}
