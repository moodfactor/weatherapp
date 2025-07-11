import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:video_player/video_player.dart';
import 'package:weatherapp/app/services/background_video_service.dart';

import '../../../../config/translations/strings_enum.dart';
import '../../../routes/app_pages.dart';
import '../controllers/welcome_controller.dart';

class WelcomeView extends GetView<WelcomeController> {
  const WelcomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    // Get the persistent video service instance
    final videoService = Get.find<BackgroundVideoService>();

    return Scaffold(
      body: Stack(
        children: [
          // --- Animated Video Background ---
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                // Use the service's controller's value for size
                width: videoService.videoController.value.size.width,
                height: videoService.videoController.value.size.height,
                // Wrap with Obx to react to the initialization state
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
              filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),

          // --- Main Content PageView ---
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    children: const [
                      _OnboardingPage(
                        icon: Icons.location_on_outlined,
                        title: 'Hyper-Local Forecasts',
                        subtitle:
                            'Get real-time weather updates based on your precise location for unparalleled accuracy.',
                      ),
                      _OnboardingPage(
                        icon: Icons.public_outlined,
                        title: 'Explore the World',
                        subtitle:
                            'Add and manage cities globally. Keep track of the weather for your favorite destinations.',
                      ),
                      _OnboardingPage(
                        icon: Icons.palette_outlined,
                        title: 'Visually Stunning',
                        subtitle:
                            'Experience weather data through a beautiful, modern interface with sleek light & dark themes.',
                      ),
                    ],
                  ),
                ),

                // --- Bottom Controls ---
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                  child: Column(
                    children: [
                      Obx(
                        () => AnimatedSmoothIndicator(
                          activeIndex: controller.currentPage.value,
                          count: 3,
                          effect: ExpandingDotsEffect(
                            activeDotColor: theme.primaryColor,
                            dotColor: Colors.white.withOpacity(0.5),
                            dotWidth: 10.w,
                            dotHeight: 10.h,
                          ),
                        ),
                      ),
                      30.verticalSpace,
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 56.h),
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          elevation: 8,
                          shadowColor: theme.primaryColor.withOpacity(0.5),
                        ),
                        onPressed: () => Get.offNamed(Routes.HOME),
                        child: Text(
                          Strings.getStarted.tr,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      20.verticalSpace,
                    ],
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(
                    begin: 0.2, duration: 500.ms, curve: Curves.easeOutCubic),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Reusable Page Widget for Onboarding ---
class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Glassmorphism Icon Container
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, size: 60.sp, color: theme.primaryColor),
            ),
          ),
        ),
        40.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        16.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.w),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).scale(
        begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
  }
}