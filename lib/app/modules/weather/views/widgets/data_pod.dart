import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DataPod extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const DataPod({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.primaryColor, size: 20.sp),
                8.horizontalSpace,
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
            12.verticalSpace,
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}