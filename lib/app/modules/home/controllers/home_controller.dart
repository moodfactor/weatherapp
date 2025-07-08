import 'package:get/get.dart';

import '../../../../config/theme/my_theme.dart';
import '../../../../config/translations/localization_service.dart';
import '../../../../utils/constants.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../../data/models/weather_model.dart';
import '../../../services/api_call_status.dart';
import '../../../services/base_client.dart';
import '../../../services/location_service.dart';
import '../views/widgets/location_dialog.dart';
import '../views/widgets/change_city_dialog.dart';

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  // get the current language code
  var currentLanguage = LocalizationService.getCurrentLocal().languageCode;

  // hold current weather data
  late WeatherModel currentWeather;

  // hold the weather for the three cards
  List<WeatherModel?> weatherCards = List.filled(3, null);

  // hold the weather arround the world
  List<WeatherModel> weatherArroundTheWorld = [];

  // for update
  final dotIndicatorsId = 'DotIndicators';
  final themeId = 'Theme';

  // api call status
  ApiCallStatus apiCallStatus = ApiCallStatus.loading;

  // for app theme
  var isLightTheme = MySharedPref.getThemeIsLight();
  
  // for weather slider and dot indicator
  var activeIndex = 1;

  @override
  void onInit() async {
    if (!await LocationService().hasLocationPermission()) {
      Get.dialog(const LocationDialog());
    } else {
      getUserLocation();
    }
    getCurrentWeather('London', 1);
    getCurrentWeather('Cairo', 2);
    super.onInit();
  }

  /// get the user location
  getUserLocation() async {
    var locationData = await LocationService().getUserLocation();
    if (locationData != null) {
      await getCurrentWeather('${locationData.latitude},${locationData.longitude}', 0);
    }
  }
  
  /// get home screem data (sliders, brands, and cars)
  getCurrentWeather(String location, int cardIndex) async {
    await BaseClient.safeApiCall(
      Constants.currentWeatherApiUrl,
      RequestType.get,
      queryParameters: {
        Constants.key: Constants.apiKey,
        Constants.q: location,
        Constants.lang: currentLanguage,
      },
      onSuccess: (response) async {
        if (cardIndex < 3) {
          weatherCards[cardIndex] = WeatherModel.fromJson(response.data);
          if (cardIndex == 0) {
            currentWeather = weatherCards[0]!;
            await getWeatherArroundTheWorld();
          }
        } else { // cardIndex >= 3
          final int actualIndex = cardIndex - 3;
          if (actualIndex >= 0 && actualIndex < weatherArroundTheWorld.length) {
            // Update existing city
            weatherArroundTheWorld[actualIndex] = WeatherModel.fromJson(response.data);
          } else {
            // This case should ideally not be reached if UI is built correctly.
            // If it is, it means we're trying to update a non-existent "Around the World" card.
            // For now, we'll add it to the end, but this might indicate a logic flaw elsewhere.
            // A more robust solution might involve a different way to manage "Around the World" cities.
            weatherArroundTheWorld.add(WeatherModel.fromJson(response.data));
          }
        }
        apiCallStatus = ApiCallStatus.success;
        update();
      },
      onError: (error) {
        BaseClient.handleApiError(error);
        apiCallStatus = ApiCallStatus.error;
        update();
      },
    );
  }

  /// get weather arround the world
  getWeatherArroundTheWorld() async {
    weatherArroundTheWorld.clear();
    final cities = ['London', 'Cairo', 'Alaska'];
    await Future.forEach(cities, (city) {
      BaseClient.safeApiCall(
        Constants.currentWeatherApiUrl,
        RequestType.get,
        queryParameters: {
          Constants.key: Constants.apiKey,
          Constants.q: city,
          Constants.lang: currentLanguage,
        },
        onSuccess: (response) {
          weatherArroundTheWorld.add(WeatherModel.fromJson(response.data));
          update();
        },
        onError: (error) => BaseClient.handleApiError(error),
      );
    });
  }

  /// when the user slide the weather card
  onCardSlided(index, reason) {
    activeIndex = index;
    update([dotIndicatorsId]);
  }

  /// when the user wants to change the city of a card
  changeCity(int cardIndex) {
    Get.dialog(
      ChangeCityDialog(
        cardIndex: cardIndex,
      ),
    );
  }

  /// when the user press on change theme icon
  onChangeThemePressed() {
    MyTheme.changeTheme();
    isLightTheme = MySharedPref.getThemeIsLight();
    update([themeId]);
  }
  
  /// when the user press on change language icon
  onChangeLanguagePressed() async {
    currentLanguage = currentLanguage == 'ar' ? 'en' : 'ar';
    await LocalizationService.updateLanguage(currentLanguage);
    apiCallStatus = ApiCallStatus.loading;
    update();
    await getUserLocation();
    for (int i = 1; i < weatherCards.length; i++) {
      if (weatherCards[i] != null) {
        await getCurrentWeather(weatherCards[i]!.location!.name!, i);
      }
    }
  }
}