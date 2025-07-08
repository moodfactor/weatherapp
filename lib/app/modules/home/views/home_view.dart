import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:get/get.dart';

import '../../../../config/translations/strings_enum.dart';
import '../../../../utils/constants.dart';
import '../../../components/api_error_widget.dart';
import '../../../components/custom_icon_button.dart';
import '../../../components/my_widgets_animator.dart';
import '../controllers/home_controller.dart';
import 'widgets/compact_weather_list_tile.dart'; // ✨ IMPORT new compact tile
import 'widgets/home_shimmer.dart';
import 'widgets/weather_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✨ ENHANCEMENT: Use a CustomScrollView for more advanced scroll behaviors
      body: SafeArea(
        child: GetBuilder<HomeController>(
          builder: (_) => MyWidgetsAnimator(
            apiCallStatus: controller.apiCallStatus,
            loadingWidget: () => const HomeShimmer(),
            errorWidget: () => ApiErrorWidget(
              retryAction: () => controller.getUserLocation(),
            ),
            successWidget: () => CustomScrollView(
              slivers: [
                // ✨ ENHANCEMENT: Pinned App Bar at the top
                SliverPersistentHeader(
                  delegate: _HomeAppBar(),
                  pinned: true,
                ),

                // ✨ ENHANCEMENT: Sliver wrapper for the carousel
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      children: [
                        24.verticalSpace,
                        SizedBox(
                          height: 190.h,
                          child: CarouselSlider.builder(
                            options: CarouselOptions(
                              enableInfiniteScroll: false,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                              onPageChanged: controller.onCardSlided,
                            ),
                            itemCount: 3,
                            itemBuilder: (context, itemIndex, pageViewIndex) {
                              final weather = controller.weatherCards[itemIndex];
                              return weather == null
                                ? const Center(child: CircularProgressIndicator())
                                  // ✨ USE ENHANCED CARD: Pass showEditButton: true
                                : WeatherCard(
                                    weather: weather,
                                    cardIndex: itemIndex,
                                    showEditButton: true,
                                  );
                            },
                          ).animate().fade(duration: 400.ms).slideY(
                                duration: 500.ms,
                                begin: 0.2,
                                curve: Curves.easeOutCubic,
                              ),
                        ),
                        16.verticalSpace,
                        GetBuilder<HomeController>(
                          id: controller.dotIndicatorsId,
                          builder: (_) => AnimatedSmoothIndicator(
                            activeIndex: controller.activeIndex,
                            count: 3,
                            effect: WormEffect(
                              activeDotColor: context.theme.primaryColor,
                              dotColor: context.theme.colorScheme.surface,
                              dotWidth: 10.w,
                              dotHeight: 10.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ✨ ENHANCEMENT: Sliver wrapper for the section header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 24.h),
                    child: Text(
                      Strings.aroundTheWorld.tr,
                      style: context.theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ).animate().fade(delay: 200.ms).slideX(
                          duration: 400.ms,
                          begin: -0.5,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                ),

                // ✨ ENHANCEMENT: Use SliverList for the list of other cities
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 26.w),
                  sliver: SliverList.separated(
                    itemCount: controller.weatherArroundTheWorld.length,
                    separatorBuilder: (context, index) => 16.verticalSpace,
                    itemBuilder: (context, index) =>
                        // ✨ USE NEW WIDGET: CompactWeatherListTile
                        CompactWeatherListTile(
                      weather: controller.weatherArroundTheWorld[index],
                    ).animate(delay: (100 * index).ms).fade(duration: 400.ms).slideY(
                          duration: 400.ms,
                          begin: 0.5,
                          curve: Curves.easeOutCubic,
                        ),
                  ),
                ),
                SliverToBoxAdapter(child: 24.verticalSpace),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ✨ ENHANCEMENT: Extracted the app bar into a SliverPersistentHeaderDelegate
class _HomeAppBar extends SliverPersistentHeaderDelegate {
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = context.theme;
    final controller = Get.find<HomeController>();

    return Container(
      color: theme.scaffoldBackgroundColor, // Ensures it covers content when scrolling
      padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hello!', // A more welcoming greeting
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.hintColor),
                ),
                Obx(
                  () => Text(
                    controller.currentTime.value, // Changed to a more fitting greeting or name if available
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          CustomIconButton(
            onPressed: () => controller.onChangeThemePressed(),
            icon: GetBuilder<HomeController>(
              id: controller.themeId,
              builder: (_) => Icon(
                controller.isLightTheme ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              ),
            ),
            borderColor: theme.dividerColor,
          ),
          8.horizontalSpace,
          CustomIconButton(
            onPressed: () => controller.onChangeLanguagePressed(),
            icon: SvgPicture.asset(
              Constants.language,
              width: 22.w,
              height: 22.h,
              colorFilter: ColorFilter.mode(theme.iconTheme.color!, BlendMode.srcIn),
            ),
            borderColor: theme.dividerColor,
          ),
        ],
      ).animate().fade(duration: 300.ms).slideY(
            begin: -0.5,
            curve: Curves.easeOutCubic,
          ),
    );
  }

  @override
  double get maxExtent => 80.h;

  @override
  double get minExtent => 80.h;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}