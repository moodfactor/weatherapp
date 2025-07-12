import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../utils/constants.dart';

class LoadingView extends StatefulWidget {
  const LoadingView({Key? key}) : super(key: key);

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  final List<String> _loadingMessages = [
    "Gazing at the clouds...",
    "Calibrating the anemometer...",
    "Consulting the weather spirits...",
    "Tasting the air for humidity...",
    "Chasing the sun for a forecast...",
    "Decoding the whispers of the wind...",
    "Measuring the fluffiness of clouds...",
  ];

  late String _currentMessage;

  @override
  void initState() {
    super.initState();
    _currentMessage = _loadingMessages[Random().nextInt(_loadingMessages.length)];
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: Lottie.asset(Constants.weatherAnimation),
            ),
            const SizedBox(height: 20),
            Text(
              _currentMessage,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 600.ms),
          ],
        ),
      ),
    );
  }
}
