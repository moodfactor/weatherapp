import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class WelcomeController extends GetxController {
  // Controller for the PageView
  final PageController pageController = PageController();
  // To track the current page index
  final RxInt currentPage = 0.obs;

  // Video player controller for the background
  late VideoPlayerController videoController;

  @override
  void onInit() {
    super.onInit();
    // Initialize the video player
    videoController = VideoPlayerController.asset('assets/videos/plexus_background.mp4')
      ..initialize().then((_) {
        // Ensure the first frame is shown and then play the video, looping it.
        videoController.play();
        videoController.setLooping(true);
        update(); // Update the UI to show the video
      });
  }

  @override
  void onClose() {
    // Dispose of the controllers to free up resources
    pageController.dispose();
    videoController.dispose();
    super.onClose();
  }

  // Method to update the current page when the user swipes
  void onPageChanged(int index) {
    currentPage.value = index;
  }
}