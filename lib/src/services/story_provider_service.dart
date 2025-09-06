import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:link_io/src/provider/user_detail_provider.dart';
import 'package:link_io/src/model/story_model.dart';

class StoryProviderService with ChangeNotifier {
  final String _baseUrl = "http://10.0.2.2:8000/api/stories";

  bool _isLoading = false;
  String? _errorMessage;
  List<StoryModel> _stories = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<StoryModel> get stories => _stories;

  // ================= Add Story =================
  Future<bool> addStory({
    required File file,
    required String caption,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      final userDetailProvider =
      Provider.of<UserDetailProvider>(context, listen: false);
      final token = userDetailProvider.currentUser!.token;

      var request = http.MultipartRequest(
        "POST",
        Uri.parse("$_baseUrl/story/add"),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['caption'] = caption;

      // ✅ Backend multer expects "media" not "file"
// ✅ sahi
      request.files.add(await http.MultipartFile.fromPath("file", file.path));

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        final data = jsonDecode(resBody);

        if (data is Map<String, dynamic> && data["story"] != null) {
          final newStory = StoryModel.fromJson(data["story"]);
          _stories.insert(0, newStory); // ✅ latest story on top
          _errorMessage = null;
          notifyListeners();
          return true;
        } else {
          _setError("Unexpected response format: $resBody");

          return false;
        }
      } else {
        _setError("Upload failed: $resBody");
        print("Upload failed: $resBody");
        return false;
      }
    } catch (error) {
      _setError("AddStory Error: $error");
      return false;
    } finally {
      _setLoading(false);
    }
  }


  // ================= Get Stories =================
  Future<void> getStories(BuildContext context) async {
    _setLoading(true);
    try {
      final userDetailProvider =
      Provider.of<UserDetailProvider>(context, listen: false);
      final token = userDetailProvider.currentUser!.token;

      final response = await http.get(
        Uri.parse("$_baseUrl/all"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> && data["stories"] is List) {
          _stories = (data["stories"] as List)
              .map((e) => StoryModel.fromJson(e))
              .toList();
          _errorMessage = null;
        } else {
          _setError("Unexpected response: ${response.body}");
          print("Unexpected response: ${response.body}");
        }
      } else {
        _setError("Failed to load stories: ${response.body}");
        print("Failed to load stories: ${response.body}");
      }
    } catch (error) {
      _setError("GetStories Error: $error");
      print("GetStories Error: $error");
    } finally {
      _setLoading(false);
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
