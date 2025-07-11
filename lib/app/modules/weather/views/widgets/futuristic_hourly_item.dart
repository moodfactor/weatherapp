import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:weatherapp/app/components/custom_cached_image.dart';
import '../../../../../utils/extensions.dart';
import '../../../../../config/translations/strings_enum.dart';
import '../../../../data/models/weather_details_model.dart';

class FuturisticHourlyItem extends StatelessWidget {
  final Hour hour;
  const FuturisticHourlyItem({super.key, required this.hour});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: 60.w,
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            hour.time.convertToTime(),
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          CustomCachedImage(
            imageUrl: hour.condition.icon?.addHttpPrefix() ?? '',
            width: 35.w,
            height: 35.h,
          ),
          Text(
            '${hour.tempC.toInt().toString()}${Strings.celsius.tr}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}