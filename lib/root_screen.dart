import 'package:flutter/material.dart';
import 'package:link_io/src/core/utils/utils.dart';
import 'package:link_io/src/views/notification_screen/notification_screen.dart';
import 'package:link_io/src/views/nav_bar_screens/post_upload_screen/post_upload_screen.dart';
import 'package:link_io/src/views/nav_bar_screens/user_profile_screen/user_profile_screen.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:link_io/src/core/constants/app_colors.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:link_io/src/views/nav_bar_screens/home_page_screen/home_page_screen.dart';

class RootScreen extends StatefulWidget {

  static const routeName = "/RootScreen";

  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    Center(child: Text('Search Screen', style: TextStyle(fontSize: 24))),
    PostUploadScreen(),
    NotificationScreen(),
    UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: SizedBox(
        height: screenHeight * 0.065,
        child: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          items: [
            // Home
            SalomonBottomBarItem(
              icon: Icon(
                AntDesign.home,
                size: 25,
                color: _currentIndex == 0 ? AppColors.primary : Colors.grey,
              ),
              title: const SizedBox.shrink(),
              selectedColor: AppColors.primary,
            ),
            // Search
            SalomonBottomBarItem(
              icon: Icon(
                AntDesign.search1,
                size: 25,
                color: _currentIndex == 1 ? AppColors.primary : Colors.grey,
              ),
              title: const SizedBox.shrink(),
              selectedColor: AppColors.primary,
            ),
            // Post Upload
            SalomonBottomBarItem(
              icon: Icon(
                FontAwesome.plus_square_o,
                size: 25,
                color: _currentIndex == 2 ? AppColors.primary : Colors.grey,
              ),
              title: const SizedBox.shrink(),
              selectedColor: AppColors.primary,
            ),
            // Notifications
            SalomonBottomBarItem(
              icon: Icon(
                Ionicons.notifications_outline,
                size: 25,
                color: _currentIndex == 3 ? AppColors.primary : Colors.grey,
              ),
              title: const SizedBox.shrink(),
              selectedColor: AppColors.primary,
            ),
            // Profile
            SalomonBottomBarItem(
              icon: Icon(
                Ionicons.person_outline,
                size: 25,
                color: _currentIndex == 4 ? AppColors.primary : Colors.grey,
              ),
              title: const SizedBox.shrink(),
              selectedColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
