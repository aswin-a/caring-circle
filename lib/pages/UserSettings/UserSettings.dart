import 'package:caring_circle/providers/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../styles/TextStyles.dart' as TextStyles;
import '../../components/TitleBar.dart';
import '../../components/LargeAvatar.dart';

class UserSettings extends StatelessWidget {
  static const routeName = '/user-settings';
  static const pageTitle = 'User Settings';

  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context).settings.arguments as Map;
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 15),
        child: _UserSettingsContent(routeArgs: routeArgs),
      ),
    );
  }
}

class _UserSettingsContent extends StatefulWidget {
  final routeArgs;

  _UserSettingsContent({@required this.routeArgs});

  @override
  _UserSettingsContentState createState() => _UserSettingsContentState();
}

class _UserSettingsContentState extends State<_UserSettingsContent> {
  var editMode = false;
  final nameController = TextEditingController(text: '');

  void leftButtonOnTap() {
    if (this.editMode) {
      setState(() {
        this.editMode = false;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void rightButtonOnTap(User user) {
    if (this.editMode) {
      setState(() {
        this.editMode = false;
      });
      user.updateName(this.nameController.text);
    } else {
      setState(() {
        this.editMode = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    this.nameController.text = user.name;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TitleBar(
          UserSettings.pageTitle,
          showLeftButton: true,
          showLeftChevron: !this.editMode,
          leftButtonTitle:
              this.editMode ? 'Cancel' : widget.routeArgs['fromPage'],
          leftButtonOnTapFn: this.leftButtonOnTap,
          showRightButton: true,
          rightButtonTitle: this.editMode ? 'Save' : 'Edit',
          rightButtonOnTapFn: () => (this.rightButtonOnTap(user)),
        ),
        LargeAvatar(
          nameController: this.nameController,
          editMode: this.editMode,
        ),
        Expanded(
          child: Container(
            alignment: Alignment.bottomCenter,
            padding: EdgeInsets.only(bottom: 20),
            child: !this.editMode
                ? FlatButton(
                    onPressed: () {},
                    child: Text(
                      'Logout',
                      style: TextStyles.flatButtonStyle,
                    ),
                  )
                : Container(),
          ),
        )
      ],
    );
  }
}
