import 'package:flutter/material.dart';
import '../styles/textStyles.dart' as TextStyles;

class CCFlatButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final bool showBackIcon;

  CCFlatButton(
      {this.text = 'Button',
      @required this.onPressed,
      this.showBackIcon = false});

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: 0,
      child: FlatButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            this.showBackIcon
                ? Positioned(
                    left: -10,
                    child: Icon(
                      Icons.chevron_left,
                      size: 35,
                      color: Colors.white,
                    ),
                  )
                : Container(),
            Padding(
              padding: EdgeInsets.only(left: this.showBackIcon ? 20 : 0),
              child: Text(
                this.text,
                style: TextStyles.titleFlatButtonStyle,
              ),
            ),
          ],
        ),
        onPressed: this.onPressed,
      ),
    );
  }
}
