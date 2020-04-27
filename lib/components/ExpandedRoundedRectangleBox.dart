import 'package:flutter/material.dart';
import 'TodayChart.dart';
import '../styles/textStyles.dart' as TextStyles;

class ExpandedRoundedRectangleBox extends StatelessWidget {
  final String title;
  final String caption;

  ExpandedRoundedRectangleBox(this.title, this.caption);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        child: Container(
          height: 88,
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(this.title, style: TextStyles.squareBoxTitleStyle),
              Expanded(
                child: SizedBox.expand(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                    child: TodayChart(),
                  ),
                ),
              ),
              Text(this.caption, style: TextStyles.squareBoxCaptionStyle),
            ],
          ),
        ),
      ),
    );
  }
}
