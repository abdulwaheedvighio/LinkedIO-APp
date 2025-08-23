class PostModel {
  final String id;
  final UserModel user;
  final String caption;
  final List<String> hashtags;
  final String? image;
  final List<LikeModel> likes;
  final List<CommentModel> comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.user,
    required this.caption,
    required this.hashtags,
    this.image,
    required this.likes,
    required this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json["_id"] ?? "",
      user: UserModel.fromJson(json["user"] ?? {}),
      caption: json["caption"] ?? "",
      hashtags: (json["hashtags"] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      image: json["imageUrl"] ?? json["image"], // ✅ backend dono case me handle
      likes: (json["likes"] as List<dynamic>?)
          ?.map((l) => LikeModel.fromJson(l as Map<String, dynamic>))
          .toList() ??
          [],
      comments: (json["comments"] as List<dynamic>?)
          ?.map((c) => CommentModel.fromJson(c as Map<String, dynamic>))
          .toList() ??
          [],
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? "") ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "user": user.toJson(),
      "caption": caption,
      "hashtags": hashtags,
      "image": image,
      "likes": likes.map((l) => l.toJson()).toList(),
      "comments": comments.map((c) => c.toJson()).toList(),
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

class LikeModel {
  final String userId;
  final DateTime createdAt;

  LikeModel({
    required this.userId,
    required this.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    String userId;
    if (json["user"] is Map<String, dynamic>) {
      userId = json["user"]["_id"] ?? "";
    } else {
      userId = json["user"]?.toString() ?? "";
    }

    return LikeModel(
      userId: userId,
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"]) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user": userId,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? bio;
  final String? profileImage;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.bio,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"] ?? "",
      fullName: json["fullName"] ?? "",
      email: json["email"] ?? "",
      bio: json["bio"]??"",
      profileImage: json["profileImage"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "fullName": fullName,
      "email": email,
      "bio":bio,
      "profileImage": profileImage,
    };
  }
}

class CommentModel {
  final String? id;
  final String? text;
  final UserModel? user;   // ✅ user object instead of just userId
  final DateTime? createdAt;

  CommentModel({
    this.id,
    this.text,
    this.user,
    this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json["_id"] ?? "",
      text: json["text"] ?? "",
      user: json["user"] != null
          ? (json["user"] is Map<String, dynamic>
          ? UserModel.fromJson(json["user"])
          : null)
          : null,
      createdAt: json["createdAt"] != null
          ? DateTime.tryParse(json["createdAt"]) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "text": text,
      "user": user?.toJson(),
      "createdAt": createdAt?.toIso8601String(),
    };
  }
}
