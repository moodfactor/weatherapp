// lib/app/modules/weather/views/weather_view.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Import flutter_animate
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:get/get.dart';

import '../../../../utils/extensions.dart';
import '../../../../config/translations/strings_enum.dart';
import '../../../../utils/constants.dart';
import '../../../components/api_error_widget.dart';
import '../../../components/my_widgets_animator.dart';
import '../controllers/weather_controller.dart';
import 'widgets/forecast_hour_item.dart';
import 'widgets/sun_rise_set_item.dart';
import 'widgets/weather_details_card.dart';
import 'widgets/weather_details_item.dart';
import 'widgets/weather_row_data.dart';

class WeatherView extends GetView<WeatherController> {
  const WeatherView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      body: GetBuilder<WeatherController>(
        builder: (_) => MyWidgetsAnimator(
          apiCallStatus: controller.apiCallStatus,
          loadingWidget: () => const Center(child: CircularProgressIndicator()),
          errorWidget: () => ApiErrorWidget(
            retryAction: () => controller.getWeatherDetails(),
          ),
          successWidget: () => CustomScrollView(
            slivers: [
              // ✨ ENHANCEMENT: Use SliverAppBar for a standard, flexible app bar
              SliverAppBar(
                backgroundColor: theme.scaffoldBackgroundColor,
                pinned: true,
                automaticallyImplyLeading: false, // Remove default back button
                elevation: 0,
                titleSpacing: 0,
                title: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.primaryColor,
                        child: IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: controller.onDaySelected,
                        color: theme.cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                        itemBuilder: (context) =>
                            controller.weatherDetails?.forecast?.forecastday?.map((fd) {
                          return PopupMenuItem<String>(
                            value: fd.date.convertToDay(),
                            child: Text(
                              fd.date.convertToDay(),
                              style: theme.textTheme.titleMedium,
                            ),
                          );
                        }).toList() ?? [],
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(30.r),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Row(
                            children: [
                              Text(controller.selectedDay, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              8.horizontalSpace,
                              Icon(Icons.keyboard_arrow_down_rounded, color: theme.hintColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ✨ ENHANCEMENT: Place the PageView inside a SliverToBoxAdapter
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    24.verticalSpace,
                    SizedBox(
                      height: 400.h, // Give it a fixed height
                      child: PageView.builder(
                        controller: controller.pageController,
                        physics: const BouncingScrollPhysics(), // Nicer scroll physics
                        onPageChanged: controller.onCardSlided,
                        itemCount: controller.weatherDetails?.forecast?.forecastday?.length ?? 0,
                        itemBuilder: (context, index) {
                          // This check is good, let's keep it
                          if (controller.weatherDetails == null || controller.weatherDetails!.forecast?.forecastday?.isEmpty == true) {
                            return const SizedBox.shrink();
                          }
                          return AnimatedBuilder(
                            animation: controller.pageController,
                            builder: (context, child) {
                              double value = 0.0;
                              if (controller.pageController.position.haveDimensions) {
                                value = index.toDouble() - (controller.pageController.page ?? 0);
                                value = (value * 0.038).clamp(-1, 1);
                              }
                              return Transform.rotate(
                                angle: pi * value,
                                child: WeatherDetailsCard(
                                  weatherDetails: controller.weatherDetails!,
                                  forecastDay: controller.weatherDetails!.forecast!.forecastday![index],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    20.verticalSpace,
                    Center(
                      child: AnimatedSmoothIndicator(
                        activeIndex: controller.currentPage,
                        count: controller.weatherDetails?.forecast?.forecastday?.length ?? 0,
                        effect: ExpandingDotsEffect( // More modern effect
                          activeDotColor: theme.primaryColor,
                          dotColor: theme.dividerColor,
                          dotWidth: 8.w,
                          dotHeight: 8.h,
                        ),
                      ),
                    ),
                    20.verticalSpace,
                  ],
                ),
              ),

              // ✨ ENHANCEMENT: A Sliver that contains all the bottom details
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 30.h),
                  decoration: BoxDecoration(
                    color: theme.canvasColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40.r),
                      topRight: Radius.circular(40.r),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Strings.hoursForecast.tr, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      16.verticalSpace,
                      SizedBox(
                        height: 110.h,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          itemCount: controller.forecastday?.hour?.length ?? 0,
                          itemBuilder: (context, index) => ForecastHourItem(
                            hour: controller.forecastday!.hour![index],
                          ),
                        ),
                      ),
                      24.verticalSpace,
                      Row(
                        children: [
                          Expanded(
                            child: WeatherDetailsItem(
                              title: Strings.wind.tr,
                              icon: Constants.wind,
                              value: controller.weatherDetails?.current?.windMph?.toInt().toString() ?? '',
                              text: 'mph',
                              numericValue: controller.weatherDetails?.current?.windMph ?? 0.0,
                              maxValue: 100, // Assuming a max wind speed of 100 mph for the gauge
                            ),
                          ),
                          16.horizontalSpace,
                          Expanded(
                            child: WeatherDetailsItem(
                              title: Strings.pressure.tr,
                              icon: Constants.pressure,
                              value: controller.weatherDetails?.current?.pressureIn?.toInt().toString() ?? '',
                              text: 'inHg',
                              isHalfCircle: true,
                              numericValue: controller.weatherDetails?.current?.pressureIn ?? 0.0,
                              maxValue: 40, // Assuming a max pressure of 40 inHg for the gauge
                            ),
                          ),
                        ],
                      ),
                      24.verticalSpace,
                      // ✨ ENHANCEMENT: Cleaner grid-like layout for extra details
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Column(
                          children: [
                            SunRiseSetItem(
                              icon: Icons.wb_sunny_outlined,
                              text: Strings.sunrise.tr,
                              value: controller.forecastday?.astro?.sunrise?.formatTime() ?? '',
                            ),
                            const Divider(height: 24),
                            SunRiseSetItem(
                              icon: Icons.nights_stay_outlined,
                              text: Strings.sunset.tr,
                              value: controller.forecastday?.astro?.sunset?.formatTime() ?? '',
                            ),
                          ],
                        ),
                      ),
                      16.verticalSpace,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Column(
                          children: [
                            WeatherRowData(
                              icon: Icons.water_drop_outlined,
                              text: Strings.humidity.tr,
                              value: '${controller.forecastday?.day?.avghumidity?.toInt() ?? ''}%',
                            ),
                            WeatherRowData(
                              icon: Icons.thermostat_outlined,
                              text: Strings.realFeel.tr,
                              value: '${controller.forecastday?.day?.avgtempC?.toInt() ?? ''}°',
                            ),
                            WeatherRowData(
                              icon: Icons.light_mode_outlined,
                              text: Strings.uv.tr,
                              value: controller.forecastday?.day?.uv.toString() ?? '',
                            ),
                            WeatherRowData(
                              icon: Icons.umbrella_outlined,
                              text: Strings.chanceOfRain.tr,
                              value: '${controller.forecastday?.day?.dailyChanceOfRain ?? ''}%',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().slideY(
                  begin: 0.5,
                  duration: 500.ms,
                  curve: Curves.easeOutCubic,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}