import 'package:flutter/material.dart';
import './CCFlatButton.dart';

class TitleBar extends StatelessWidget {
  final String title;
  final bool showAvatar;
  final ImageProvider avatarImageProvider;
  final Function avatarOnTapFn;
  final bool showLeftButton;
  final bool showLeftChevron;
  final String leftButtonTitle;
  final Function leftButtonOnTapFn;
  final bool showRightButton;
  final String rightButtonTitle;
  final Function rightButtonOnTapFn;

  TitleBar(
    this.title, {
    this.showAvatar = false,
    this.avatarImageProvider,
    this.avatarOnTapFn,
    this.showLeftButton = false,
    this.showLeftChevron = false,
    this.leftButtonTitle = 'Back',
    this.leftButtonOnTapFn,
    this.showRightButton = false,
    this.rightButtonTitle = 'Button',
    this.rightButtonOnTapFn,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                this.showLeftButton
                    ? CCFlatButton(
                        text: this.leftButtonTitle,
                        onPressed: () => this.leftButtonOnTapFn != null
                            ? this.leftButtonOnTapFn()
                            : null,
                        showBackIcon: this.showLeftChevron,
                      )
                    : Container(),
                this.showRightButton
                    ? CCFlatButton(
                        text: this.rightButtonTitle,
                        onPressed: () => this.leftButtonOnTapFn != null
                            ? this.rightButtonOnTapFn()
                            : null,
                      )
                    : Container()
              ],
            ),
          ),
          Container(
            height: 44,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  this.title,
                  style: Theme.of(context).textTheme.title,
                ),
                this.showAvatar
                    ? InkWell(
                        highlightColor: Colors.transparent,
                        onTap: this.avatarOnTapFn,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            backgroundImage: this.avatarImageProvider,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
