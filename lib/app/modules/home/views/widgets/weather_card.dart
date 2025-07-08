import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:weatherapp/app/modules/home/views/widgets/change_city_dialog.dart';
import 'package:weatherapp/app/routes/app_pages.dart'; // Added import

import '../../../../../utils/extensions.dart';
import '../../../../../config/translations/strings_enum.dart';
import '../../../../components/custom_cached_image.dart';
import '../../../../data/models/weather_model.dart';


class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final int cardIndex;
  const WeatherCard({super.key, required this.weather, required this.cardIndex});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return InkWell(
      onTap: () {
        Get.dialog(
          ChangeCityDialog(cardIndex: cardIndex),
        );
      },
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        height: 190.h,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.primaryColor.withAlpha((0.7 * 255).round()),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Stack( // Added Stack
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      5.verticalSpace,
                      Text(
                        weather.location.country.toRightCountry(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      4.verticalSpace,
                      Text(
                        weather.location.name.toRightCity(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      10.verticalSpace,
                      Flexible(
                        child: Text(
                          weather.current.condition.text ?? '',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ).animate().slideX(
                    duration: 200.ms, begin: -1, curve: Curves.easeInSine,
                  ),
                ),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomCachedImage(
                        imageUrl: weather.current.condition.icon?.toHighRes().addHttpPrefix() ?? '',
                        fit: BoxFit.cover,
                        width: 100.w,
                        height: 100.h,
                        color: Colors.white,
                      ),
                      Text(
                        '${weather.current.tempC.round()}${Strings.celsius.tr}',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animate().slideX(
                  duration: 200.ms, begin: 1, curve: Curves.easeInSine,
                ),
              ],
            ),
            Positioned( // Added Positioned for IconButton
              top: 5.h, // Adjusted top padding
              right: 5.w, // Adjusted right padding
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50), // Semi-transparent background
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.white, size: 20.w), // Increased icon size
                  onPressed: () {
                    Get.toNamed(Routes.WEATHER, arguments: weather);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
