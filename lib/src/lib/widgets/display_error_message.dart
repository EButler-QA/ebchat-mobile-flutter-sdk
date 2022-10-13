import 'package:ebchat/src/lib/config/config.dart';
import 'package:flutter/material.dart';

class DisplayErrorMessage extends StatelessWidget {
  const DisplayErrorMessage({Key? key, this.error}) : super(key: key);

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        getTranslated("Oh no, something went wrong."),
      ),
    );
  }
}
