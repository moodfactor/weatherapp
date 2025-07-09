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
import 'widgets/compact_weather_list_tile.dart';
import 'widgets/home_shimmer.dart';
import 'widgets/weather_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      // Use a Stack to overlay the FloatingActionButton
      body: GetBuilder<HomeController>(
        builder: (_) => MyWidgetsAnimator(
          apiCallStatus: controller.apiCallStatus,
          loadingWidget: () => const HomeShimmer(),
          errorWidget: () => ApiErrorWidget(
            retryAction: () => controller.refreshAllData(),
          ),
          successWidget: () => Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    delegate: _HomeAppBar(),
                    pinned: true,
                  ),
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
                              itemCount: controller.weatherCards.length,
                              itemBuilder: (context, itemIndex, pageViewIndex) {
                                final weather = controller.weatherCards[itemIndex];
                                return weather == null
                                    ? Center(child: CircularProgressIndicator(color: theme.primaryColor))
                                    : WeatherCard(
                                        weather: weather,
                                        cardIndex: itemIndex,
                                        showEditButton: itemIndex > 0,
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
                              count: controller.weatherCards.length,
                              effect: WormEffect(
                                activeDotColor: theme.primaryColor,
                                dotColor: theme.colorScheme.surface,
                                dotWidth: 10.w,
                                dotHeight: 10.h,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // "Around the World" Section Header with Edit Button
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(26.w, 24.h, 16.w, 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            Strings.aroundTheWorld.tr,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ).animate().fade(delay: 200.ms).slideX(
                                duration: 400.ms,
                                begin: -0.5,
                                curve: Curves.easeOutCubic,
                              ),
                          Obx(
                            () => TextButton(
                              onPressed: controller.toggleWorldListEditing,
                              child: Text(controller.isEditingWorldList.isTrue ? 'Done' : 'Edit'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // The "Around the World" List
                  Obx(
                    () => _buildWorldList(context, controller.isEditingWorldList.value),
                  ),
                  SliverToBoxAdapter(child: 60.verticalSpace), // Space for FAB
                ],
              ),
              // Floating Action Button for adding cities
              Obx(
                () => AnimatedPositioned(
                  duration: 300.ms,
                  curve: Curves.easeInOutCubic,
                  bottom: controller.isEditingWorldList.isTrue ? -100 : 20.h,
                  right: 20.w,
                  child: FloatingActionButton(
                    onPressed: controller.onAddCityPressed,
                    backgroundColor: theme.primaryColor,
                    child: const Icon(Icons.add, color: Colors.white),
                  ).animate(
                    target: controller.isEditingWorldList.isTrue ? 0 : 1,
                  ).scale(end: const Offset(1.1, 1.1)).then().scale(end: const Offset(1/1.1, 1/1.1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build the appropriate list based on editing state
  Widget _buildWorldList(BuildContext context, bool isEditing) {
    if (isEditing) {
      // Use ReorderableListView inside a SliverToBoxAdapter for drag-and-drop
      return SliverToBoxAdapter(
        child: ReorderableListView.builder(
          shrinkWrap: true,
          primary: false,
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          itemCount: controller.weatherAroundTheWorld.length,
          itemBuilder: (context, index) {
            final weather = controller.weatherAroundTheWorld[index];
            return Padding(
              key: ValueKey(weather.location.name),
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: CompactWeatherListTile(
                weather: weather,
                isEditing: true,
                index: index,
              ),
            );
          },
          onReorder: controller.reorderWorldList,
        ),
      );
    } else {
      // Use standard SliverList for display mode
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 26.w),
        sliver: SliverList.separated(
          itemCount: controller.weatherAroundTheWorld.length,
          separatorBuilder: (context, index) => 16.verticalSpace,
          itemBuilder: (context, index) => CompactWeatherListTile(
            weather: controller.weatherAroundTheWorld[index],
            isEditing: false,
            index: index,
          ).animate(delay: (100 * index).ms).fade(duration: 400.ms).slideY(
                duration: 400.ms,
                begin: 0.5,
                curve: Curves.easeOutCubic,
              ),
        ),
      );
    }
  }
}


// _HomeAppBar remains unchanged
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