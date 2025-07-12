import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:weatherapp/app/components/my_widgets_animator.dart';
import 'package:weatherapp/app/services/background_video_service.dart';

import '../../../../config/translations/strings_enum.dart';
import '../../../components/api_error_widget.dart';
import '../controllers/home_controller.dart';
import 'widgets/futuristic_compact_tile.dart';
import 'widgets/futuristic_weather_card.dart';
import '../../splash/views/loading_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the persistent video service instance
    final videoService = Get.find<BackgroundVideoService>();

    return Scaffold(
      backgroundColor: Colors.black, // Base color for transitions
      body: GetBuilder<HomeController>(
        builder: (_) => MyWidgetsAnimator(
          apiCallStatus: controller.apiCallStatus,
          loadingWidget: () => const LoadingView(),
          errorWidget: () => ApiErrorWidget(
            retryAction: () => controller.refreshAllData(),
          ),
          successWidget: () => Stack(
            children: [
              // --- Animated Video Background ---
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: videoService.videoController.value.size.width,
                    height: videoService.videoController.value.size.height,
                    child: Obx(
                      () => videoService.isInitialized.value
                          ? VideoPlayer(videoService.videoController)
                          : Container(color: Colors.black),
                    ),
                  ),
                ),
              ),

              // --- Frosted Glass Overlay ---
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.black.withOpacity(0.4),
                  ),
                ),
              ),

              // --- Main Scrollable Content ---
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const _FuturisticAppBar(),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 250.h,
                      child: CarouselSlider.builder(
                        options: CarouselOptions(
                          height: 210.h,
                          viewportFraction: 0.8,
                          enlargeCenterPage: true,
                          enlargeFactor: 0.15,
                          onPageChanged: controller.onCardSlided,
                        ),
                        itemCount: controller.weatherCards.length,
                        itemBuilder: (context, itemIndex, pageViewIndex) {
                          final weather = controller.weatherCards[itemIndex];
                          return weather == null
                              ? const LoadingView()
                              : FuturisticWeatherCard(
                                  weather: weather,
                                  cardIndex: itemIndex,
                                  showEditButton: itemIndex > 0,
                                );
                        },
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
                  ),
                  SliverToBoxAdapter(
                    child: GetBuilder<HomeController>(
                      id: controller.dotIndicatorsId,
                      builder: (_) => Center(
                        child: AnimatedSmoothIndicator(
                          activeIndex: controller.activeIndex,
                          count: controller.weatherCards.length,
                          effect: ScrollingDotsEffect(
                            activeDotColor: context.theme.primaryColor,
                            dotColor: Colors.white.withOpacity(0.3),
                            dotWidth: 8.w,
                            dotHeight: 8.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24.w, 30.h, 16.w, 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Global Data Stream",
                            style: context.theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
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
                  Obx(
                    () => _buildWorldList(context, controller.isEditingWorldList.value),
                  ),
                  SliverToBoxAdapter(child: 100.verticalSpace),
                ],
              ),
              // --- Floating Action Button ---
              Obx(
                () => AnimatedPositioned(
                  duration: 300.ms,
                  curve: Curves.easeInOutCubic,
                  bottom: controller.isEditingWorldList.isTrue ? -100 : 20.h,
                  right: 20.w,
                  child: FloatingActionButton(
                    onPressed: controller.onAddCityPressed,
                    backgroundColor: context.theme.primaryColor,
                    elevation: 10,
                    child: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorldList(BuildContext context, bool isEditing) {
    if (isEditing) {
      return SliverToBoxAdapter(
        child: ReorderableListView.builder(
          shrinkWrap: true,
          primary: false,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          itemCount: controller.weatherAroundTheWorld.length,
          itemBuilder: (context, index) {
            final weather = controller.weatherAroundTheWorld[index];
            return Padding(
              key: ValueKey(weather.location.name),
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: FuturisticCompactTile(
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
      return SliverList.separated(
        itemCount: controller.weatherAroundTheWorld.length,
        separatorBuilder: (context, index) => 12.verticalSpace,
        itemBuilder: (context, index) {
          final weather = controller.weatherAroundTheWorld[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: FuturisticCompactTile(
              weather: weather,
              isEditing: false,
              index: index,
            ).animate(delay: (100 * index).ms).fadeIn(duration: 500.ms).slideX(begin: -0.1),
          );
        },
      );
    }
  }
}

// --- A New, Floating AppBar ---
class _FuturisticAppBar extends StatelessWidget {
  const _FuturisticAppBar();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final controller = Get.find<HomeController>();

    return SliverAppBar(
      pinned: true,
      floating: true,
      elevation: 0,
      backgroundColor: Colors.transparent, // Make it fully transparent
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            color: Colors.black.withOpacity(0.25), // Control the darkness of the blur
            child: FlexibleSpaceBar(
              titlePadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              title: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Welcome",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        Obx(
                          () => Text(
                            controller.currentTime.value,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.onChangeThemePressed(),
                    icon: GetBuilder<HomeController>(
                      id: controller.themeId,
                      builder: (_) => Icon(
                        controller.isLightTheme
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => controller.onChangeLanguagePressed(),
                    icon: const Icon(Icons.translate_outlined, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}