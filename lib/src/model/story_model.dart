
import 'package:link_io/src/model/user_model.dart';

class StoryModel {
  final String id;
  final UserModel? user; // Story posted by user
  final String mediaUrl;
  final String mediaType;
  final String caption;
  final List<StoryViewer> viewers;
  final DateTime createdAt;
  final DateTime updatedAt;

  StoryModel({
    required this.id,
    this.user,
    required this.mediaUrl,
    required this.mediaType,
    required this.caption,
    required this.viewers,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(
      id: json['_id'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      mediaUrl: json['mediaUrl'] ?? '',
      mediaType: json['mediaType'] ?? 'image',
      caption: json['caption'] ?? '',
      viewers: (json['viewers'] as List<dynamic>? ?? [])
          .map((v) => StoryViewer.fromJson(v))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "user": user?.toJson(),
      "mediaUrl": mediaUrl,
      "mediaType": mediaType,
      "caption": caption,
      "viewers": viewers.map((v) => v.toJson()).toList(),
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}

class StoryViewer {
  final String? userId;
  final DateTime viewedAt;

  StoryViewer({
    this.userId,
    required this.viewedAt,
  });

  factory StoryViewer.fromJson(Map<String, dynamic> json) {
    return StoryViewer(
      userId: json['user'],
      viewedAt: DateTime.parse(json['viewedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user": userId,
      "viewedAt": viewedAt.toIso8601String(),
    };
  }
}
