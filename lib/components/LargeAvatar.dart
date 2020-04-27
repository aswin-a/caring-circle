import 'package:flutter/material.dart';

import '../styles/textStyles.dart' as TextStyles;

class LargeAvatar extends StatelessWidget {
  final bool editMode;
  final TextEditingController nameController;

  LargeAvatar({@required this.nameController, this.editMode = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 66,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 62,
                  backgroundColor: Colors.transparent,
                  backgroundImage:
                      AssetImage('assets/images/defaultAvatarLarge.png'),
                ),
              ),
              this.editMode
                  ? Positioned(
                      top: 110,
                      left: 52,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Container(
                          color: Colors.black.withOpacity(0.7),
                          padding:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                          child: Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              child: TextField(
                controller: this.nameController,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: this.editMode,
                  fillColor: Colors.white.withOpacity(0.3),
                ),
                showCursor: true,
                style: TextStyles.subtitleStyle,
                textAlign: TextAlign.center,
                enabled: this.editMode,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
