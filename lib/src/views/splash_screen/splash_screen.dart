import 'package:flutter/material.dart';
import 'package:link_io/src/core/constants/app_colors.dart';
import 'package:link_io/src/views/onboarding_screen/onboarding_screen.dart';
import 'package:link_io/src/widget/custom_text_widget.dart';
import 'dart:async';


class SplashScreen extends StatefulWidget {
  static const routeName = "/SplashScreen";
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    //Simulate loading, then navigate
    Timer(const Duration(seconds: 8), () {
      Navigator.pushReplacementNamed(context, OnboardingScreen.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon (Link style)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.link_rounded, // 🔗 Link icon for "Linkio"
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            CustomTextWidget(
              text: 'LinkedIo',
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.primary,
            ),

            const SizedBox(height: 8),

            // Tagline

            CustomTextWidget(
              text: 'Link. Learn. Grow.',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),

            const SizedBox(height: 32),

            // Loader
            const CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 4,
            ),
          ],
        ),
      ),
    );
  }
}
