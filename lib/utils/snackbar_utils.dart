import 'package:flutter/material.dart';

SnackBar appSnackBar(
  String message, {
  Duration? duration,
  SnackBarAction? action,
}) {
  return SnackBar(
    content: Center(
      widthFactor: double.infinity,
      child: Text(
        message,
        textAlign: TextAlign.center,
      ),
    ),
    duration: duration ?? const Duration(seconds: 4),
    action: action,
  );
}

void showAppSnackBar(
  BuildContext context,
  String message, {
  Duration? duration,
  SnackBarAction? action,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    appSnackBar(message, duration: duration, action: action),
  );
}
