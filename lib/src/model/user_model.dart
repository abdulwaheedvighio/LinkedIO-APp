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

  // Extra fields
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
  final List<dynamic> notifications; // notifications ka structure alag banega
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};

    return UserModel(
      token: json['token'] ?? '',
      id: user['_id'] ?? '',
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
      notifications: List<dynamic>.from(user['notifications'] ?? []),
      createdAt: user['createdAt'] != null ? DateTime.parse(user['createdAt']) : null,
      updatedAt: user['updatedAt'] != null ? DateTime.parse(user['updatedAt']) : null,
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
      'notifications': notifications,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
