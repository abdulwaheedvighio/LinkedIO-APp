import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:link_io/root_screen.dart';
import 'package:link_io/src/core/constants/app_colors.dart';
import 'package:link_io/src/core/utils/app_toast.dart';
import 'package:link_io/src/core/utils/app_validator.dart';
import 'package:link_io/src/core/utils/utils.dart';
import 'package:link_io/src/provider/user_detail_provider.dart';
import 'package:link_io/src/services/user_auth_service.dart';
import 'package:link_io/src/views/auth_screens/sign_up_screen/sign_up_screen.dart';
import 'package:link_io/src/widget/custom_elevated_button_widget.dart';
import 'package:link_io/src/widget/custom_text_form_field_widget.dart';
import 'package:link_io/src/widget/custom_text_widget.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = "/LoginScreen";

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool obscureText = false;
  bool isLoading = false;


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!formKey.currentState!.validate()) return;


    setState(() => isLoading = true);

    try {
      final authProvider = Provider.of<UserAuthService>(context, listen: false);

      final result = await authProvider.userLogin(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        context: context,
      );

      setState(() => isLoading = false);

      if (result['success'] == true) {
        final userProvider = Provider.of<UserDetailProvider>(context, listen: false);
        await userProvider.getUserData();

        print("Name: ${userProvider.currentUser!.fullName}");
        print("Email: ${userProvider.currentUser!.email}");
        print("Token: ${userProvider.currentUser!.token}");
        print("User JSON: ${userProvider.currentUser?.toJson()}");


        print("Get Token From SharedPreferences: ${userProvider.currentUser!.token}");
        print("Get ID From SharedPreferences: ${userProvider.currentUser!.id}");

        //✅ Login successful
        AppToast.success(result['message'] ?? "Login successful");

        // Navigate to home/dashboard
        Navigator.pushReplacementNamed(context, RootScreen.routeName);

        // Optional: Save token locally using SharedPreferences
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('token', result['token']);
      } else {
        // Login failed
        AppToast.error(result['message'] ?? "Login failed");
      }
    } catch (error) {
      setState(() => isLoading = false);
      AppToast.error("Something went wrong: $error");
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(
        backgroundColor:
        isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.08,
              vertical: screenHeight * 0.05,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.05),

                /// 🔹 Logo + Branding
                Icon(Icons.link, size: screenWidth * 0.18, color: AppColors.primary),
                SizedBox(height: screenHeight * 0.02),
                CustomTextWidget(
                  text: "Linkio",
                  fontSize: screenWidth * 0.08,
                  fontWeight: FontWeight.w700,
                ),
                SizedBox(height: screenHeight * 0.01),
                CustomTextWidget(
                  text: "Connect with professionals & friends",
                  fontSize: screenWidth * 0.040,
                  fontWeight: FontWeight.w400,
                ),
                SizedBox(height: screenHeight * 0.05),

                /// 🔹 Login Form
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      CustomTextFormFieldWidget(
                        controller: emailController,
                        prefixIcon: const Icon(CupertinoIcons.mail),
                        hintText: "Email",
                        validator: (value) {
                          return AppValidator.validateEmail(value);
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      CustomTextFormFieldWidget(
                        obscureText: obscureText,
                        controller: passwordController,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                          icon: Icon(
                            obscureText
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                          ),
                        ),
                        hintText: "Password",
                        validator: (value) {
                          return AppValidator.validatePassword(value);
                        },
                      ),

                      /// Forgot Password
                      SizedBox(height: screenHeight * 0.015),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            // Navigator.pushNamed(context, ForgotPasswordScreen.routeName);
                          },
                          child: CustomTextWidget(
                            text: "Forgot Password?",
                            fontSize: screenWidth * 0.040,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      /// Login Button
                      CustomElevatedButtonWidget(
                        text: "Login",
                        backgroundColor: AppColors.primary,
                        borderRadius: 2,
                        isLoading: false,
                        isDisabled: false,
                        onPressed: (){
                          _login();
                        },
                      ),
                      SizedBox(height: screenHeight * 0.03),

                      /// Divider
                      Row(
                        children: [
                          Expanded(child: Divider(thickness: 1)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: CustomTextWidget(text: "or continue with"),
                          ),
                          Expanded(child: Divider(thickness: 1)),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      /// Social Login Buttons (future)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _socialButton(FontAwesomeIcons.google, Colors.red),
                          SizedBox(width: 20),
                          _socialButton(FontAwesomeIcons.facebook, Colors.blue),
                          SizedBox(width: 20),
                          _socialButton(FontAwesomeIcons.apple, Colors.black),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.04),

                      /// Register Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CustomTextWidget(text: "Don't have an account?"),
                          SizedBox(width: screenWidth * 0.014),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, SignUpScreen.routeName);
                            },
                            child: CustomTextWidget(
                              text: "Register",
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔹 Helper for Social Buttons
  Widget _socialButton(IconData icon, Color color) {
    return CircleAvatar(
      radius: 26,
      backgroundColor: color.withOpacity(0.1),
      child: Icon(icon, color: color, size: 26),
    );
  }
}
