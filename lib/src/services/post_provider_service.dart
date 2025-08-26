import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:link_io/src/model/post_model.dart';
import 'package:link_io/src/provider/user_detail_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class PostProviderService with ChangeNotifier {
  final String _baseUrl = "http://10.0.2.2:8000/api/posts";

  bool _isLoading = false;
  String? _errorMessage;

  List<PostModel> _posts = [];     // ✅ All posts (HomePage)
  List<PostModel> _userPosts = []; // ✅ Specific user posts (FriendProfile)

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PostModel> get posts => _posts;
  List<PostModel> get userPosts => _userPosts;

  // ================= Upload Post =================
  Future<bool> uploadPost({
    required String caption,
    required List<String> hashtags,
    File? image,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      final userDetailProvider =
      Provider.of<UserDetailProvider>(context, listen: false);
      final token = userDetailProvider.currentUser!.token;

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$_baseUrl/upload-post"),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['caption'] = caption;
      request.fields['hashtags'] = hashtags.join(',');

      if (image != null) {
        request.files
            .add(await http.MultipartFile.fromPath("image", image.path));
      }

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        _setLoading(false);
        return true;
      } else {
        _setError("Upload failed: $resBody");
        return false;
      }
    } catch (error) {
      _setError(error.toString());
      return false;
    }
  }

  // ================= Get All Posts =================
  Future<void> getPosts({required BuildContext context}) async {
    _setLoading(true);
    try {
      final userDetailProvider =
      Provider.of<UserDetailProvider>(context, listen: false);
      final token = userDetailProvider.currentUser!.token;

      final response = await http.get(
        Uri.parse("$_baseUrl/get-posts"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List) {
          _posts = data
              .map<PostModel>((postJson) => PostModel.fromJson(postJson))
              .toList();
        } else {
          _posts = [];
        }

        _setLoading(false);
      } else {
        _setError("Failed to fetch posts: ${response.body}");
      }
    } catch (error) {
      _setError(error.toString());
      print("❌ Error fetching posts: $error");
    }
  }

  // ================= Get Posts by User =================
  Future<void> getPostsByUserId({
    required String userId,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      final userDetailProvider =
      Provider.of<UserDetailProvider>(context, listen: false);
      final token = userDetailProvider.currentUser!.token;

      final response = await http.get(
        Uri.parse("$_baseUrl/user/$userId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _userPosts = (data as List)
            .map<PostModel>((json) => PostModel.fromJson(json))
            .toList();
        _setLoading(false);
      } else {
        _setError("Failed to fetch user posts");
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ================= Like Post =================
  Future<bool> likePost(String postId, BuildContext context) async {
    try {
      final userDetailProvider =
      Provider.of<UserDetailProvider>(context, listen: false);
      final token = userDetailProvider.currentUser!.token;

      final response = await http.put(
        Uri.parse("$_baseUrl/like-post/$postId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data["success"] == true) {
        print("✅ Backend response: ${data["message"]}");

        // 🔹 Update local post with backend response
        final updatedPost = PostModel.fromJson(data["post"]);
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          _posts[index] = updatedPost;
          notifyListeners();
        }

        return true;
      } else {
        _setError("Failed to like post: ${response.body}");
        return false;
      }
    } catch (error) {
      _setError(error.toString());
      return false;
    }
  }

  // ================= Add Comment =================
  Future<void> addComment(
      String postId, String text, BuildContext context) async {
    try {
      final userDetailProvider =
      Provider.of<UserDetailProvider>(context, listen: false);
      final token = userDetailProvider.currentUser?.token;

      if (token == null) {
        _setError("User not logged in.");
        return;
      }

      final response = await http.post(
        Uri.parse("$_baseUrl/comment-post/$postId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"text": text}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data["success"] == true && data["comments"] != null) {
          final index = _posts.indexWhere((p) => p.id == postId);
          if (index != -1) {
            _posts[index].comments.clear();
            _posts[index].comments.addAll(
              (data["comments"] as List).map<CommentModel>((c) {
                return CommentModel(
                  id: c["_id"] ?? "",
                  text: c["text"] ?? "",
                  user: c["user"] != null
                      ? UserModel.fromJson(c["user"])
                      : null,
                  createdAt: DateTime.tryParse(c["createdAt"] ?? "") ??
                      DateTime.now(),
                );
              }),
            );
            notifyListeners();
          }
        } else {
          _setError(data["message"] ?? "Failed to add comment.");
        }
      } else {
        _setError("Failed to add comment: ${response.statusCode}");
      }
    } catch (error) {
      _setError("Unexpected error: $error");
    }
  }

  // ================= Helpers =================
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}
