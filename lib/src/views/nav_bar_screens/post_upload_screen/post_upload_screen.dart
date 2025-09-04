import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:link_io/src/core/constants/app_colors.dart';
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

  File? _selectedMedia;
  bool _isVideo = false;
  VideoPlayerController? _videoController;

  // 📌 Media picker
  Future<void> _pickMedia({required bool isVideo, required ImageSource source}) async {
    final picker = ImagePicker();
    final pickedFile = isVideo
        ? await picker.pickVideo(source: source, maxDuration: const Duration(minutes: 1))
        : await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedMedia = File(pickedFile.path);
        _isVideo = isVideo;
      });

      if (isVideo) {
        _videoController = VideoPlayerController.file(File(pickedFile.path))
          ..initialize().then((_) {
            setState(() {});
            _videoController!.setLooping(true);
          });
      }
    }
  }

  // Hashtag extractor
  List<String> _extractHashtags(String text) {
    final regex = RegExp(r"\B#\w\w+");
    return regex.allMatches(text).map((e) => e.group(0)!).toList();
  }

  Future<void> _handlePost() async {
    final caption = _captionController.text.trim();
    final hashtags = _extractHashtags(caption);

    if (caption.isEmpty && _selectedMedia == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please write something or add media")),
      );
      return;
    }

    final postProvider = Provider.of<PostProviderService>(context, listen: false);

    bool success = await postProvider.uploadPost(
      caption: caption,
      hashtags: hashtags,
      file: _selectedMedia,
      isVideo: _isVideo,
      context: context,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Post uploaded successfully")),
      );
      _captionController.clear();
      setState(() {
        _selectedMedia = null;
        _isVideo = false;
        _videoController?.dispose();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed: ${postProvider.errorMessage}")),
      );
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
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
        title: const CustomTextWidget(text: "Create Post"),
        actions: [
          TextButton(
            onPressed: postProvider.isLoading ? null : _handlePost,
            child: postProvider.isLoading
                ? const CircularProgressIndicator()
                : const Text("Post",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // Profile + Input + Buttons
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(userProvider.currentUser!.profileImage),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _captionController,
                    maxLines: null,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: const InputDecoration(
                      hintText: "What's on your mind?",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.photo_library_outlined),
                  onPressed: () => _pickMedia(isVideo: false, source: ImageSource.gallery),
                ),
                IconButton(
                  icon: const Icon(Icons.videocam_outlined),
                  onPressed: () => _pickMedia(isVideo: true, source: ImageSource.gallery),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Media Preview
            if (_selectedMedia != null)
              _isVideo
                  ? (_videoController != null && _videoController!.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
                  : const CircularProgressIndicator())
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedMedia!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 10),

            // Hashtag preview
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
                    backgroundColor:
                    isDark ? Colors.blueGrey : Colors.blue.shade50,
                  ))
                      .toList(),
                )
                    : const SizedBox();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: _isVideo && _videoController != null
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _videoController!.value.isPlaying
                ? _videoController!.pause()
                : _videoController!.play();
          });
        },
        child: Icon(
            _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow),
      )
          : null,
    );
  }
}


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:link_io/src/core/constants/app_colors.dart';
// import 'package:link_io/src/core/utils/utils.dart';
// import 'package:link_io/src/provider/user_detail_provider.dart';
// import 'package:link_io/src/services/post_provider_service.dart';
// import 'package:link_io/src/widget/custom_text_widget.dart';
// import 'package:provider/provider.dart';
//
// class PostUploadScreen extends StatefulWidget {
//   const PostUploadScreen({super.key});
//
//   @override
//   State<PostUploadScreen> createState() => _PostUploadScreenState();
// }
//
// class _PostUploadScreenState extends State<PostUploadScreen> {
//   final TextEditingController _captionController = TextEditingController();
//   File? _selectedImage;
//
//   // Pick image from gallery or camera
//   Future<void> _pickImage(ImageSource source) async {
//     final pickedFile = await ImagePicker().pickImage(source: source);
//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });
//     }
//   }
//
//   // Extract hashtags from caption
//   List<String> _extractHashtags(String text) {
//     final RegExp regex = RegExp(r"\B#\w\w+");
//     return regex.allMatches(text).map((match) => match.group(0)!).toList();
//   }
//
//   Future<void> _handlePost() async {
//     final caption = _captionController.text.trim();
//     final hashtags = _extractHashtags(caption);
//
//     if (caption.isEmpty && _selectedImage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please write something or add an image")),
//       );
//       return;
//     }
//
//     final postProvider = Provider.of<PostProviderService>(context, listen: false);
//
//     bool success = await postProvider.uploadPost(
//       caption: caption,
//       hashtags: hashtags,
//       image: _selectedImage,
//       context: context,
//     );
//
//     if (success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("✅ Post uploaded successfully")),
//       );
//       _captionController.clear();
//       setState(() => _selectedImage = null);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("❌ Failed: ${postProvider.errorMessage}")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final postProvider = Provider.of<PostProviderService>(context);
//     final userProvider = Provider.of<UserDetailProvider>(context);
//     return Scaffold(
//       backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightCard,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         title: CustomTextWidget(
//           text: "Create Post",
//           fontSize: screenWidth * 0.045,
//         ),
//         actions: [
//           TextButton(
//             onPressed: postProvider.isLoading ? null : _handlePost,
//             child: postProvider.isLoading
//                 ? const CircularProgressIndicator()
//                 : const Text(
//               "Post",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           )
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           children: [
//             // Profile + Image picker
//             Row(
//               children: [
//                  CircleAvatar(
//                   radius: 22,
//                   backgroundImage: NetworkImage("${userProvider.currentUser!.profileImage}"), // placeholder user
//                 ),
//                 const SizedBox(width: 10),
//                 Expanded(
//                   child: TextField(
//                     controller: _captionController,
//                     maxLines: null,
//                     style: TextStyle(
//                         color: isDark ? Colors.white : Colors.black),
//                     decoration: const InputDecoration(
//                       hintText: "What's on your mind?",
//                       border: InputBorder.none,
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.photo_library_outlined),
//                   onPressed: () => _pickImage(ImageSource.gallery),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.camera_alt_outlined),
//                   onPressed: () => _pickImage(ImageSource.camera),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 10),
//
//             // Image Preview
//             if (_selectedImage != null)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.file(
//                   _selectedImage!,
//                   height: 200,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//
//             const SizedBox(height: 10),
//
//             // Hashtag Preview
//             ValueListenableBuilder<TextEditingValue>(
//               valueListenable: _captionController,
//               builder: (context, value, child) {
//                 final hashtags = _extractHashtags(value.text);
//                 return hashtags.isNotEmpty
//                     ? Wrap(
//                   spacing: 6,
//                   children: hashtags
//                       .map((tag) => Chip(
//                     label: Text(tag),
//                     backgroundColor: isDark
//                         ? Colors.blueGrey
//                         : Colors.blue.shade50,
//                   ))
//                       .toList(),
//                 )
//                     : const SizedBox();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
