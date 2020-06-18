import 'package:flutter/material.dart';

class NameTextField extends StatelessWidget {
  final String initialValue;
  final void Function(String) onNameChanged;

  NameTextField({this.initialValue, this.onNameChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          child: TextFormField(
            initialValue: this.initialValue,
            onChanged: this.onNameChanged,
            cursorColor: Colors.white,
            decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white.withOpacity(0.3),
                hintText: 'Name*',
                hintStyle: Theme.of(context).textTheme.bodyText2),
            showCursor: true,
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
            textCapitalization: TextCapitalization.words,
          ),
        ),
      ),
    );
  }
}
