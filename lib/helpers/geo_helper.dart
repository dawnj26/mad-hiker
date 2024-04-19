import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeoHelper {
  static const apiKey = '4101f66de8cb687960eda67b5eb4a621';

  static Future<bool> isPermissionGranted() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return false;
    }

    return true;
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  static Future<Position> _determinePosition() async {
    bool serviceEnabled;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    if (!await isPermissionGranted()) {
      return Future.error('Location permissions are denied');
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  static Future<Map<String, dynamic>> getLocationDetails() async {
    final pos = await _determinePosition();
    final placeMark =
        await placemarkFromCoordinates(pos.latitude, pos.longitude);
    final weatherData = await getWeatherDetails(pos.longitude, pos.latitude);
    final iconUrl =
        'https://openweathermap.org/img/wn/${weatherData['weather'][0]['icon']}@4x.png';
    final p = placeMark.first;

    final place =
        '${p.street} ${p.locality}, ${p.subAdministrativeArea}, ${p.administrativeArea}, ${p.country}';

    final Map<String, dynamic> res = {
      'place': place,
      'locality': p.locality,
      'weather': {
        'temp': weatherData['main']['temp'],
        'feels_like': weatherData['main']['feels_like'],
        'humidity': weatherData['main']['humidity'],
        'type': weatherData['weather'][0]['main'],
        'icon': iconUrl,
      },
      'longitude': pos.longitude,
      'latitude': pos.latitude,
      'altitude': pos.altitude,
      'accuracy': pos.accuracy,
    };

    return res;
  }

  static Future<dynamic> getWeatherDetails(
      double longitude, double latitude) async {
    final opt = BaseOptions(
      baseUrl: 'https://api.openweathermap.org',
    );
    final dio = Dio(opt);

    final response = await dio.get(
      '/data/2.5/weather',
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'appid': apiKey,
      },
    );

    return response.data;
  }
}
