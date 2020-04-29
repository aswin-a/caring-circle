import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Dashboard/Dashboard.dart';
import '../../components/LargeAvatar.dart';

class GetStarted extends StatelessWidget {
  static const routeName = '/get-started';
  static const pageTitle = 'Get Started';

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        minimum: EdgeInsets.symmetric(horizontal: 15),
        child: GetStartedContent(),
      ),
    );
  }
}

class GetStartedContent extends StatefulWidget {
  @override
  _GetStartedContentState createState() => _GetStartedContentState();
}

class _GetStartedContentState extends State<GetStartedContent> {
  final nameController = TextEditingController();
  bool isLoading = false;
  bool isValid = false;

  void onTapContinue(BuildContext context) {
    this.setState(() {
      this.isLoading = true;
    });

    FirebaseAuth.instance.currentUser().then((firebaseUser) {
      Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .setData({'name': this.nameController.text});
    });

    Navigator.of(context).pushNamedAndRemoveUntil(
        Dashboard.routeName, (Route<dynamic> route) => false);
  }

  void onNameChanged(String name) {
    if (name.length == 0 && this.isValid) {
      this.setState(() {
        this.isValid = false;
      });
    } else if (name.length > 0 && !this.isValid) {
      this.setState(() {
        this.isValid = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 44),
          Text('Let\'s get started.',
              style: Theme.of(context).textTheme.display4),
          SizedBox(height: 10),
          Center(
            child: LargeAvatar(
              nameController: nameController,
              onNameChanged: this.onNameChanged,
              onNameSubmitted: (_) => this.onTapContinue(context),
              editMode: true,
              autoFocus: true,
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(bottom: this.isLoading ? 20 : 10),
              child: this.isLoading
                  ? CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    )
                  : FlatButton(
                      onPressed: this.isValid
                          ? () => this.onTapContinue(context)
                          : null,
                      child: Text(
                        'Continue',
                        style: this.isValid
                            ? Theme.of(context).textTheme.button
                            : Theme.of(context)
                                .textTheme
                                .button
                                .copyWith(color: Colors.white.withOpacity(0.5)),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
