import 'package:flutter/material.dart';

void showSnackBarMessage(BuildContext context, String message,
    {bool removePrevious = true}) {
  final ScaffoldMessengerState scaffoldMessenger =
      ScaffoldMessenger.of(context);

  if (removePrevious) {
    scaffoldMessenger.removeCurrentSnackBar();
  }

  scaffoldMessenger.showSnackBar(
    SnackBar(content: Text(message)),
  );
}

void hideSnackBarMessage(BuildContext context) =>
    ScaffoldMessenger.of(context)..hideCurrentSnackBar();
