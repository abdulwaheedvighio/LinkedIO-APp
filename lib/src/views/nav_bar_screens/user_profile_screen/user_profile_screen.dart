import 'package:flutter/material.dart';
import 'package:link_io/src/core/constants/app_colors.dart';
import 'package:link_io/src/core/constants/app_fonts.dart';
import 'package:link_io/src/core/utils/utils.dart';
import 'package:link_io/src/provider/user_detail_provider.dart';
import 'package:link_io/src/services/post_provider_service.dart';
import 'package:link_io/src/views/nav_bar_screens/user_edit_profile_screen/user_edit_profile_screen.dart';
import 'package:link_io/src/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final userProvider =
      Provider.of<UserDetailProvider>(context, listen: false);
      final postProvider =
      Provider.of<PostProviderService>(context, listen: false);

      if (userProvider.currentUser != null) {
        postProvider.getPostsByUserId(
          userId: userProvider.currentUser!.id!,
          context: context,
        );
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = Provider.of<UserDetailProvider>(context);
    final postProvider = Provider.of<PostProviderService>(context);

    final user = userProvider.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: CustomTextWidget(
          text: user.fullName ?? "My Profile",
          color: isDark ? AppColors.lightTextColor : AppColors.lightTextPrimary,
          fontSize: screenWidth * 0.045,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor:
      isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: RefreshIndicator(
        onRefresh: () async {
          await postProvider.getPostsByUserId(
            userId: user.id!,
            context: context,
          );
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImage(
                              imagePath:
                              user.profileImage ?? "assets/image/default.jpg",
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 45,
                        backgroundImage: (user.profileImage != null &&
                            user.profileImage!.isNotEmpty)
                            ? NetworkImage(user.profileImage!)
                            : const AssetImage("assets/image/default.jpg")
                        as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatColumn(
                                "Posts",
                                "${postProvider.posts.where((post) => post.user.id == userProvider.currentUser!.id).length}",
                                isDark,
                              ),
                              _buildStatColumn(
                                  "Followers",
                                  "${user.followers.length ?? 0}",
                                  isDark),
                              _buildStatColumn(
                                  "Following",
                                  "${user.following.length ?? 0}",
                                  isDark),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                    context, UserProfileUpdateScreen.routeName);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                isDark ? Colors.white12 : Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              child: Text(
                                "Edit Profile",
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontFamily: AppFonts.poppinsFont,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Username & Bio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? "User Name",
                      style: TextStyle(
                        fontFamily: AppFonts.poppinsFont,
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.038,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.bio ?? "Add a bio...",
                      style: TextStyle(
                        fontFamily: AppFonts.poppinsFont,
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ✅ Posts Grid
              postProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : postProvider.userPosts.isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("No posts yet."),
                ),
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: postProvider.userPosts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  final post = postProvider.userPosts[index];

                  if (post.media != null && post.media!.url.isNotEmpty) {
                    if (post.media!.type == "image") {
                      // ✅ Show Image
                      return Image.network(
                        post.media!.url,
                        fit: BoxFit.cover,
                      );
                    } else if (post.media!.type == "video") {
                      // ✅ Show Video Thumbnail / Placeholder
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Thumbnail placeholder (ya agar chaho to video ka preview bhi nikal sakte ho)
                          Container(
                            color: Colors.black12,
                            child: const Icon(
                              Icons.videocam,
                              color: Colors.white70,
                              size: 40,
                            ),
                          ),
                          const Positioned(
                            bottom: 8,
                            right: 8,
                            child: Icon(
                              Icons.play_circle_fill,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      );
                    }
                  }

                  // ✅ Default image if no media
                  return Image.asset(
                    "assets/image/default.jpg",
                    fit: BoxFit.cover,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  // Build stats column
  Column _buildStatColumn(String title, String count, bool isDark) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontFamily: AppFonts.poppinsFont,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontFamily: AppFonts.poppinsFont,
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imagePath;
  const FullScreenImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              child: imagePath.startsWith("http")
                  ? Image.network(imagePath)
                  : Image.asset(imagePath),
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
