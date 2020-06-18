import 'package:flutter/material.dart';

class SubtitleBar extends StatelessWidget {
  final String data;
  final bool showRightButton;
  final VoidCallback onTap;

  SubtitleBar(this.data, {this.showRightButton = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      alignment: Alignment.center,
      scale: 1.01,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15),
          color: Theme.of(context).scaffoldBackgroundColor,
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(this.data, style: Theme.of(context).textTheme.headline6),
              this.showRightButton
                  ? IconButton(
                      icon: Icon(Icons.add, color: Colors.white, size: 28),
                      onPressed: onTap,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
