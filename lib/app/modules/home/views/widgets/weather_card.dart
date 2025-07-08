import 'dart:ui'; // Import for ImageFilter
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:weatherapp/app/modules/home/views/widgets/change_city_dialog.dart';
import 'package:weatherapp/app/routes/app_pages.dart';

import '../../../../../utils/extensions.dart';
import '../../../../../config/translations/strings_enum.dart';
import '../../../../components/custom_cached_image.dart';
import '../../../../data/models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final int cardIndex;
  // ✨ ENHANCEMENT: Added a flag to conditionally show the edit button
  final bool showEditButton;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.cardIndex,
    this.showEditButton = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.WEATHER, arguments: weather);
      },
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        height: 190.h,
        decoration: BoxDecoration(
          // ✨ ENHANCEMENT: Added a subtle shadow for depth
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          gradient: LinearGradient(
            colors: [
              theme.primaryColor,
              theme.primaryColor.withAlpha(200),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30.r),
        ),
        // Use a ClipRRect to contain the stacked elements
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.r),
          child: Stack(
            children: [
              // ✨ ENHANCEMENT: Large, semi-transparent background icon for visual flair
              Positioned(
                right: -25.w,
                bottom: -20.h,
                child: CustomCachedImage(
                  imageUrl: weather.current.condition.icon?.toHighRes().addHttpPrefix() ?? '',
                  width: 150.w,
                  height: 150.h,
                  color: Colors.white.withOpacity(0.15),
                  fit: BoxFit.cover,
                ),
              ),
              // Main content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3, // Give more space to text
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            weather.location.country.toRightCountry(),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white.withOpacity(0.85),
                              fontWeight: FontWeight.w500,
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
                          const Spacer(),
                          Flexible(
                            child: Text(
                              weather.current.condition.text ?? '',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          8.verticalSpace,
                        ],
                      ).animate().slideX(
                        duration: 300.ms, begin: -0.5, curve: Curves.easeOutCubic,
                      ),
                    ),
                    Expanded(
                      flex: 2, // Give less space to the icon and temp
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomCachedImage(
                            imageUrl: weather.current.condition.icon?.toHighRes().addHttpPrefix() ?? '',
                            fit: BoxFit.contain,
                            width: 80.w,
                            height: 80.h,
                          ),
                          4.verticalSpace,
                          Text(
                            '${weather.current.tempC.round()}${Strings.celsius.tr}',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ).animate().slideX(
                        duration: 300.ms, begin: 0.5, curve: Curves.easeOutCubic,
                      ),
                    ),
                  ],
                ),
              ),

              // ✨ ENHANCEMENT: Conditionally show the styled edit button
              if (showEditButton)
                Positioned(
                  top: 10.h,
                  right: 10.w,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          // ✨ ENHANCEMENT: More appropriate icon
                          icon: Icon(Icons.more_horiz, color: Colors.white, size: 22.w),
                          onPressed: () => Get.dialog(ChangeCityDialog(cardIndex: cardIndex)),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}