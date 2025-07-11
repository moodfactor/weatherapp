import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:weatherapp/app/routes/app_pages.dart';

import '../../../../../config/translations/strings_enum.dart';
import '../../../../components/custom_cached_image.dart';
import '../../../../data/models/weather_model.dart';
import '../../../../../utils/extensions.dart';
import 'change_city_dialog.dart';

class FuturisticWeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final int cardIndex;
  final bool showEditButton;

  const FuturisticWeatherCard({
    super.key,
    required this.weather,
    required this.cardIndex,
    this.showEditButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return GestureDetector(
      onTap: () => Get.toNamed(Routes.WEATHER, arguments: weather),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 210.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
              // Glowing effect from the bottom
              boxShadow: [
                BoxShadow(
                  color: theme.primaryColor.withOpacity(0.3),
                  blurRadius: 25,
                  spreadRadius: -10,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Stack(
              children: [
                // --- Optional: Corner accent glow ---
                Positioned(
                  top: -50,
                  left: -50,
                  child: Container(
                    width: 150.w,
                    height: 150.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [theme.primaryColor.withOpacity(0.3), Colors.transparent],
                      ),
                    ),
                  ),
                ),

                // --- Main Content ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Column(
                    children: [
                      // Top Row: City and Edit button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  weather.location.name.toRightCity(),
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  weather.location.country.toRightCountry(),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (showEditButton)
                            GestureDetector(
                              onTap: () => Get.dialog(ChangeCityDialog(cardIndex: cardIndex)),
                              child: Icon(Icons.more_horiz, color: Colors.white.withOpacity(0.7), size: 28.sp),
                            ),
                        ],
                      ),
                      const Spacer(),
                      // Bottom Row: Icon, Temp, Condition
                      Row(
                        children: [
                          CustomCachedImage(
                            imageUrl: weather.current.condition.icon?.toHighRes().addHttpPrefix() ?? '',
                            width: 60.w,
                            height: 60.h,
                          ),
                          12.horizontalSpace,
                          Text(
                            '${weather.current.tempC.round()}${Strings.celsius.tr}',
                            style: TextStyle(
                              fontSize: 56.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w200, // Thinner font for a futuristic look
                              height: 1,
                            ),
                          ),
                          const Spacer(),
                          Expanded(
                            child: Text(
                              weather.current.condition.text ?? '',
                              textAlign: TextAlign.right,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
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
}