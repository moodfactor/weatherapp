import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:weatherapp/app/modules/home/controllers/home_controller.dart';
import 'package:weatherapp/app/routes/app_pages.dart';
import '../../../../components/custom_cached_image.dart';
import 'package:weatherapp/config/translations/strings_enum.dart';
import '../../../../data/models/weather_model.dart';
import '../../../../../utils/extensions.dart';

class FuturisticCompactTile extends StatelessWidget {
  final WeatherModel weather;
  final bool isEditing;
  final int index;

  const FuturisticCompactTile({
    super.key,
    required this.weather,
    required this.isEditing,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final controller = Get.find<HomeController>();

    return InkWell(
      onTap: isEditing ? null : () => Get.toNamed(Routes.WEATHER, arguments: weather),
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isEditing ? 0.15 : 0.05),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.white.withOpacity(isEditing ? 0.3 : 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (isEditing)
              ReorderableDragStartListener(
                index: index,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: 12.w),
                  child: Icon(Icons.drag_handle_rounded, color: Colors.white.withOpacity(0.6)),
                ),
              ),
            CustomCachedImage(
              imageUrl: weather.current.condition.icon?.addHttpPrefix() ?? '',
              width: 45.w,
              height: 45.h,
            ),
            12.horizontalSpace,
            Expanded(
              child: Text(
                weather.location.name.toRightCity(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            12.horizontalSpace,
            if (isEditing)
              IconButton(
                icon: Icon(Icons.remove_circle_outline, color: theme.primaryColor.withOpacity(0.8)),
                onPressed: () => controller.removeCityFromWorldList(index),
              )
            else
              Text(
                '${weather.current.tempC.round()}${Strings.celsius.tr}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}