import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'shimmer_widget.dart';

class HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    // ✨ ENHANCEMENT: Use CustomScrollView to match the success widget's layout
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(), // Disable scrolling during shimmer
      slivers: [
        // Shimmer for _HomeAppBar
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 10.h).copyWith(top: 40.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ShimmerWidget.rectangular(width: 80, height: 20),
                      8.verticalSpace,
                      const ShimmerWidget.rectangular(width: 120, height: 24),
                    ],
                  ),
                ),
                const ShimmerWidget.circular(width: 48, height: 48),
                8.horizontalSpace,
                const ShimmerWidget.circular(width: 48, height: 48),
              ],
            ),
          ),
        ),

        // Shimmer for Carousel and Dots
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                24.verticalSpace,
                ShimmerWidget.circular(
                  width: double.infinity,
                  height: 190.h,
                  isCircle: false,
                ),
                16.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ShimmerWidget.circular(width: 10.w, height: 10.h),
                  )),
                ),
              ],
            ),
          ),
        ),

        // Shimmer for "Around the world" section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 24.h),
            child: ShimmerWidget.rectangular(width: 200.w, height: 28.h),
          ),
        ),

        // Shimmer for CompactWeatherListTile list
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 26.w),
          sliver: SliverList.separated(
            itemCount: 4, // Show a few placeholder tiles
            separatorBuilder: (context, index) => 16.verticalSpace,
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: ShimmerWidget.rectangular(
                height: 75.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}