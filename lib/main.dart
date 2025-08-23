import 'package:flutter/material.dart';
import 'package:link_io/root_screen.dart';
import 'package:link_io/src/core/constants/app_theme.dart';
import 'package:link_io/src/core/utils/utils.dart';
import 'package:link_io/src/provider/user_detail_provider.dart';
import 'package:link_io/src/services/post_provider_service.dart';
import 'package:link_io/src/services/user_auth_service.dart';
import 'package:link_io/src/views/auth_screens/login_screen/login_screen.dart';
import 'package:link_io/src/views/auth_screens/sign_up_screen/sign_up_screen.dart';
import 'package:link_io/src/views/nav_bar_screens/user_edit_profile_screen/user_edit_profile_screen.dart';
import 'package:link_io/src/views/onboarding_screen/onboarding_screen.dart';
import 'package:link_io/src/views/splash_screen/splash_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => UserAuthService(),
        ),
        ChangeNotifierProvider(
            create: (context) => UserDetailProvider(),
        ),
        ChangeNotifierProvider(
            create: (context) => PostProviderService(),
        ),
      ],
      child: MaterialApp(
        title: 'LinkedIo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
        home: const SplashScreen(),
        routes: {
          SplashScreen.routeName : (context) => SplashScreen(),
          OnboardingScreen.routeName : (context) => OnboardingScreen(),
          LoginScreen.routeName : (context) => LoginScreen(),
          SignUpScreen.routeName : (context) => SignUpScreen(),
          RootScreen.routeName : (context) => RootScreen(),
          UserProfileUpdateScreen.routeName : (context) => UserProfileUpdateScreen(),
        },
      ),
    );
  }
}