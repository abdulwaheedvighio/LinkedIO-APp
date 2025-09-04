class PostModel {
  final String id;
  final UserModel user;
  final String caption;
  final List<String> hashtags;
  final MediaModel? media; // 👈 image/video both
  final List<LikeModel> likes;
  final List<CommentModel> comments;
  final List<NotificationModel> notifications;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.id,
    required this.user,
    required this.caption,
    required this.hashtags,
    this.media,
    required this.likes,
    required this.comments,
    required this.notifications,
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
      media: json["media"] != null ? MediaModel.fromJson(json["media"]) : null,
      likes: (json["likes"] as List<dynamic>?)
          ?.map((l) => LikeModel.fromJson(l))
          .toList() ??
          [],
      comments: (json["comments"] as List<dynamic>?)
          ?.map((c) => CommentModel.fromJson(c))
          .toList() ??
          [],
      notifications: (json["notifications"] as List<dynamic>?)
          ?.map((n) => NotificationModel.fromJson(n))
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
      "media": media?.toJson(),
      "likes": likes.map((l) => l.toJson()).toList(),
      "comments": comments.map((c) => c.toJson()).toList(),
      "notifications": notifications.map((n) => n.toJson()).toList(),
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

/// 🔥 Media model for image/video
class MediaModel {
  final String url;
  final String type; // "image" or "video"

  MediaModel({required this.url, required this.type});

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      url: json["url"] ?? "",
      type: json["type"] ?? "image",
    );
  }

  Map<String, dynamic> toJson() => {
    "url": url,
    "type": type,
  };
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
      bio: json["bio"] ?? "",
      profileImage: json["profileImage"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "fullName": fullName,
      "email": email,
      "bio": bio,
      "profileImage": profileImage,
    };
  }
}

class CommentModel {
  final String? id;
  final String? text;
  final UserModel? user;
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

class NotificationModel {
  final String id;
  final UserModel sender; // jisne notification trigger kiya
  final String type; // follow / like / comment
  final String? status; // sirf follow request k liye
  final String? postId; // like/comment kis post par hua
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.sender,
    required this.type,
    this.status,
    this.postId,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json["_id"] ?? "",
      sender: json["sender"] != null
          ? UserModel.fromJson(json["sender"])
          : UserModel(id: "", fullName: "", email: "", profileImage: ""),
      type: json["type"] ?? "",
      status: json["status"], // only for follow
      postId: json["postId"], // only for like/comment
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "sender": sender.toJson(),
      "type": type,
      "status": status,
      "postId": postId,
      "createdAt": createdAt.toIso8601String(),
    };
  }
}

