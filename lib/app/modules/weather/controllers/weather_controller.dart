import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/custom_loading_overlay.dart';
import '../../../../utils/extensions.dart';
import '../../../../config/translations/localization_service.dart';
import '../../../../config/translations/strings_enum.dart';
import '../../../../utils/constants.dart';
import '../../../data/models/weather_details_model.dart';
import '../../../data/models/weather_model.dart';
import '../../../services/api_call_status.dart';
import '../../../services/base_client.dart';

class WeatherController extends GetxController {
  static WeatherController get instance => Get.find();

  // get the current language code
  final currentLanguage = LocalizationService.getCurrentLocal().languageCode;

  // hold the weather details & forecast day
  WeatherDetailsModel? weatherDetails;
  Forecastday? forecastday;

  // for update
  final dotIndicatorsId = 'DotIndicators';
  
  // for weather forecast
  final days = 3;
  //var selectedDay = 'Today';
  var selectedDay = Strings.today.tr;

  // api call status
  ApiCallStatus apiCallStatus = ApiCallStatus.holding;

  // for weather card slider
  late PageController pageController;
  
  // for weather slider and dot indicator
  var currentPage = 0;

  @override
  void onInit() async {
    pageController = PageController(
      initialPage: currentPage, viewportFraction: 0.8,
    );
    super.onInit();
  }
  
  @override
  void onReady() {
    getWeatherDetails();
    super.onReady();
  }

  /// get current language
  bool get isEnLang => currentLanguage == 'en';

  /// get weather details
  getWeatherDetails() async {
    if (Get.arguments == null || Get.arguments is! WeatherModel) {
      apiCallStatus = ApiCallStatus.error;
      update();
      return;
    }

    final weatherModel = Get.arguments as WeatherModel;

    await showLoadingOverLay(
      asyncFunction: () async => await BaseClient.safeApiCall(
        Constants.forecastWeatherApiUrl,
        RequestType.get,
        queryParameters: {
          Constants.key: Constants.apiKey,
          Constants.q: '${weatherModel.location.lat},${weatherModel.location.lon}',
          Constants.days: days,
          Constants.lang: currentLanguage,
        },
        onSuccess: (response) {
          weatherDetails = WeatherDetailsModel.fromJson(response.data);
          if (weatherDetails?.forecast?.forecastday?.isEmpty ?? true) {
            apiCallStatus = ApiCallStatus.error;
          } else {
            forecastday = weatherDetails!.forecast!.forecastday![0];
            apiCallStatus = ApiCallStatus.success;
          }
          update();
        },
        onError: (error) {
          BaseClient.handleApiError(error);
          apiCallStatus = ApiCallStatus.error;
          update();
        },
      ),
    );
  }

  /// when the user change the selected day
  onDaySelected(String day) {
    selectedDay = day;
    var index = weatherDetails?.forecast?.forecastday?.indexWhere((fd) {
      return fd.date.convertToDay() == day;
    }) ?? -1;

    if (index >= 0) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
      onCardSlided(index);
    }
  }

  /// when the user slide the weather card
  onCardSlided(int index) {
    if (index >= 0 && index < (weatherDetails?.forecast?.forecastday?.length ?? 0)) {
      forecastday = weatherDetails?.forecast?.forecastday?[index];
      selectedDay = forecastday?.date.convertToDay() ?? selectedDay;
      currentPage = index;
      update();
    }
  }
}
