import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:weatherapp/app/routes/app_pages.dart';
import '../../../../../config/translations/strings_enum.dart';
import '../../../../components/custom_cached_image.dart';
import '../../../../data/models/weather_model.dart';
import '../../../../../utils/extensions.dart';
import '../../controllers/home_controller.dart';

class CompactWeatherListTile extends StatelessWidget {
  final WeatherModel weather;
  final bool isEditing;
  final int index;

  const CompactWeatherListTile({
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
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: theme.dividerColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Conditionally show drag handle when editing
            if (isEditing)
              Padding(
                padding: EdgeInsetsDirectional.only(end: 12.w),
                child: ReorderableDragStartListener(
                  index: index,
                  child: Icon(Icons.drag_handle_rounded, color: theme.hintColor),
                ),
              ),
            CustomCachedImage(
              imageUrl: weather.current.condition.icon?.addHttpPrefix() ?? '',
              width: 50.w,
              height: 50.h,
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weather.location.name.toRightCity(),
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  2.verticalSpace,
                  Text(
                    weather.location.country.toRightCountry(),
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            12.horizontalSpace,
            // Conditionally show temp or delete icon
            isEditing
                ? IconButton(
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400),
                    onPressed: () => controller.removeCityFromWorldList(index),
                  )
                : Text(
                    '${weather.current.tempC.round()}${Strings.celsius.tr}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}