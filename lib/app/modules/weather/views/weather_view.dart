import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:weatherapp/app/services/background_video_service.dart';
import 'package:weatherapp/utils/extensions.dart';

import '../../../components/api_error_widget.dart';
import '../../../components/my_widgets_animator.dart';
import '../controllers/weather_controller.dart';
import 'widgets/data_pod.dart';
import 'widgets/futuristic_details_card.dart';
import 'widgets/futuristic_hourly_item.dart';

class WeatherView extends GetView<WeatherController> {
  const WeatherView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final videoService = Get.find<BackgroundVideoService>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GetBuilder<WeatherController>(
        builder: (_) => MyWidgetsAnimator(
          apiCallStatus: controller.apiCallStatus,
          loadingWidget: () => Center(child: CircularProgressIndicator(color: theme.primaryColor)),
          errorWidget: () => ApiErrorWidget(
            retryAction: () => controller.getWeatherDetails(),
          ),
          successWidget: () => Stack(
            children: [
              // --- Video Background ---
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: videoService.videoController.value.size.width,
                    height: videoService.videoController.value.size.height,
                    child: VideoPlayer(videoService.videoController),
                  ),
                ),
              ),
              // --- Frosted Glass Overlay ---
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(color: Colors.black.withOpacity(0.4)),
                ),
              ),
              // --- Main Scrollable UI ---
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildFuturisticAppBar(context),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        20.verticalSpace,
                        SizedBox(
                          height: 380.h,
                          child: PageView.builder(
                            controller: controller.pageController,
                            onPageChanged: controller.onCardSlided,
                            itemCount: controller.weatherDetails?.forecast?.forecastday?.length ?? 0,
                            itemBuilder: (context, index) {
                              final forecast = controller.weatherDetails!.forecast!.forecastday![index];
                              // Apply a scaling effect based on page position
                              return AnimatedBuilder(
                                animation: controller.pageController,
                                builder: (context, child) {
                                  double value = 1.0;
                                  if (controller.pageController.position.haveDimensions) {
                                    value = (controller.pageController.page ?? 0) - index;
                                    value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                                  }
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: FuturisticDetailsCard(
                                  weatherDetails: controller.weatherDetails!,
                                  forecastDay: forecast,
                                ),
                              );
                            },
                          ),
                        ),
                        16.verticalSpace,
                        AnimatedSmoothIndicator(
                          activeIndex: controller.currentPage,
                          count: controller.weatherDetails?.forecast?.forecastday?.length ?? 0,
                          effect: ScrollingDotsEffect(
                            activeDotColor: theme.primaryColor,
                            dotColor: Colors.white.withOpacity(0.3),
                            dotWidth: 8.w,
                            dotHeight: 8.h,
                          ),
                        ),
                        30.verticalSpace,
                      ],
                    ),
                  ),

                  _buildSectionHeader("Today's Forecast"),

                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 120.h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        itemCount: controller.forecastday?.hour?.length ?? 0,
                        separatorBuilder: (_, __) => 12.horizontalSpace,
                        itemBuilder: (context, index) => FuturisticHourlyItem(
                          hour: controller.forecastday!.hour![index],
                        ),
                      ),
                    ),
                  ),

                  _buildSectionHeader("Atmosphere"),

                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              DataPod(
                                icon: Icons.water_drop_outlined,
                                label: 'Humidity',
                                value: '${controller.forecastday?.day?.avghumidity?.toInt() ?? ''}%',
                              ),
                              12.horizontalSpace,
                              DataPod(
                                icon: Icons.thermostat_outlined,
                                label: 'Real Feel',
                                value: '${controller.forecastday?.day?.avgtempC?.toInt() ?? ''}°',
                              ),
                            ],
                          ),
                          12.verticalSpace,
                          Row(
                            children: [
                              DataPod(
                                icon: Icons.air,
                                label: 'Wind Speed',
                                value: '${controller.forecastday?.day?.maxwindKph?.toInt() ?? ''} km/h',
                              ),
                              12.horizontalSpace,
                              DataPod(
                                icon: Icons.umbrella_outlined,
                                label: 'Rain Chance',
                                value: '${controller.forecastday?.day?.dailyChanceOfRain ?? ''}%',
                              ),
                            ],
                          ),
                          12.verticalSpace,
                           Row(
                            children: [
                              DataPod(
                                icon: Icons.wb_sunny_outlined,
                                label: 'Sunrise',
                                value: controller.forecastday?.astro?.sunrise?.formatTime() ?? '',
                              ),
                              12.horizontalSpace,
                              DataPod(
                                icon: Icons.nights_stay_outlined,
                                label: 'Sunset',
                                value: controller.forecastday?.astro?.sunset?.formatTime() ?? '',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(child: 30.verticalSpace),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 300.ms),
        ),
      ),
    );
  }

  SliverAppBar _buildFuturisticAppBar(BuildContext context) {
    final theme = context.theme;
    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white, size: 20.w),
                onPressed: () => Get.back(),
              ),
            ),
          ),
        ),
      ),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(color: Colors.black.withOpacity(0.25)),
        ),
      ),
      actions: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: PopupMenuButton<String>(
                onSelected: controller.onDaySelected,
                color: Colors.black.withOpacity(0.7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                itemBuilder: (context) =>
                    controller.weatherDetails?.forecast?.forecastday?.map((fd) {
                  return PopupMenuItem<String>(
                    value: fd.date.convertToDay(),
                    child: Text(
                      fd.date.convertToDay(),
                      style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                  );
                }).toList() ?? [],
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        controller.selectedDay,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      8.horizontalSpace,
                      Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        16.horizontalSpace,
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 30.h, 24.w, 16.h),
        child: Text(
          title,
          style: Get.theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}