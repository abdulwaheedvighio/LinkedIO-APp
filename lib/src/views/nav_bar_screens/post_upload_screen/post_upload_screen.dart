import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_io/src/core/constants/app_colors.dart';
import 'package:link_io/src/core/utils/utils.dart';
import 'package:link_io/src/provider/user_detail_provider.dart';
import 'package:link_io/src/services/post_provider_service.dart';
import 'package:link_io/src/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class PostUploadScreen extends StatefulWidget {
  const PostUploadScreen({super.key});

  @override
  State<PostUploadScreen> createState() => _PostUploadScreenState();
}

class _PostUploadScreenState extends State<PostUploadScreen> {
  final TextEditingController _captionController = TextEditingController();
  File? _selectedImage;

  // Pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Extract hashtags from caption
  List<String> _extractHashtags(String text) {
    final RegExp regex = RegExp(r"\B#\w\w+");
    return regex.allMatches(text).map((match) => match.group(0)!).toList();
  }

  Future<void> _handlePost() async {
    final caption = _captionController.text.trim();
    final hashtags = _extractHashtags(caption);

    if (caption.isEmpty && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write something or add an image")),
      );
      return;
    }

    final postProvider = Provider.of<PostProviderService>(context, listen: false);

    bool success = await postProvider.uploadPost(
      caption: caption,
      hashtags: hashtags,
      image: _selectedImage,
      context: context,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Post uploaded successfully")),
      );
      _captionController.clear();
      setState(() => _selectedImage = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: ${postProvider.errorMessage}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final postProvider = Provider.of<PostProviderService>(context);
    final userProvider = Provider.of<UserDetailProvider>(context);
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightCard,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: CustomTextWidget(
          text: "Create Post",
          fontSize: screenWidth * 0.045,
        ),
        actions: [
          TextButton(
            onPressed: postProvider.isLoading ? null : _handlePost,
            child: postProvider.isLoading
                ? const CircularProgressIndicator()
                : const Text(
              "Post",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Profile + Image picker
            Row(
              children: [
                 CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage("${userProvider.currentUser!.profileImage}"), // placeholder user
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _captionController,
                    maxLines: null,
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black),
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.photo_library_outlined),
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt_outlined),
                  onPressed: () => _pickImage(ImageSource.camera),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Image Preview
            if (_selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 10),

            // Hashtag Preview
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _captionController,
              builder: (context, value, child) {
                final hashtags = _extractHashtags(value.text);
                return hashtags.isNotEmpty
                    ? Wrap(
                  spacing: 6,
                  children: hashtags
                      .map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: isDark
                        ? Colors.blueGrey
                        : Colors.blue.shade50,
                  ))
                      .toList(),
                )
                    : const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
