import 'package:flutter/material.dart';

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
          Text(this.data, style: Theme.of(context).textTheme.display3),
          this.showRightButton
              ? Icon(Icons.add, color: Colors.white, size: 28)
              : Container(),
        ],
      ),
    );
  }
}
