import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../config/theme/theme_extensions/shimmer_theme_data.dart';

class ShimmerWidget extends StatelessWidget {
  final double width;
  final double? height;
  final double? cornerRadius;
  final bool? isCircle;

  const ShimmerWidget.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.cornerRadius = 6.0,
    this.isCircle = false,
  });

  const ShimmerWidget.circular({
    super.key,
    required this.width,
    this.height,
    this.cornerRadius,
    this.isCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    final shimmerTheme = Theme.of(context).extension<ShimmerThemeData>()!;
    return Shimmer.fromColors(
      baseColor: shimmerTheme.baseColor!,
      highlightColor: shimmerTheme.highlightColor!,
      child: Container(
        width: width,
        height: height ?? width, // Use width as fallback for height if not provided for circular
        decoration: BoxDecoration(
          color: shimmerTheme.backgroundColor,
          shape: isCircle ?? false ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ?? false ? null : BorderRadius.circular(cornerRadius ?? 6.0),
        ),
      ),
    );
  }
}
