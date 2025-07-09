import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:weatherapp/app/modules/home/views/widgets/add_city_dialog.dart';

import '../../../../config/theme/my_theme.dart';
import '../../../../config/translations/localization_service.dart';
import '../../../../utils/constants.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../data/models/weather_model.dart';
import '../../../services/api_call_status.dart';
import '../../../services/base_client.dart';
import '../../../services/location_service.dart';
import '../views/widgets/location_dialog.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  var currentLanguage = LocalizationService.getCurrentLocal().languageCode;
  final currentTime = ''.obs;

  // Carousel Cards
  List<WeatherModel?> weatherCards = List.filled(3, null);
  late String card1CityName;
  late String card2CityName;

  // "Around the World" List - now fully dynamic
  List<WeatherModel> weatherAroundTheWorld = [];
  List<String> worldCityNames = [];

  // State Management
  final dotIndicatorsId = 'DotIndicators';
  final themeId = 'Theme';
  ApiCallStatus apiCallStatus = ApiCallStatus.loading;
  var isLightTheme = MySharedPref.getThemeIsLight();
  var activeIndex = 0;
  RxBool isEditingWorldList = false.obs; // To toggle editing mode

  @override
  void onInit() {
    super.onInit();
    _updateTime();
    Timer.periodic(1.seconds, (_) => _updateTime());

    // Load persisted cities
    card1CityName = MySharedPref.getCard1City();
    card2CityName = MySharedPref.getCard2City();
    worldCityNames = MySharedPref.getWorldCities();

    _initiateDataLoad();
  }

  void _updateTime() {
    currentTime.value = DateFormat.jm().format(DateTime.now());
  }

  Future<void> _initiateDataLoad() async {
    if (!await LocationService().hasLocationPermission()) {
      Get.dialog(const LocationDialog(), barrierDismissible: false);
    } else {
      await refreshAllData();
    }
  }

  Future<void> refreshAllData() async {
    apiCallStatus = ApiCallStatus.loading;
    update();

    final locationData = await LocationService().getUserLocation();
    if (locationData == null) {
      apiCallStatus = ApiCallStatus.error;
      update();
      return;
    }
    final userLocationString = '${locationData.latitude},${locationData.longitude}';

    await _fetchWeather(userLocationString, 0);
    await _fetchWeather(card1CityName, 1);
    await _fetchWeather(card2CityName, 2);
    await _fetchAroundTheWorldWeather();

    apiCallStatus = ApiCallStatus.success;
    update();
  }

  Future<void> _fetchWeather(String location, int cardIndex) async {
    await BaseClient.safeApiCall(
      Constants.currentWeatherApiUrl,
      RequestType.get,
      queryParameters: {
        Constants.key: Constants.apiKey,
        Constants.q: location,
        Constants.lang: currentLanguage,
      },
      onSuccess: (response) {
        weatherCards[cardIndex] = WeatherModel.fromJson(response.data);
      },
      onError: (error) {
        weatherCards[cardIndex] = null;
        BaseClient.handleApiError(error);
      },
    );
  }

  Future<void> _fetchAroundTheWorldWeather() async {
    weatherAroundTheWorld.clear();
    if (worldCityNames.isEmpty) return;

    List<WeatherModel> fetchedWeather = [];
    for (var city in worldCityNames) {
      await BaseClient.safeApiCall(
        Constants.currentWeatherApiUrl,
        RequestType.get,
        queryParameters: {
          Constants.key: Constants.apiKey,
          Constants.q: city,
          Constants.lang: currentLanguage,
        },
        onSuccess: (response) {
          fetchedWeather.add(WeatherModel.fromJson(response.data));
        },
      );
    }
    weatherAroundTheWorld = fetchedWeather;
  }

  Future<void> updateWeatherForCard(String location, int cardIndex) async {
    if (cardIndex <= 0 || cardIndex >= 3) return;

    weatherCards[cardIndex] = null;
    update();

    await _fetchWeather(location, cardIndex);

    if (cardIndex == 1) {
      MySharedPref.setCard1City(location);
      card1CityName = location;
    } else if (cardIndex == 2) {
      MySharedPref.setCard2City(location);
      card2CityName = location;
    }
    update();
  }

  void onCardSlided(int index, CarouselPageChangedReason reason) {
    activeIndex = index;
    update([dotIndicatorsId]);
  }

  void onChangeThemePressed() {
    MyTheme.changeTheme();
    isLightTheme = MySharedPref.getThemeIsLight();
    update([themeId]);
  }

  Future<void> onChangeLanguagePressed() async {
    currentLanguage = currentLanguage == 'ar' ? 'en' : 'ar';
    await LocalizationService.updateLanguage(currentLanguage);
    await refreshAllData();
  }

  // --- Methods for "Around the World" List Management ---

  void toggleWorldListEditing() {
    isEditingWorldList.value = !isEditingWorldList.value;
  }

  void onAddCityPressed() {
    Get.dialog(const AddCityDialog());
  }

  Future<void> addCityToWorldList(String cityName) async {
    final trimmedCity = cityName.trim();
    if (trimmedCity.isEmpty || worldCityNames.any((c) => c.toLowerCase() == trimmedCity.toLowerCase())) {
      Get.snackbar('Error', 'City name cannot be empty or a duplicate.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    worldCityNames.add(trimmedCity);
    await MySharedPref.setWorldCities(worldCityNames);

    await BaseClient.safeApiCall(
      Constants.currentWeatherApiUrl,
      RequestType.get,
      queryParameters: {
        Constants.key: Constants.apiKey,
        Constants.q: trimmedCity,
        Constants.lang: currentLanguage,
      },
      onSuccess: (response) {
        weatherAroundTheWorld.add(WeatherModel.fromJson(response.data));
        update();
      },
      onError: (e) {
        // If adding fails, remove it back from the list
        worldCityNames.remove(trimmedCity);
        MySharedPref.setWorldCities(worldCityNames);
        Get.snackbar('Error', 'Could not find weather for "$trimmedCity".',
            snackPosition: SnackPosition.BOTTOM);
      },
    );
  }

  Future<void> removeCityFromWorldList(int index) async {
    if (index < 0 || index >= worldCityNames.length) return;

    worldCityNames.removeAt(index);
    weatherAroundTheWorld.removeAt(index);
    await MySharedPref.setWorldCities(worldCityNames);
    update();
  }

  Future<void> reorderWorldList(int oldIndex, int newIndex) async {
    // This correction is needed for ReorderableListView's logic
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final String city = worldCityNames.removeAt(oldIndex);
    worldCityNames.insert(newIndex, city);

    final WeatherModel weather = weatherAroundTheWorld.removeAt(oldIndex);
    weatherAroundTheWorld.insert(newIndex, weather);

    await MySharedPref.setWorldCities(worldCityNames);
    update();
  }
}