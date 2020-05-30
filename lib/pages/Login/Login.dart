import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './OTP.dart';
import './utils.dart' as utils;
import '../../components/Alert.dart';
import '../../utils/GeofencingUtils.dart';

class Login extends StatelessWidget {
  static const routeName = '/login';
  static const pageTitle = 'Login';

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        minimum: EdgeInsets.symmetric(horizontal: 15),
        child: PhoneNumber(),
      ),
    );
  }
}

class PhoneNumber extends StatefulWidget {
  @override
  _PhoneNumberState createState() => _PhoneNumberState();
}

class _PhoneNumberState extends State<PhoneNumber> {
  @override
  void initState() async {
    await removeHomeGeofence();
    await removeOfficeGeofence();
    super.initState();
  }

  @override
  deactivate() {
    this.isLoading = false;
    super.deactivate();
  }

  @override
  dispose() {
    this.phoneNumberController.dispose();
    super.dispose();
  }

  final phoneNumberController = TextEditingController();
  bool isLoading = false;
  bool isValid = false;

  String get phoneNumber => '+91${this.phoneNumberController.text.trim()}';

  void onTapContinue(BuildContext context) {
    void _onVerificationCompleted(AuthCredential authCredential) {
      this.setState(() {
        this.isLoading = false;
      });

      FirebaseAuth.instance
          .signInWithCredential(authCredential)
          .then((AuthResult authResult) {
        utils.onSignInSuccess(context, authResult);
      }).catchError((error) {
        showAlert(context, 'Oops !!!', 'No Problem',
            description: 'Something went wrong. Please try joining again.');
      });
    }

    void _onVerificationFailed(AuthException authException) {
      this.setState(() {
        this.isLoading = false;
      });

      showAlert(context, 'Oops !!!', 'No Problem',
          description: 'Something went wrong. Please try joining again.');
    }

    void _onCodeSent(String verificationId, [int forceResendingToken]) {
      Navigator.of(context).pushNamed(OTP.routeName, arguments: {
        'fromPage': '${Login.pageTitle}',
        'phoneNumber': this.phoneNumber,
        'verificationId': verificationId,
        'forceResendingToken': forceResendingToken
      }).then((_) => this.setState(() {
            this.isLoading = false;
          }));
    }

    FocusScope.of(context).unfocus();

    this.setState(() {
      this.isLoading = true;
    });

    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: this.phoneNumber,
      timeout: Duration(milliseconds: 0),
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: null,
    );
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
          SizedBox(height: 88),
          Text('Join the', style: Theme.of(context).textTheme.display4),
          Text('Caring Circle.', style: Theme.of(context).textTheme.display4),
          SizedBox(height: 10),
          Text(
            'Enter your phone number to continue.',
            style: Theme.of(context).textTheme.display2,
          ),
          SizedBox(height: 40),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.7,
                child: TextField(
                  enabled: !this.isLoading,
                  controller: this.phoneNumberController,
                  onSubmitted: this.isValid
                      ? (_) => this.onTapContinue(context)
                      : (_) => FocusScope.of(context).nextFocus(),
                  onChanged: (value) {
                    if (value.length < 10 && this.isValid) {
                      this.setState(() {
                        this.isValid = false;
                      });
                    } else if (value.length == 10 && !this.isValid) {
                      this.setState(() {
                        this.isValid = true;
                      });
                    }
                  },
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.3),
                    hintText: 'Phone Number',
                    hintStyle: Theme.of(context).textTheme.display1,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Center(
                        widthFactor: 0,
                        child: Text(
                          '+91',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.display3,
                        ),
                      ),
                    ),
                  ),
                  showCursor: true,
                  style: Theme.of(context)
                      .textTheme
                      .display3
                      .copyWith(letterSpacing: 3),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [LengthLimitingTextInputFormatter(10)],
                  autofocus: true,
                  textAlign: TextAlign.center,
                ),
              ),
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
