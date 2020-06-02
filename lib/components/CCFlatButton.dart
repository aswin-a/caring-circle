import 'package:flutter/material.dart';

class CCFlatButton extends StatelessWidget {
  final String text;
  final Function onPressed;
  final bool showBackIcon;
  final bool darkTextColor;

  CCFlatButton({
    this.text = 'Button',
    @required this.onPressed,
    this.showBackIcon = false,
    this.darkTextColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: 0,
      child: FlatButton(
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Positioned(
              left: -10,
              child: this.showBackIcon
                  ? Icon(
                      Icons.chevron_left,
                      size: 35,
                      color: this.darkTextColor ? Colors.black54 : Colors.white,
                    )
                  : Container(),
            ),
            Padding(
              padding: EdgeInsets.only(left: this.showBackIcon ? 20 : 0),
              child: Text(
                this.text,
                style: this.darkTextColor
                    ? Theme.of(context).textTheme.display1.copyWith(
                        color: Colors.black54, fontWeight: FontWeight.w500)
                    : Theme.of(context).textTheme.display1,
              ),
            ),
          ],
        ),
        onPressed: this.onPressed,
      ),
    );
  }
}
