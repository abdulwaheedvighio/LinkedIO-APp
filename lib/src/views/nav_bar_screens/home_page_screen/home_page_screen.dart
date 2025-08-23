import 'package:flutter/material.dart';
import 'package:link_io/src/core/constants/app_colors.dart';
import 'package:link_io/src/core/utils/utils.dart';
import 'package:link_io/src/provider/user_detail_provider.dart';
import 'package:link_io/src/services/post_provider_service.dart';
import 'package:link_io/src/views/nav_bar_screens/home_page_screen/post_card_widget/post_card_widget.dart';
import 'package:link_io/src/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, String>> stories = [
    {"name": "Your Story", "image": "assets/image/image.jpg"},
    {"name": "raheem_12", "image": "assets/image/image4.jpg"},
    {"name": "ibraheed_3", "image": "assets/image/image3.jpg"},
  ];

  @override
  void initState() {
    super.initState();
    // Fetch posts on init
    Future.microtask(() =>
        Provider.of<PostProviderService>(context, listen: false).getPosts(context: context));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserDetailProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightCard,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: CustomTextWidget(
          text: "LinkIo",
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.lightCard : AppColors.darkCard,
          fontSize: screenWidth * 0.055,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              color: isDark ? AppColors.lightCard : AppColors.darkCard,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.message_outlined,
              color: isDark ? AppColors.lightCard : AppColors.darkCard,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none,
              color: isDark ? AppColors.lightCard : AppColors.darkCard,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // Stories Section
          SizedBox(height: screenHeight * 0.010),
          storiesWidget(context),
          // Dynamic Posts Feed
          Expanded(
            child: ListView.builder(
              itemCount: Provider.of<PostProviderService>(context).posts.length,
              itemBuilder: (context, index) {
                final post = Provider.of<PostProviderService>(context).posts[index];
                return PostCardWidget(postItem: post);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Stories Widget
  Widget storiesWidget(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userDetailProvider =
    Provider.of<UserDetailProvider>(context, listen: false);
    final currentUser = userDetailProvider.currentUser;

    return Container(
      height: 110,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
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
                              ? [Colors.grey, Colors.grey] // apni story → grey border
                              : [Colors.purple, Colors.orange], // others → gradient
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
                              ? (currentUser?.profileImage != null
                              ? NetworkImage(currentUser!.profileImage)
                              : const AssetImage("assets/image/default.jpg")
                          as ImageProvider) // ✅ Apni image
                              : AssetImage(story["image"]!), // ✅ Dummy image
                        ),
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
                      ? "Your Story" // ✅ pehla hamesha user ka naam
                      : story["name"]!,
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


  // Add Story Options
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
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
