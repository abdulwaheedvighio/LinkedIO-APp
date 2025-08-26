class UserModel {
  final String token; // add this
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
  final List<String> notifications;

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

    final user = json['user'] ?? {};

    return UserModel(
      token: json['token'] ?? '',
      id: json['_id'] ?? json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      profileImage: json['profileImage'] ?? '',
      accountType: json['accountType'] ?? 'Student',
      education: json['education'] ?? '',
      skills: List<String>.from(json['skills'] ?? []),
      jobTitle: json['jobTitle'] ?? '',
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      links: List<String>.from(json['links'] ?? []),
      privacyPublic: json['privacyPublic'] ?? true,
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
      friends: List<String>.from(user['friends'] ?? []),
      notifications: List<String>.from(user['notifications'] ?? []),
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
    };
  }
}