// lib/app/modules/weather/views/widgets/weather_details_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:weatherapp/app/components/custom_cached_image.dart';
import '../../../../../utils/extensions.dart';
import '../../../../../config/translations/strings_enum.dart';
import '../../../../data/models/weather_details_model.dart';

class WeatherDetailsCard extends StatelessWidget {
  final WeatherDetailsModel weatherDetails;
  final Forecastday forecastDay;
  const WeatherDetailsCard({
    super.key,
    required this.weatherDetails,
    required this.forecastDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final iconUrl = forecastDay.day?.condition?.icon?.toHighRes()?.addHttpPrefix() ?? '';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10.w), // Adjust margin for new PageView fraction
      decoration: BoxDecoration(
        // ✨ ENHANCEMENT: Add shadow for depth
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        // ✨ ENHANCEMENT: Use a gradient for better visual appeal
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40.r), // More rounded
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40.r),
        child: Stack(
          children: [
            // ✨ ENHANCEMENT: Large, semi-transparent background icon
            Positioned(
              top: -20.h,
              right: -30.w,
              child: CustomCachedImage(
                imageUrl: iconUrl,
                width: 200.w,
                color: Colors.white.withOpacity(0.15),
              ),
            ),
            // Main Content
            SizedBox.expand(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${weatherDetails.location?.name?.toRightCity() ?? ''}, ${weatherDetails.location?.country?.toRightCountry() ?? ''}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  20.verticalSpace,
                  CustomCachedImage(
                    imageUrl: iconUrl,
                    width: 130.w,
                    height: 130.h,
                  ),
                  Text(
                    '${forecastDay.day?.maxtempC?.toInt() ?? ''}${Strings.celsius.tr}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  8.verticalSpace,
                  Text(
                    forecastDay.day?.condition?.text ?? '',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}