// lib/app/modules/weather/views/widgets/weather_details_item.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../../../../components/custom_icon_button.dart';

class WeatherDetailsItem extends StatelessWidget {
  final String title;
  final String icon;
  final String value;
  final String text;
  final bool isHalfCircle;
  // ✨ ENHANCEMENT: Added values for dynamic progress
  final double numericValue;
  final double maxValue;

  const WeatherDetailsItem({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.text,
    this.isHalfCircle = false,
    required this.numericValue,
    required this.maxValue,
  });

  // ✨ ENHANCEMENT: Helper to calculate the progress step
  int _calculateStep(int totalSteps) {
    if (maxValue == 0) return 0;
    // Clamp the value to ensure it doesn't exceed the max
    final clampedValue = numericValue.clamp(0, maxValue);
    return ((clampedValue / maxValue) * totalSteps).round();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    const totalSteps = 100; // Use a consistent total for easier calculation

    return Container(
      width: 170.w, // Slightly smaller for a sleeker look
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 35.w,
                height: 35.h,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(icon, width: 20.w, colorFilter: ColorFilter.mode(theme.primaryColor, BlendMode.srcIn)),
                ),
              ),
              8.horizontalSpace,
              Text(title, style: theme.textTheme.titleMedium),
            ],
          ),
          16.verticalSpace,
          CircularStepProgressIndicator(
            totalSteps: totalSteps,
            // ✨ ENHANCEMENT: Dynamically set the current step
            currentStep: _calculateStep(totalSteps),
            stepSize: 10,
            selectedColor: theme.primaryColor,
            unselectedColor: theme.dividerColor,
            padding: pi / 80,
            width: 140.w,
            height: 140.h,
            startingAngle: isHalfCircle ? pi * 2/3 : pi * -1/2, // Adjust starting angle
            arcSize: isHalfCircle ? pi * 2/3 * 2 : pi * 2,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    text,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}