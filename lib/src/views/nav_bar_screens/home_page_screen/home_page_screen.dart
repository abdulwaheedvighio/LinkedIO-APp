import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_io/src/core/constants/app_colors.dart';
import 'package:link_io/src/core/utils/utils.dart';
import 'package:link_io/src/provider/user_detail_provider.dart';
import 'package:link_io/src/services/post_provider_service.dart';
import 'package:link_io/src/services/story_provider_service.dart';
import 'package:link_io/src/views/nav_bar_screens/home_page_screen/post_card_widget/post_card_widget.dart';
import 'package:link_io/src/views/notification_screen/notification_screen.dart';
import 'package:link_io/src/widget/custom_text_widget.dart';
import 'package:link_io/src/widget/skeleton_post_card_widget.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _pickedStoryFile;
  bool _isVideo = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // ✅ Posts fetch
      Provider.of<PostProviderService>(context, listen: false)
          .getPosts(context: context);

      // ✅ Stories fetch
      Provider.of<StoryProviderService>(context, listen: false)
          .getStories(context);
    });
  }

  // ✅ Pick image or video & upload
  Future<void> _pickStory({
    required ImageSource source,
    bool isVideo = false,
  }) async {
    final picker = ImagePicker();
    final pickedFile = isVideo
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _pickedStoryFile = File(pickedFile.path);
        _isVideo = isVideo;
      });

      final storyProvider =
      Provider.of<StoryProviderService>(context, listen: false);

      final success = await storyProvider.addStory(
        file: _pickedStoryFile!,
        caption: "My story",
        context: context,
      );

      if (success) {
        // ✅ Story upload hone ke baad refresh list
        await storyProvider.getStories(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Story uploaded successfully ✅")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(storyProvider.errorMessage ?? "Failed to upload"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightCard,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: CustomTextWidget(
          text: "LinkedIo",
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.lightCard : AppColors.darkCard,
          fontSize: screenWidth * 0.055,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search,
                color: isDark ? AppColors.lightCard : AppColors.darkCard),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.message_outlined,
                color: isDark ? AppColors.lightCard : AppColors.darkCard),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationScreen()),
              );
            },
            icon: Icon(Icons.notifications_none,
                color: isDark ? AppColors.lightCard : AppColors.darkCard),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.010),

          /// ✅ Stories Section
          /// ✅ Stories Section
          Consumer<StoryProviderService>(
            builder: (context, storyProvider, child) {
              if (storyProvider.isLoading) {
                return const SizedBox(
                  height: 100,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              // ✅ Hamesha "Your Story" show hoga
              return storiesWidget(context, storyProvider);
            },
          ),


          /// ✅ Posts Section
          Expanded(
            child: Consumer<PostProviderService>(
              builder: (context, postProvider, child) {
                if (postProvider.isLoading) {
                  return ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) =>
                    const PostCardLoadingWidget(),
                  );
                }

                if (postProvider.posts.isEmpty) {
                  return const Center(child: Text("No posts available"));
                }

                return ListView.builder(
                  itemCount: postProvider.posts.length,
                  itemBuilder: (context, index) {
                    final post = postProvider.posts[index];
                    return PostCardWidget(postItem: post);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Stories Widget
  Widget storiesWidget(BuildContext context, StoryProviderService storyProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserDetailProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    final stories = storyProvider.stories;

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stories.isEmpty ? 1 : stories.length + 1, // ✅ hamesha "Your Story" + others
        itemBuilder: (context, index) {
          final isYourStory = index == 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isYourStory
                              ? [Colors.grey, Colors.grey]
                              : [Colors.purple, Colors.orange],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: isYourStory
                              ? (_pickedStoryFile != null
                              ? (!_isVideo
                              ? FileImage(_pickedStoryFile!)
                          as ImageProvider
                              : const AssetImage(
                              "assets/image/video_placeholder.png"))
                              : (currentUser?.profileImage != null
                              ? NetworkImage(currentUser!.profileImage)
                              : const AssetImage(
                              "assets/image/default.jpg")))
                              : NetworkImage(stories[index - 1].mediaUrl),
                        ),
                      ),
                    ),
                    if (_isVideo && isYourStory && _pickedStoryFile != null)
                      const Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.play_circle_fill,
                              size: 40, color: Colors.black54),
                        ),
                      ),
                    if (isYourStory)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showAddStoryOptions(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                CustomTextWidget(
                  text: isYourStory
                      ? "Your Story"
                      : stories[index - 1].user?.username ?? "Unknown",
                  fontSize: 12,
                  color: isDark ? AppColors.lightCard : AppColors.darkCard,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ BottomSheet for Add Story
  void _showAddStoryOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickStory(source: ImageSource.camera, isVideo: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose Photo from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickStory(source: ImageSource.gallery, isVideo: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickStory(source: ImageSource.camera, isVideo: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Choose Video from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickStory(source: ImageSource.gallery, isVideo: true);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
