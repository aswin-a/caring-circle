import 'package:flutter/material.dart';

class SettingsBlock extends StatelessWidget {
  final String data;
  final Function onTap;
  final IconData leftIcon;
  final bool showRightChevron;
  final String rightTextData;

  SettingsBlock(this.data,
      {this.onTap,
      this.leftIcon,
      this.showRightChevron = false,
      this.rightTextData});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: this.onTap,
          child: Ink(
            padding: EdgeInsets.symmetric(horizontal: 10),
            height: 44,
            decoration: ShapeDecoration(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    this.leftIcon != null
                        ? Icon(leftIcon, size: 24)
                        : Container(),
                    SizedBox(width: 10),
                    Text(
                      this.data,
                      style: Theme.of(context).textTheme.body2,
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    this.rightTextData != null
                        ? Text(
                            this.rightTextData,
                            style: Theme.of(context)
                                .textTheme
                                .caption
                                .copyWith(color: Colors.black54),
                          )
                        : Container(),
                    SizedBox(width: 10),
                    this.showRightChevron
                        ? Icon(
                            Icons.chevron_right,
                            size: 24,
                          )
                        : Container(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
