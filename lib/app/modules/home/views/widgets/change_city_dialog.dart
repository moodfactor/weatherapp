
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:weatherapp/config/translations/strings_enum.dart';
import '../../controllers/home_controller.dart';

class ChangeCityDialog extends GetView<HomeController> {
  final int cardIndex;
  const ChangeCityDialog({
    Key? key,
    required this.cardIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(Strings.enterCityName.tr),
      content: TextField(
        onSubmitted: (city) {
          controller.getCurrentWeather(city, cardIndex);
          Get.back();
        },
      ),
    );
  }
}
