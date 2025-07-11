// lib/app/modules/home/controllers/home_controller.dart

import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';
// ✨ FIX: Added missing import for CarouselPageChangedReason
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
  List<String> worldCityNames = [];

  // Carousel Cards
  // Card 0: User Location, Card 1: Custom City 1, Card 2: Custom City 2
  List<WeatherModel?> weatherCards = List.filled(3, null);

  // ✨ FIX: Renamed to match view's expectation (camelCase)
  List<WeatherModel> weatherAroundTheWorld = [];

  final dotIndicatorsId = 'DotIndicators';
  final themeId = 'Theme';

  ApiCallStatus apiCallStatus = ApiCallStatus.loading;
  var isLightTheme = MySharedPref.getThemeIsLight();
  var activeIndex = 0;

  // Persisted city names for the carousel
  late String card1CityName;
  late String card2CityName;

  @override
  void onInit() {
    super.onInit();
    _updateTime();
    Timer.periodic(1.seconds, (_) => _updateTime());

    // Load persisted cities or use defaults
    card1CityName = MySharedPref.getCard1City();
    card2CityName = MySharedPref.getCard2City();

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

  // ✨ FIX: This is the public method to be called by the view for retries.
  Future<void> refreshAllData() async {
    apiCallStatus = ApiCallStatus.loading;
    update();

    final locationData = await LocationService().getUserLocation();
    if (locationData == null) {
      apiCallStatus = ApiCallStatus.error;
      update();
      return;
    }
    final userLocationString =
        '${locationData.latitude},${locationData.longitude}';

    // Fetch all data points.
    // The Future.wait approach was good but requires changing BaseClient.
    // This sequential approach is simpler and still fast enough.
    await _fetchWeather(userLocationString, 0);
    await _fetchWeather(card1CityName, 1);
    await _fetchWeather(card2CityName, 2);
    await _fetchAroundTheWorldWeather(); // Fetch the separate list

    apiCallStatus = ApiCallStatus.success;
    update();
  }

  /// Helper to fetch weather for a single card in the carousel
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
        // If a city fails, we can show a placeholder or an error state on the card
        weatherCards[cardIndex] = null; // Or a custom error model
        BaseClient.handleApiError(error);
      },
    );
  }

  /// Fetches the list of cities for the "Around the World" section
  Future<void> _fetchAroundTheWorldWeather() async {
    weatherAroundTheWorld.clear();
    final cities = ['Tokyo', 'Sydney', 'Moscow', 'New York'];
    await Future.forEach(cities, (city) async {
      await BaseClient.safeApiCall(
        Constants.currentWeatherApiUrl,
        RequestType.get,
        queryParameters: {
          Constants.key: Constants.apiKey,
          Constants.q: city,
          Constants.lang: currentLanguage,
        },
        onSuccess: (response) {
          weatherAroundTheWorld.add(WeatherModel.fromJson(response.data));
        },
        onError: (e) {
          // You can decide to skip a city if it fails
          print("Failed to load weather for $city");
        },
      );
    });
  }

  /// Updates a single card when the user changes a city in the dialog.
  Future<void> updateWeatherForCard(String location, int cardIndex) async {
    if (cardIndex < 0 || cardIndex >= 3) return; // Guard clause

    // Show a loading indicator on the specific card
    weatherCards[cardIndex] = null;
    update();

    await _fetchWeather(location, cardIndex);

    // Persist the new city name if it's not the user's location card
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

  // Add new RxBool to track editing state
  final isEditingWorldList = false.obs;

  // Toggle editing mode for the world list
  void toggleWorldListEditing() {
    isEditingWorldList.value = !isEditingWorldList.value;
  }

      void removeCityFromWorldList(int index) {
      if (index >= 0 && index < weatherAroundTheWorld.length) {
        weatherAroundTheWorld.removeAt(index);
        update(); // Notify listeners to refresh the UI
      }
    }


    void reorderWorldList(int oldIndex, int newIndex) {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final WeatherModel item = weatherAroundTheWorld.removeAt(oldIndex);
      weatherAroundTheWorld.insert(newIndex, item);
    }

  // Callback when add city button is pressed
  void onAddCityPressed() {
    // Logic to handle adding a new city
    Get.dialog(const AddCityDialog());
  }

  Future<void> addCityToWorldList(String cityName) async {
    final trimmedCity = cityName.trim();
    if (trimmedCity.isEmpty ||
        worldCityNames.any(
          (c) => c.toLowerCase() == trimmedCity.toLowerCase(),
        )) {
      Get.snackbar(
        'Error',
        'City name cannot be empty or a duplicate.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Reorder the world weather list

    // Removes a city from the weatherAroundTheWorld list.

  }
}
