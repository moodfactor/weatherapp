import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:weatherapp/app/components/custom_cached_image.dart';
import '../../../../../utils/extensions.dart';
import '../../../../../config/translations/strings_enum.dart';
import '../../../../data/models/weather_details_model.dart';

class FuturisticDetailsCard extends StatelessWidget {
  final WeatherDetailsModel weatherDetails;
  final Forecastday forecastDay;

  const FuturisticDetailsCard({
    super.key,
    required this.weatherDetails, // Corrected: Removed 'this.' prefix
    required this.forecastDay,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final iconUrl = forecastDay.day?.condition?.icon?.toHighRes()?.addHttpPrefix() ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(40.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40.r),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${weatherDetails.location?.name?.toRightCity() ?? ''}, ${weatherDetails.location?.country?.toRightCountry() ?? ''}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              20.verticalSpace,
              CustomCachedImage(
                imageUrl: iconUrl,
                width: 140.w,
                height: 140.h,
              ),
              Text(
                '${forecastDay.day?.maxtempC?.toInt() ?? ''}${Strings.celsius.tr}',
                style: TextStyle(
                  fontSize: 72.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w200, // Thin font for a futuristic look
                  height: 1.1,
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
      ),
    );
  }
}