// lib/app/modules/weather/views/widgets/weather_row_data.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WeatherRowData extends StatelessWidget {
  final String text;
  final String value;
  final IconData icon; // ✨ ENHANCEMENT: Added icon

  const WeatherRowData({
    super.key,
    required this.text,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    // ✨ ENHANCEMENT: Using Padding instead of a Column with a Divider for cleaner look
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, color: theme.primaryColor, size: 20.sp),
          12.horizontalSpace,
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}