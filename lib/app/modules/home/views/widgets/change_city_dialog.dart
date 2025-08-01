import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:weatherapp/config/translations/strings_enum.dart';
import '../../controllers/home_controller.dart';

class ChangeCityDialog extends GetView<HomeController> {
  final int cardIndex;
  const ChangeCityDialog({
    Key? key,
    required this.cardIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final TextEditingController cityController = TextEditingController();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
        ),
        elevation: 0,
        backgroundColor: theme.cardColor.withOpacity(0.85),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Strings.enterCityName.tr,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              24.verticalSpace,
              TextField(
                controller: cityController,
                decoration: InputDecoration(
                  hintText: Strings.cityName.tr,
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.r),
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                ),
                style: theme.textTheme.bodyLarge,
              ),
              24.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(Strings.cancel.tr),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (cityController.text.trim().isNotEmpty) {
                          // ✨ USE ENHANCED CONTROLLER METHOD
                          controller.updateWeatherForCard(cityController.text.trim(), cardIndex);
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                      child: Text(Strings.change.tr),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fade(duration: 200.ms).scale(begin: const Offset(0.9, 0.9)),
      ),
    );
  }
}