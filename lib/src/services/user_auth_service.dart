import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:link_io/src/model/user_model.dart';
import 'package:link_io/src/provider/user_detail_provider.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:provider/provider.dart';

enum FollowStatus { self, following, pending, none }

FollowStatus followStatusFromString(String s) {
  switch (s) {
    case "self":
      return FollowStatus.self;
    case "following":
      return FollowStatus.following;
    case "pending":
      return FollowStatus.pending;
    default:
      return FollowStatus.none;
  }
}

class UserAuthService with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // ---------------- Register ----------------
  Future<Map<String, dynamic>> userRegister({
    required String fullName,
    required String userName,
    required String email,
    required String password,
    required String phone,
    required String gender,
    required File profileImage,
    required String accountType,
  }) async {
    setLoading(true);
    try {
      final uri = Uri.parse('http://10.0.2.2:8000/api/users/register');
      var request = http.MultipartRequest('POST', uri);

      request.fields.addAll({
        'fullName': fullName,
        'userName': userName,
        'email': email,
        'password': password,
        'phone': phone,
        'gender': gender,
        'accountType': accountType,
      });

      final mimeTypeData = lookupMimeType(profileImage.path)!.split('/');
      request.files.add(await http.MultipartFile.fromPath(
        'profileImage',
        profileImage.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      setLoading(false);

      if (response.statusCode == 201) {
        return {
          "success": true,
          "message": responseData['message'],
          "data": responseData['user'],
          "token": responseData['token'],
        };
      } else {
        return {
          "success": false,
          "message": responseData['message'] ?? 'Registration failed',
        };
      }
    } on SocketException {
      setLoading(false);
      return {"success": false, "message": "No Internet Connection"};
    } catch (error) {
      setLoading(false);
      return {"success": false, "message": error.toString()};
    }
  }

  // ---------------- Login ----------------
  Future<Map<String, dynamic>> userLogin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse('http://10.0.2.2:8000/api/users/login');
      final userDetailProvider =
      Provider.of<UserDetailProvider>(context, listen: false);

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final userJson = data['user'];

          final user = UserModel(
            token: data['token'] ?? '',
            id: userJson['_id'] ?? '',
            fullName: userJson['fullName'] ?? '',
            username: userJson['username'] ?? '',
            email: userJson['email'] ?? '',
            phone: userJson['phone'] ?? '',
            gender: userJson['gender'] ?? '',
            profileImage: userJson['profileImage'] ?? '',
            accountType: userJson['accountType'] ?? 'Student',
            education: userJson['education'] ?? '',
            skills: List<String>.from(userJson['skills'] ?? []),
            jobTitle: userJson['jobTitle'] ?? '',
            bio: userJson['bio'] ?? '',
            location: userJson['location'] ?? '',
            links: List<String>.from(userJson['links'] ?? []),
            privacyPublic: userJson['privacyPublic'] ?? true,
            followers: List<String>.from(userJson['followers'] ?? []),
            following: List<String>.from(userJson['following'] ?? []),
          );

          await userDetailProvider.saveUserData(user, token: data['token'] ?? '');

          return {
            "success": true,
            "message": data['message'] ?? "Login successful",
            "token": data['token'],
            "user": user,
          };
        } else {
          return {"success": false, "message": data['message'] ?? "Login failed"};
        }
      } else {
        final data = jsonDecode(response.body);
        return {"success": false, "message": data['message'] ?? "Login failed"};
      }
    } catch (error) {
      return {"success": false, "message": error.toString()};
    }
  }

  // ---------------- Send Follow Request ----------------
  Future<Map<String, dynamic>> sendFollowRequest({
    required String targetUserId,
    required BuildContext context,
  }) async {
    setLoading(true);
    try {
      final userDetailProvider =
      Provider.of<UserDetailProvider>(context, listen: false);
      final token = userDetailProvider.currentUser!.token;
      final url = Uri.parse("http://10.0.2.2:8000/api/users/users/follow");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"targetUserId": targetUserId}),
      );

      final data = jsonDecode(response.body);
      setLoading(false);

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          "success": true,
          "message": data['message'] ?? "Follow request sent",
        };
      } else {
        return {
          "success": false,
          "message": data['message'] ?? "Failed to send follow request",
        };
      }
    } catch (error) {
      setLoading(false);
      return {"success": false, "message": error.toString()};
    }
  }

  // ---------------- Follow Status ----------------
  Future<FollowStatus> getFollowStatus({
    required String targetUserId,
    required BuildContext context,
  }) async {
    try {
      final userDetailProvider =
      Provider.of<UserDetailProvider>(context, listen: false);
      final token = userDetailProvider.currentUser?.token ?? '';
      final url = Uri.parse(
          "http://10.0.2.2:8000/api/users/users/$targetUserId/follow-status");

      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return followStatusFromString(data['status'] ?? "none");
      }
      return FollowStatus.none;
    } catch (_) {
      return FollowStatus.none;
    }
  }

  // ---------------- Respond to Follow Request ----------------
  Future<Map<String, dynamic>> respondFollowRequest({
    required String notificationId,
    required String action, // "accept" | "reject"
    required BuildContext context,
  }) async {
    setLoading(true);
    try {
      final userDetailProvider =
      Provider.of<UserDetailProvider>(context, listen: false);
      final token = userDetailProvider.currentUser?.token ?? '';
      final url =
      Uri.parse("http://10.0.2.2:8000/api/users/users/follow/respond");

      final response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer $token",
          },
          body: jsonEncode({
            "notificationId": notificationId,
            "action": action,
          }));

      final data = jsonDecode(response.body);
      setLoading(false);
      final msg = data['message'] ?? data['msg'] ?? 'Success';
      return {
        "success": response.statusCode == 200,
        "message": msg,
      };
    } catch (e) {
      setLoading(false);
      return {"success": false, "message": e.toString()};
    }
  }

  // ---------------- Fetch Notifications ----------------
  Future<List<Map<String, dynamic>>> fetchNotifications(
      BuildContext context) async {
    try {
      final userDetailProvider =
      Provider.of<UserDetailProvider>(context, listen: false);
      final token = userDetailProvider.currentUser?.token ?? '';
      final url = Uri.parse("http://10.0.2.2:8000/api/users/notifications");

      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      });

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['notifications'] ?? []);
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
