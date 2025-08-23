import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:link_io/src/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailProvider extends ChangeNotifier {
  // ----------------------
  // User State
  // ----------------------
  bool isLoading = false;
  UserModel? currentUser;

  // ----------------------
  // SharedPreferences Keys
  // ----------------------
  static const String _userKey = "user_data";

  // ----------------------
  // Set Loading
  // ----------------------
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  // ----------------------
  // Save User Data
  // ----------------------
  Future<void> saveUserData(UserModel user, {required token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token); // save token separately


    // Assign to currentUser
    currentUser = user;

    // Save entire user object as JSON string
    await prefs.setString(_userKey, jsonEncode(user.toJson()));

    print("✅ User data saved to SharedPreferences");
    print("Token: ${user.token}");
    print("User ID: ${user.id}");
    notifyListeners();
  }

  // ----------------------
  // Load User Data
  // ----------------------
  Future<void> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_userKey);

    if (userJson != null) {
      currentUser = UserModel.fromJson(jsonDecode(userJson));
      print("✅ User data fetched from SharedPreferences");
      print("Token: ${currentUser?.token}");
      print("User ID: ${currentUser?.id}");
    } else {
      print("⚠️ No user data found in SharedPreferences");
    }

    notifyListeners();
  }

  // ----------------------
  // Clear User Data
  // ----------------------
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);

    currentUser = null;

    print("✅ User data removed from SharedPreferences");
    notifyListeners();
  }

  // ----------------------
  // Getters
  // ----------------------
  String get currentUserToken => currentUser?.token ?? '';
  String get currentUserId => currentUser?.id ?? '';
  String get currentUserEmail => currentUser?.email ?? '';
  String get currentUserName => currentUser?.username ?? '';
}
