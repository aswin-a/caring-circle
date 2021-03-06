import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../components/CCFlatButton.dart';
import '../../components/Alert.dart';
import './utils.dart' as utils;

class OTP extends StatelessWidget {
  static const routeName = '/otp';
  static const pageTitle = 'OTP';

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.canvas,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        minimum: EdgeInsets.symmetric(horizontal: 15),
        child: OTPContent(),
      ),
    );
  }
}

class OTPContent extends StatefulWidget {
  @override
  _OTPContentState createState() => _OTPContentState();
}

class _OTPContentState extends State<OTPContent> {
  bool isLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  void onCompleted(String verificationId, String otp) {
    this.setState(() {
      this.isLoading = true;
    });

    FirebaseAuth.instance
        .signInWithCredential(PhoneAuthProvider.getCredential(
            verificationId: verificationId, smsCode: otp))
        .then((AuthResult authResult) {
      utils.onSignInSuccess(context, authResult);
    }).catchError((error) {
      if (error.code == 'ERROR_INVALID_VERIFICATION_CODE') {
        showAlert(context, 'Incorrect OTP', 'Try Again',
            description:
                'Please make sure you have entered the 6 digit OTP sent to your phone number.');
      } else {
        showAlert(context, 'Oops !!!', 'No Problem',
            description:
                'Something went wrong. Please try entering the OTP again.');
      }
      this.setState(() {
        this.isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeArguments = ModalRoute.of(context).settings.arguments as Map;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 44),
          Container(
            height: 44,
            child: CCFlatButton(
              text: 'Change Number',
              onPressed: () => Navigator.of(context).pop(),
              showBackIcon: true,
            ),
          ),
          Text('Security Check.', style: Theme.of(context).textTheme.headline4),
          SizedBox(height: 10),
          Wrap(
            children: <Widget>[
              Text(
                'Enter the OTP sent to ',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              Text(
                '${routeArguments['phoneNumber']}.',
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ],
          ),
          SizedBox(height: 40),
          PinCodeTextField(
            length: 6,
            onChanged: (_) {},
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            obsecureText: false,
            animationType: AnimationType.fade,
            shape: PinCodeFieldShape.box,
            animationDuration: Duration(milliseconds: 300),
            borderRadius: BorderRadius.circular(10),
            autoFocus: true,
            borderWidth: 2,
            backgroundColor: Colors.transparent,
            enableActiveFill: true,
            selectedColor: Colors.white,
            activeColor: Colors.transparent,
            inactiveColor: Colors.transparent,
            selectedFillColor: Colors.white.withOpacity(0.3),
            activeFillColor: Colors.white.withOpacity(0.3),
            inactiveFillColor: Colors.white.withOpacity(0.3),
            textStyle: Theme.of(context).textTheme.headline6,
            textInputType: TextInputType.number,
            dialogTitle: 'Paste OTP?',
            dialogContent: '                          ',
            onCompleted: (otp) =>
                this.onCompleted(routeArguments['verificationId'], otp),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(bottom: this.isLoading ? 20 : 10),
              child: this.isLoading
                  ? CircularProgressIndicator(
                      backgroundColor: Colors.white,
                    )
                  : Container(),
            ),
          ),
        ],
      ),
    );
  }
}
