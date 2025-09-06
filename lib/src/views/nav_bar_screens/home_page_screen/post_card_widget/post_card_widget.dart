import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:link_io/src/core/constants/app_colors.dart';
import 'package:link_io/src/core/constants/app_fonts.dart';
import 'package:link_io/src/model/post_model.dart' as post;
import 'package:link_io/src/model/user_model.dart' as auth;
import 'package:link_io/src/provider/user_detail_provider.dart';
import 'package:link_io/src/services/post_provider_service.dart';
import 'package:link_io/src/views/nav_bar_screens/home_page_screen/friend_profile_screen/friend_profile_screen.dart';
import 'package:link_io/src/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class PostCardWidget extends StatefulWidget {
  final post.PostModel postItem;

  const PostCardWidget({super.key, required this.postItem});

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  late bool isLiked;
  late int likeCount;

  VideoPlayerController? _videoController;
  Future<void>? _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    final userId =
        Provider.of<UserDetailProvider>(context, listen: false).currentUser!.id;
    isLiked = widget.postItem.likes.any((like) => like.userId == userId);
    likeCount = widget.postItem.likes.length;

    // 🎥 Agar media video hai to init karo
    if (widget.postItem.media != null &&
        widget.postItem.media!.type == "video" &&
        widget.postItem.media!.url.isNotEmpty) {
      _videoController =
          VideoPlayerController.network(widget.postItem.media!.url);
      _initializeVideoPlayerFuture = _videoController!.initialize().then((_) {
        setState(() {});
      });
      _videoController!.setLooping(false);
      _videoController!.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  /// Format mm:ss
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final postProvider =
    Provider.of<PostProviderService>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Header
        ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: (widget.postItem.user.profileImage != null &&
                widget.postItem.user.profileImage!.isNotEmpty)
                ? NetworkImage(widget.postItem.user.profileImage!,)
                : const AssetImage("assets/image/default.jpg",) as ImageProvider,
          ),
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FriendProfileScreen(user: widget.postItem.user),
                ),
              );
            },
            child: CustomTextWidget(
              text: widget.postItem.user.fullName,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: CustomTextWidget(
            text: _timeAgo(widget.postItem.createdAt),
            fontSize: 12,
            color: Colors.grey,
          ),
        ),

        // ✅ Media (Video/Image)
        if (widget.postItem.media != null) ...[
          if (widget.postItem.media!.type == "video")
            _buildVideoPlayer()
          else if (widget.postItem.media!.type == "image")
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                widget.postItem.media!.url,
                width: double.infinity,
                height: 400,
                fit: BoxFit.cover,
              ),
            ),
        ],

        // ✅ Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                onPressed: () async {
                  setState(() {
                    isLiked = !isLiked;
                    likeCount += isLiked ? 1 : -1;
                  });
                  await postProvider.likePost(widget.postItem.id, context);
                },
              ),
              IconButton(
                icon: const Icon(Ionicons.chatbubble_outline),
                onPressed: () => _showComments(context, widget.postItem),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // ✅ Likes count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: CustomTextWidget(
            text: "$likeCount likes",
            fontWeight: FontWeight.bold,
          ),
        ),

        // ✅ Caption + Hashtags
        if (widget.postItem.caption.isNotEmpty ||
            widget.postItem.hashtags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.postItem.caption.isNotEmpty)
                  CustomTextWidget(
                    text: widget.postItem.caption,
                    fontWeight: FontWeight.w500,
                  ),
                if (widget.postItem.hashtags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: -6,
                    children: widget.postItem.hashtags
                        .map(
                          (tag) => Text(
                        "#$tag",
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontFamily: AppFonts.poppinsFont,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                        .toList(),
                  ),
              ],
            ),
          ),

        // ✅ Comments & time
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            "${widget.postItem.comments.length} comments • ${_timeAgo(widget.postItem.createdAt)}",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// 🎥 Video Player Widget
  Widget _buildVideoPlayer() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _videoController != null &&
            _videoController!.value.isInitialized) {
          final position = _videoController!.value.position;
          final duration = _videoController!.value.duration;

          return Column(
            children: [
              AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_videoController!),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        });
                      },
                      child: Icon(
                        _videoController!.value.isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        color: Colors.white.withOpacity(0.8),
                        size: 60,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "${_formatDuration(position)} / ${_formatDuration(duration)}",
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
              VideoProgressIndicator(
                _videoController!,
                allowScrubbing: true,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                colors: VideoProgressColors(
                  playedColor: Colors.blue,
                  bufferedColor: Colors.grey,
                  backgroundColor: Colors.black12,
                ),
              ),
            ],
          );
        }
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  /// ⏱ Time ago helper
  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return "${diff.inDays}d ago";
  }

  /// 💬 Comments BottomSheet
  void _showComments(BuildContext context, post.PostModel postItem) {
    final TextEditingController commentController = TextEditingController();
    final userDetailProvider =
    Provider.of<UserDetailProvider>(context, listen: false);
    final postProvider =
    Provider.of<PostProviderService>(context, listen: false);
    final auth.UserModel currentUser = userDetailProvider.currentUser!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        height: 4,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Comments",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(),

                      // ✅ Comment List
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: postItem.comments.length,
                          itemBuilder: (context, index) {
                            final comment = postItem.comments[index];
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundImage: (comment.user?.profileImage !=
                                    null &&
                                    comment.user!.profileImage!.isNotEmpty)
                                    ? NetworkImage(comment.user!.profileImage!)
                                    : const AssetImage(
                                    "assets/image/default.jpg")
                                as ImageProvider,
                              ),
                              title: CustomTextWidget(
                                text: comment.user?.fullName ?? "Unknown User",
                                fontWeight: FontWeight.bold,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextWidget(text: comment.text ?? ""),
                                  if (comment.createdAt != null)
                                    Row(
                                      children: [
                                        CustomTextWidget(
                                          text: _timeAgo(comment.createdAt!),
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton(
                                          onPressed: () {},
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: const Size(40, 20),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: const Text(
                                            "Reply",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      // ✅ Comment Input
                      SafeArea(
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundImage:
                                NetworkImage(currentUser.profileImage),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: commentController,
                                  decoration: const InputDecoration(
                                    hintText: "Add a comment...",
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      fontFamily: AppFonts.poppinsFont,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send, color: Colors.blue),
                                onPressed: () async {
                                  final text = commentController.text.trim();
                                  if (text.isNotEmpty) {
                                    setState(() {
                                      postItem.comments.insert(
                                        0,
                                        post.CommentModel(
                                          id: DateTime.now().toIso8601String(),
                                          text: text,
                                          user: post.UserModel(
                                            id: currentUser.id,
                                            fullName: currentUser.fullName,
                                            email: currentUser.email,
                                            profileImage:
                                            currentUser.profileImage,
                                          ),
                                          createdAt: DateTime.now(),
                                        ),
                                      );
                                    });

                                    commentController.clear();
                                    await postProvider.addComment(
                                        postItem.id, text, context);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
