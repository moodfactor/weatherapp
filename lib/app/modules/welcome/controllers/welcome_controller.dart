import 'package:flutter/material.dart';
import 'package:get/get.dart';
// No longer need video_player import here

class WelcomeController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;

  // The videoController is GONE from here.

  @override
  void onInit() {
    super.onInit();
    // No video initialization needed.
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }
}