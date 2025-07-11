import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart'; // Import for VideoPlayerController

class BackgroundVideoService extends GetxService {
  // Make the controller accessible
  late VideoPlayerController videoController;

  // Use a RxBool to track initialization, so widgets can react to it.
  final isInitialized = false.obs;

  // This method will be called when the service is first initialized.
  Future<void> init() async {
    videoController = VideoPlayerController.asset('assets/videos/plexus_background.mp4');

    try {
      await videoController.initialize();
      videoController.play();
      videoController.setLooping(true);
      isInitialized.value = true;
      print("✅ BackgroundVideoService Initialized Successfully");
    } catch (e) {
      // Use kDebugMode to only print errors during development
      if (kDebugMode) {
        print("❌ Error initializing background video: $e");
      }
    }
  }

  @override
  void onClose() {
    // This is called when the app is closed, ensuring proper disposal.
    print("Disposing BackgroundVideoService...");
    videoController.dispose();
    super.onClose();
  }
}