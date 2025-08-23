// ---------------- CustomTextFormFieldWidget ----------------
import 'package:flutter/material.dart';
import 'package:link_io/src/core/constants/app_colors.dart';
import 'package:link_io/src/core/constants/app_fonts.dart';

class CustomTextFormFieldWidget extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool isDatePicker;
  final VoidCallback? onTapDate;
  final bool readOnly;
  final bool isDropdown;
  final List<String>? dropdownItems;
  final String? dropdownValue;
  final int? maxLines;
  final Function(String?)? onChanged;

  const CustomTextFormFieldWidget({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.enabled = true,
    this.isDatePicker = false,
    this.onTapDate,
    this.readOnly = false,
    this.isDropdown = false,
    this.dropdownItems,
    this.dropdownValue,
    this.onChanged,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🔹 Dropdown Mode
    if (isDropdown && dropdownItems != null) {
      return DropdownButtonFormField<String>(
        value: dropdownValue,
        icon: const Icon(Icons.keyboard_arrow_down),
        items: dropdownItems!.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontFamily: AppFonts.poppinsFont,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: AppFonts.poppinsFont,
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          filled: true,
          fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
          contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(2),
            borderSide: BorderSide.none,
          ),
        ),
      );
    }

    // 🔹 TextFormField Mode (Default + Date Picker)
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      maxLines: obscureText ? 1 : (maxLines ?? 1), // ✅ Fix for obscureText crash
      readOnly: readOnly || isDatePicker,
      onTap: isDatePicker ? onTapDate : null,
      style: TextStyle(
        fontFamily: AppFonts.poppinsFont,
        color: isDark ? Colors.white : AppColors.lightTextPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontFamily: AppFonts.poppinsFont,
          fontSize: 14,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
