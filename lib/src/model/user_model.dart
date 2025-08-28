import 'package:link_io/src/model/post_model.dart';

class UserModel {
  final String token;
  final String id;
  final String fullName;
  final String username;
  final String email;
  final String phone;
  final String gender;
  final String profileImage;
  final String accountType;

  // Extra fields...
  final String education;
  final List<String> skills;
  final String jobTitle;
  final String bio;
  final String location;
  final List<String> links;
  final bool privacyPublic;
  final List<String> followers;
  final List<String> following;
  final List<String> friends;
  final List<NotificationModel> notifications; // ✅ fixed

  UserModel({
    required this.token,
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    required this.phone,
    required this.gender,
    required this.profileImage,
    required this.accountType,
    this.education = "",
    this.skills = const [],
    this.jobTitle = "",
    this.bio = "",
    this.location = "",
    this.links = const [],
    this.privacyPublic = true,
    this.followers = const [],
    this.following = const [],
    this.friends = const [],
    this.notifications = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json; // ✅ fallback

    return UserModel(
      token: json['token'] ?? '',
      id: user['_id'] ?? user['id'] ?? '',
      fullName: user['fullName'] ?? '',
      username: user['username'] ?? '',
      email: user['email'] ?? '',
      phone: user['phone'] ?? '',
      gender: user['gender'] ?? '',
      profileImage: user['profileImage'] ?? '',
      accountType: user['accountType'] ?? 'Student',
      education: user['education'] ?? '',
      skills: List<String>.from(user['skills'] ?? []),
      jobTitle: user['jobTitle'] ?? '',
      bio: user['bio'] ?? '',
      location: user['location'] ?? '',
      links: List<String>.from(user['links'] ?? []),
      privacyPublic: user['privacyPublic'] ?? true,
      followers: List<String>.from(user['followers'] ?? []),
      following: List<String>.from(user['following'] ?? []),
      friends: List<String>.from(user['friends'] ?? []),
      notifications: (user['notifications'] as List<dynamic>?)
          ?.map((n) => NotificationModel.fromJson(n))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'id': id,
      'fullName': fullName,
      'username': username,
      'email': email,
      'phone': phone,
      'gender': gender,
      'profileImage': profileImage,
      'accountType': accountType,
      'education': education,
      'skills': skills,
      'jobTitle': jobTitle,
      'bio': bio,
      'location': location,
      'links': links,
      'privacyPublic': privacyPublic,
      'followers': followers,
      'following': following,
      'friends': friends,
      'notifications': notifications.map((n) => n.toJson()).toList(),
    };
  }
}
