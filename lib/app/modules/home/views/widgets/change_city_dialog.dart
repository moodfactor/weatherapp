
import 'package:flutter/material.dart';
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

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Strings.enterCityName.tr,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.primaryColor,
              ),
            ),
            20.verticalSpace,
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                hintText: Strings.cityName.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: theme.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: theme.primaryColor, width: 2),
                ),
              ),
              style: theme.textTheme.bodyMedium,
            ),
            20.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text(
                    Strings.cancel.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                10.horizontalSpace,
                ElevatedButton(
                  onPressed: () {
                    if (cityController.text.isNotEmpty) {
                      controller.getCurrentWeather(cityController.text, cardIndex);
                      Get.back();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    Strings.change.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
