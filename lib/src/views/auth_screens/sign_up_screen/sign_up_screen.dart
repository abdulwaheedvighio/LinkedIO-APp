// ---------------- SignUpScreen ----------------
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_io/src/core/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:link_io/src/core/constants/app_colors.dart';
import 'package:link_io/src/core/utils/app_toast.dart';
import 'package:link_io/src/core/utils/app_validator.dart';
import 'package:link_io/src/services/user_auth_service.dart';
import 'package:link_io/src/views/auth_screens/login_screen/login_screen.dart';
import 'package:link_io/src/widget/custom_elevated_button_widget.dart';
import 'package:link_io/src/widget/custom_text_form_field_widget.dart';
import 'package:link_io/src/widget/custom_text_widget.dart';

class SignUpScreen extends StatefulWidget {
  static const routeName = "/SignUpScreen";
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  final TextEditingController educationController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  final TextEditingController locationController = TextEditingController();
  final TextEditingController linksController = TextEditingController();

  String? accountType = "Student";
  bool obscureText = true;
  bool obscureText1 = true;
  bool isLoading = false;

  XFile? pickedImage;

  /// Pick Image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (image != null) {
      setState(() => pickedImage = image);
      AppToast.success("Profile image selected");
    }
  }

  /// Select Date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => dateOfBirthController.text = "${picked.day}-${picked.month}-${picked.year}");
    }
  }

  /// Register User
  Future<void> _registerUser() async {
    if (!formKey.currentState!.validate()) return;

    if (pickedImage == null) {
      AppToast.error("Please select a profile image");
      return;
    }

    setState(() => isLoading = true);

    try {
      final authProvider = Provider.of<UserAuthService>(context, listen: false);

      final result = await authProvider.userRegister(
        fullName: fullNameController.text.trim(),
        userName: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        phone: phoneController.text.trim(),
        gender: genderController.text.trim(),
        profileImage: File(pickedImage!.path),
        accountType: accountType ?? "Student",
      );

      setState(() => isLoading = false);

      if (result['success'] == true) {
        AppToast.success(result['message']);
        Navigator.pushReplacementNamed(context, LoginScreen.routeName);
      } else {
        AppToast.error(result['message'] ?? "Registration failed");
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
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Form(
          key: formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenHeight * 0.03),
            children: [
              CustomTextWidget(
                text: "Create Account",
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: screenHeight * 0.01),
              CustomTextWidget(
                text: "Step ${_currentStep + 1} of 3",
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w400,
              ),
              SizedBox(height: screenHeight * 0.03),

              /// Profile Image
              if (_currentStep == 0)
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: pickedImage != null ? FileImage(File(pickedImage!.path)) : null,
                      child: pickedImage == null ? Icon(Icons.camera_alt, size: 28, color: Colors.black54) : null,
                    ),
                  ),
                ),

              SizedBox(height: screenHeight * 0.03),

              /// Steps
              if (_currentStep == 0) _buildBasicInfoStep(),
              if (_currentStep == 1) _buildProfileInfoStep(),
              if (_currentStep == 2) _buildAdvancedInfoStep(),

              SizedBox(height: screenHeight * 0.03),

              /// Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: CustomElevatedButtonWidget(
                        text: "Back",
                        backgroundColor: Colors.grey,
                        borderRadius: 2,
                        onPressed: () => setState(() => _currentStep--),
                      ),
                    ),
                  if (_currentStep > 0) SizedBox(width: 12),
                  Expanded(
                    child: CustomElevatedButtonWidget(
                      text: _currentStep == 2 ? "Sign Up" : "Next",
                      backgroundColor: isDark ? AppColors.primary : AppColors.darkCard,
                      isLoading: isLoading,
                      borderRadius: 2,
                      onPressed: () {
                        if (_currentStep < 2) {
                          setState(() => _currentStep++);
                        } else {
                          _registerUser();
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),

              /// Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextWidget(text: "Already have an account? "),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, LoginScreen.routeName),
                    child: CustomTextWidget(text: "Login", fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Step 1: Basic Info
  Widget _buildBasicInfoStep() {
    return Column(
      children: [
        CustomTextFormFieldWidget(
          controller: fullNameController,
          prefixIcon: Icon(CupertinoIcons.person),
          hintText: "Full Name",
          validator: AppValidator.validateName,
        ),
        SizedBox(height: 12),
        CustomTextFormFieldWidget(
          controller: usernameController,
          prefixIcon: Icon(Icons.alternate_email),
          hintText: "Username",
          validator: AppValidator.validateName,
        ),
        SizedBox(height: 12),
        CustomTextFormFieldWidget(
          controller: emailController,
          prefixIcon: Icon(CupertinoIcons.mail),
          hintText: "Email",
          validator: AppValidator.validateEmail,
        ),
        SizedBox(height: 12),
        CustomTextFormFieldWidget(
          obscureText: obscureText,
          controller: passwordController,
          prefixIcon: Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            onPressed: () => setState(() => obscureText = !obscureText),
            icon: Icon(obscureText ? CupertinoIcons.eye_slash : CupertinoIcons.eye),
          ),
          hintText: "Password",
          validator: AppValidator.validatePassword,
        ),
        SizedBox(height: 12),
        CustomTextFormFieldWidget(
          obscureText: obscureText1,
          controller: confirmPasswordController,
          prefixIcon: Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            onPressed: () => setState(() => obscureText1 = !obscureText1),
            icon: Icon(obscureText1 ? CupertinoIcons.eye_slash : CupertinoIcons.eye),
          ),
          hintText: "Confirm Password",
          validator: (value) => AppValidator.validateConfirmPassword(value, passwordController.text),
        ),
        SizedBox(height: 12),
        CustomTextFormFieldWidget(
          hintText: "Date of Birth",
          controller: dateOfBirthController,
          isDatePicker: true,
          prefixIcon: Icon(Icons.calendar_month_outlined),
          onTapDate: _selectDate,
          validator: AppValidator.validateDateOfBirth,
        ),
        SizedBox(height: 12),
        CustomTextFormFieldWidget(
          controller: phoneController,
          prefixIcon: Icon(CupertinoIcons.phone),
          hintText: "Phone Number",
          validator: AppValidator.validatePhoneNumber,
        ),
        SizedBox(height: 12),
        CustomTextFormFieldWidget(
          controller: genderController,
          prefixIcon: Icon(CupertinoIcons.person_2),
          hintText: "Gender",
          validator: AppValidator.validateGender,
        ),
      ],
    );
  }

  /// Step 2: Profile Info
  Widget _buildProfileInfoStep() {
    return Column(
      children: [
        CustomTextFormFieldWidget(
          controller: educationController,
          hintText: "Education",
        ),
        SizedBox(height: 12),
        CustomTextFormFieldWidget(
          controller: skillsController,
          hintText: "Skills / Interests (comma separated)",
        ),
        SizedBox(height: 12),
        CustomTextFormFieldWidget(
          controller: jobTitleController,
          hintText: "Profession / Job Title",
        ),
        SizedBox(height: 12),
        CustomTextFormFieldWidget(
          controller: bioController,
          hintText: "Bio / About Me",
          maxLines: 3,
          obscureText: false, // ✅ important fix
        ),
      ],
    );
  }

  /// Step 3: Advanced Info
  Widget _buildAdvancedInfoStep() {
    return Column(
      children: [
        CustomTextFormFieldWidget(
          controller: locationController,
          hintText: "Location (City, Country)",
        ),
        SizedBox(height: 12),
        CustomTextFormFieldWidget(
          controller: linksController,
          hintText: "Portfolio / LinkedIn / GitHub",
        ),
        SizedBox(height: 12),
        CustomTextFormFieldWidget(
          hintText: "Account Type",
          isDropdown: true,
          dropdownItems: ["Student", "Professional", "Organization"],
          dropdownValue: accountType,
          onChanged: (val) => setState(() => accountType = val),
        ),
      ],
    );
  }
}
