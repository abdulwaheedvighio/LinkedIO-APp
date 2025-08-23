import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart'; // ✅ Add this import

class AppToast {
  AppToast._(); // private constructor

  static void success(String message) {
    _showToast(message, Colors.green);
  }

  static void error(String message) {
    _showToast(message, Colors.red);
  }

  static void info(String message) {
    _showToast(message, Colors.blue);
  }

  static void _showToast(String message, Color bgColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM, // ✅ Works now
      backgroundColor: bgColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
