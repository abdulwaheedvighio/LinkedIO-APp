import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:link_io/src/core/utils/utils.dart';
import 'package:link_io/src/model/post_model.dart' as auth;
import 'package:link_io/src/services/post_provider_service.dart';
import 'package:link_io/src/services/user_auth_service.dart';
import 'package:link_io/src/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';


class FriendProfileScreen extends StatefulWidget {
  final auth.UserModel user;

  static const routeName = "/FriendProfileScreen";

  const FriendProfileScreen({super.key, required this.user});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  FollowStatus _followStatus = FollowStatus.none;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..forward();
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // ✅ Fetch posts and follow status on init
    Future.microtask(() async {
      final postProvider =
      Provider.of<PostProviderService>(context, listen: false);
      postProvider.getPostsByUserId(userId: widget.user.id!, context: context);

      final userAuthService =
      Provider.of<UserAuthService>(context, listen: false);
      final status = await userAuthService.getFollowStatus(
        targetUserId: widget.user.id ?? "",
        context: context,
      );

      if (mounted) {
        setState(() => _followStatus = status);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStat(String number, String label) {
    return Column(
      children: [
        CustomTextWidget(text: number,fontWeight: FontWeight.bold, fontSize: 18),
        const SizedBox(height: 2),
        CustomTextWidget(text: label,fontSize: 14, color: Colors.grey),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final postProvider = Provider.of<PostProviderService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            CustomTextWidget(
              text: widget.user.fullName ?? "Friend Name",
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.045,
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 22),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Feather.more_vertical),
            onPressed: () {},
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Profile with gradient ring
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFfeda75),
                                Color(0xFFfa7e1e),
                                Color(0xFFd62976),
                                Color(0xFF962fbf),
                                Color(0xFF4f5bd5),
                              ],
                            ),
                          ),
                          child: ClipOval(
                            child: (widget.user.profileImage != null &&
                                widget.user.profileImage!.isNotEmpty)
                                ? Image.network(
                              widget.user.profileImage!,
                              width: 95,
                              height: 95,
                              fit: BoxFit.cover,
                            )
                                : Image.asset(
                              "assets/image/default.jpg",
                              width: 95,
                              height: 95,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.040),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStat(
                                  "${postProvider.userPosts.length}", "Posts"),
                              _buildStat("1.4k", "Followers"),
                              _buildStat("100", "Following"),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Name + Bio
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextWidget(
                            text: widget.user.fullName ?? "Friend Name",
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 2),
                          CustomTextWidget(
                              text: widget.user.bio ?? "Mobile App Developer",
                              fontSize: 14, color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),

                    // ✅ Follow Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _followStatus == FollowStatus.none
                              ? Colors.blue
                              : _followStatus == FollowStatus.pending
                              ? Colors.orange
                              : Colors.grey[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _loading
                            ? null
                            : () async {
                          final userAuthService =
                          Provider.of<UserAuthService>(context, listen: false);

                          if (_followStatus == FollowStatus.none) {
                            // ✅ Send Follow Request
                            setState(() => _loading = true);
                            final result = await userAuthService.sendFollowRequest(
                              targetUserId: widget.user.id ?? "",
                              context: context,
                            );
                            setState(() {
                              _loading = false;
                              if (result["success"]) {
                                _followStatus = FollowStatus.pending;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(result["message"])),
                            );
                          } else if (_followStatus == FollowStatus.following) {
                            // ✅ Future: Unfollow API call
                            setState(() => _followStatus = FollowStatus.none);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Unfollowed user")),
                            );
                          }
                        },
                        child: _loading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : CustomTextWidget(
                          text: _followStatus == FollowStatus.none
                              ? "Follow"
                              : _followStatus == FollowStatus.pending
                              ? "Pending"
                              : "Following",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(thickness: 0.5),

              // Tabs like Insta
              const Row(
                children: [
                  Expanded(child: Icon(Icons.grid_on, size: 28)),
                  Expanded(child: Icon(Icons.person_pin_outlined, size: 28)),
                  Expanded(child: Icon(Icons.movie_filter, size: 28)),
                ],
              ),
              SizedBox(height: screenHeight * 0.020),

              // ✅ Posts Grid (using userPosts instead of posts)
              postProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : postProvider.userPosts.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(20.0),
                child: CustomTextWidget(text: "No posts available",color: Colors.grey)
              )
                  : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: postProvider.userPosts.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  final post = postProvider.userPosts[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FullScreenGalleryView(
                            images: postProvider.userPosts
                                .map((p) => p.image ?? "")
                                .where((url) => url.isNotEmpty)
                                .toList(),
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: '${post.id}_$index',
                      child: (post.image != null &&
                          post.image!.isNotEmpty)
                          ? Image.network(post.image!,
                          fit: BoxFit.cover)
                          : Image.asset("assets/image/default.jpg",
                          fit: BoxFit.cover),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenGalleryView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  const FullScreenGalleryView(
      {super.key, required this.images, required this.initialIndex});

  @override
  State<FullScreenGalleryView> createState() => _FullScreenGalleryViewState();
}

class _FullScreenGalleryViewState extends State<FullScreenGalleryView> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Center(
                  child: Hero(
                    tag: '${widget.images[index]}_$index',
                    child: (widget.images[index].isNotEmpty)
                        ? Image.network(widget.images[index],
                        fit: BoxFit.contain)
                        : Image.asset("assets/image/default.jpg",
                        fit: BoxFit.contain),
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: CustomTextWidget(
                text: "${_currentIndex + 1} / ${widget.images.length}",
                color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
