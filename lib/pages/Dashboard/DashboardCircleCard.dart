import 'package:flutter/material.dart';
import '../../styles/textStyles.dart' as TextStyles;
import '../../components/TodayChart.dart';

class DashboardCircleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 122,
        padding: EdgeInsets.all(10),
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.lightGreen,
                      radius: 19,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Circle',
                      style: TextStyles.circleCardTitleStyle,
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right,
                  size: 33,
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Today', style: TextStyles.squareBoxTitleStyle),
                        Expanded(
                          child: Center(
                              child: Text('123',
                                  style: TextStyles.squareBoxValueStyle)),
                        )
                      ],
                    ),
                    VerticalDivider(
                      thickness: 1,
                      width: 20,
                      color: Colors.grey,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Week', style: TextStyles.squareBoxTitleStyle),
                        Expanded(
                          child: Center(
                              child: Text('123',
                                  style: TextStyles.squareBoxValueStyle)),
                        )
                      ],
                    ),
                    VerticalDivider(
                      thickness: 1,
                      width: 20,
                      color: Colors.grey,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Month', style: TextStyles.squareBoxTitleStyle),
                        Expanded(
                          child: Center(
                              child: Text('123',
                                  style: TextStyles.squareBoxValueStyle)),
                        )
                      ],
                    ),
                    VerticalDivider(
                      thickness: 1,
                      width: 20,
                      color: Colors.grey,
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Today (2hr 25mins)',
                            style: TextStyles.squareBoxTitleStyle,
                          ),
                          Expanded(
                            child: SizedBox.expand(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: TodayChart(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
