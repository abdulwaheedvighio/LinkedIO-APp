import 'package:flutter/material.dart';
//import 'package:timeago/timeago.dart' as timeago;

class NotificationModel {
  final String type; // like, comment, follow
  final String userName;
  final String userImage;
  final String message;
  final DateTime createdAt;

  NotificationModel({
    required this.type,
    required this.userName,
    required this.userImage,
    required this.message,
    required this.createdAt,
  });
}

class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  // Dummy Data (API se load karoge baad mein)
  final List<NotificationModel> notifications = [
    NotificationModel(
      type: "like",
      userName: "Ali Raza",
      userImage: "https://i.pravatar.cc/150?img=3",
      message: "liked your post",
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    NotificationModel(
      type: "comment",
      userName: "Sara Khan",
      userImage: "https://i.pravatar.cc/150?img=5",
      message: "commented: Awesome work!",
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    NotificationModel(
      type: "follow",
      userName: "John Doe",
      userImage: "https://i.pravatar.cc/150?img=8",
      message: "started following you",
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor:
      isDark ? Colors.black : Colors.grey.shade100,
      body: notifications.isEmpty
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

  Widget _buildNotificationCard(NotificationModel notif, bool isDark) {
    IconData icon;
    Color iconColor;

    switch (notif.type) {
      case "like":
        icon = Icons.favorite;
        iconColor = Colors.redAccent;
        break;
      case "comment":
        icon = Icons.comment;
        iconColor = Colors.blue;
        break;
      case "follow":
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.grey.shade900 : Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(notif.userImage),
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
                text: notif.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: " ${notif.message}"),
            ],
          ),
        ),
        // subtitle: Text(
        //   timeago.format(notif.createdAt),
        //   style: TextStyle(
        //     color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        //     fontSize: 12,
        //   ),
        // ),
        trailing: notif.type == "follow"
            ? ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text("Follow Back"),
        )
            : null,
      ),
    );
  }
}
