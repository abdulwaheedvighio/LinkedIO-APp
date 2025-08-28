import 'package:flutter/material.dart';
import 'package:link_io/src/core/constants/app_colors.dart';
import 'package:link_io/src/core/constants/app_fonts.dart';
import 'package:link_io/src/services/user_auth_service.dart';
import 'package:link_io/src/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

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

  Future<void> _respondToRequest(
      String notificationId, String action) async {
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
      // agar accept ya reject success ho gaya toh list se remove kar do
      setState(() {
        notifications.removeWhere(
                (n) => n['_id'] == notificationId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightCard,

      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        elevation: 0,
      ),
     // backgroundColor: isDark ? Colors.black : Colors.grey.shade100,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? const Center(
        child: Text(
          "No notifications yet",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return _buildNotificationCard(notif, isDark);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif, bool isDark) {
    IconData icon;
    Color iconColor;

    switch (notif['type']) {
      case "like":
        icon = Icons.favorite;
        iconColor = Colors.redAccent;
        break;
      case "comment":
        icon = Icons.comment;
        iconColor = Colors.blue;
        break;
      case "follow":
      case "friend_request":
        icon = Icons.person_add;
        iconColor = Colors.green;
        break;
      default:
        icon = Icons.notifications;
        iconColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      color: isDark ? AppColors.darkCard : AppColors.lightCard,

      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(
                notif['sender']?['profileImage'] ??
                    "https://i.pravatar.cc/150?img=1",
              ),
              radius: 28,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: isDark ? Colors.black : Colors.white,
                child: Icon(icon, size: 14, color: iconColor),
              ),
            )
          ],
        ),
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                text: notif['sender']?['fullName'] ?? "Unknown",
                style: const TextStyle(fontWeight: FontWeight.bold,fontFamily: AppFonts.poppinsFont),
              ),
              TextSpan(text: _getMessage(notif['type'] ?? ""),style: TextStyle(fontFamily: AppFonts.poppinsFont,fontSize: 11)),
            ],
          ),
        ),
        trailing: notif['type'] == "follow" || notif['type'] == "friend_request"
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => _respondToRequest(
                  notif['_id'], "accept"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              child: CustomTextWidget(text: "Accept",),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _respondToRequest(
                  notif['_id'], "reject"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              child: const CustomTextWidget(text: "Accept",),
            ),
          ],
        )
            : null,
      ),
    );
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
