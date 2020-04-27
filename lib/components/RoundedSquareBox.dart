import 'package:flutter/material.dart';
import '../styles/textStyles.dart' as TextStyles;

class RoundedSquareBox extends StatelessWidget {
  final String title;
  final String value;
  final String caption;

  RoundedSquareBox(this.title, this.value, this.caption);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      child: Container(
        height: 88,
        width: 88,
        color: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text(this.title, style: TextStyles.squareBoxTitleStyle),
            Text(this.value, style: TextStyles.squareBoxValueStyle),
            Text(this.caption, style: TextStyles.squareBoxCaptionStyle),
          ],
        ),
      ),
    );
  }
}
