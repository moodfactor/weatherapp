// lib/app/modules/weather/views/widgets/sun_rise_set_item.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SunRiseSetItem extends StatelessWidget {
  final String text;
  final String value;
  final IconData icon; // ✨ ENHANCEMENT: Added icon

  const SunRiseSetItem({
    super.key,
    required this.text,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Get.theme.primaryColor, size: 24.sp), // ✨ USE Icon
        12.horizontalSpace,
        Text(value, style: Get.theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        )),
        8.horizontalSpace,
        Text(text, style: Get.theme.textTheme.bodyMedium?.copyWith(
          color: Get.theme.hintColor,
        )),
      ],
    );
  }
}