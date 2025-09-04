import 'package:flutter/material.dart';
import 'package:link_io/src/core/constants/app_colors.dart';
import 'package:link_io/src/core/constants/app_fonts.dart';
import 'package:link_io/src/services/user_auth_service.dart';
import 'package:link_io/src/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final userAuthService =
    Provider.of<UserAuthService>(context, listen: false);

    final data = await userAuthService.fetchNotifications(context);
    if (mounted) {
      setState(() {
        notifications = data;
        isLoading = false;
      });
    }
  }

  Future<void> _respondToRequest(String notificationId, String action) async {
    final userAuthService =
    Provider.of<UserAuthService>(context, listen: false);

    final res = await userAuthService.respondFollowRequest(
      notificationId: notificationId,
      action: action,
      context: context,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res['message'] ?? '')),
    );

    if (res['success']) {
      setState(() {
        notifications.removeWhere((n) => n['_id'] == notificationId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
      isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(
        child: Text(
          "No notifications yet",
          style: TextStyle(fontSize: 16),
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notif = notifications[index];
            return _buildNotificationCard(notif, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif, bool isDark) {
    final senderName = notif['sender']?['fullName'] ?? "Unknown";
    final profileImage = notif['sender']?['profileImage'] ??
        "https://i.pravatar.cc/150?img=1";
    final type = notif['type'] ?? "";
    final createdAt = DateTime.tryParse(notif['createdAt'] ?? "");

    final iconData = _getIcon(type).$1;
    final iconColor = _getIcon(type).$2;
    final message = _getMessage(type);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(profileImage),
              radius: 26,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: isDark ? Colors.black : Colors.white,
                child: Icon(iconData, size: 14, color: iconColor),
              ),
            )
          ],
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
              fontFamily: AppFonts.poppinsFont,
            ),
            children: [
              TextSpan(
                text: senderName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: message),
            ],
          ),
        ),
        subtitle: createdAt != null
            ? Text(
          timeago.format(createdAt),
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        )
            : null,
        trailing: (type == "follow" || type == "friend_request")
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              label: "Accept",
              color: AppColors.primary,
              onTap: () => _respondToRequest(notif['_id'], "accept"),
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              label: "Reject",
              color: AppColors.error,
              onTap: () => _respondToRequest(notif['_id'], "reject"),
            ),
          ],
        )
            : null,
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: CustomTextWidget(text: label),
    );
  }

  (IconData, Color) _getIcon(String type) {
    switch (type) {
      case "like":
        return (Icons.favorite, Colors.redAccent);
      case "comment":
        return (Icons.comment, Colors.blue);
      case "follow":
      case "friend_request":
        return (Icons.person_add, Colors.green);
      default:
        return (Icons.notifications, Colors.grey);
    }
  }

  String _getMessage(String type) {
    switch (type) {
      case "like":
        return " liked your post";
      case "comment":
        return " commented on your post";
      case "follow":
        return " started following you";
      case "friend_request":
        return " sent you a friend request";
      default:
        return " sent a notification";
    }
  }
}
