import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class PlaceDetails {
  final String? city;
  final String? province;
  final String? country;

  PlaceDetails({
    this.city,
    this.province,
    this.country,
  });

  @override
  String toString() {
    return 'PlaceDetails(city: $city, province: $province, country: $country)';
  }
}

class LocationService {
  // --- Singleton Setup ---
  LocationService._internal();

  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  Future<Position> getCurrentLocation() async {
    var status = await Permission.location.status;

    if (status.isDenied) {
      // If permission is denied, request it.
      status = await Permission.location.request();
      if (status.isDenied) {
        // User denied the permission.
        return Future.error('Location permissions are denied.');
      }
    }

    if (status.isPermanentlyDenied) {
      // User has permanently denied the permission.
      // We should guide them to the app settings.
      // openAppSettings();
      return Future.error('Location permissions are permanently denied. Please enable them in app settings.');
    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled.
      return Future.error('Location services are disabled.');
    }

    LocationSettings locationSettings;

    if (defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 20));
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        // distanceFilter: 10,
        pauseLocationUpdatesAutomatically: true,
        showBackgroundLocationIndicator: false,
        timeLimit: Duration(seconds: 20),
      );
    } else {
      locationSettings = LocationSettings(accuracy: LocationAccuracy.high);
    }

    try {
      Position position = await Geolocator.getCurrentPosition(locationSettings: locationSettings);

      return position;
    } on TimeoutException {
      // Handle timeout.
      return Future.error('Location request timed out. Could not fetch location.');
    } catch (e) {
      // Handle other potential errors.
      return Future.error('An unknown error occurred: ${e.toString()}');
    }
  }

  Future<PlaceDetails> getPlaceDetails(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];

        return PlaceDetails(
          city: place.locality,
          province: place.administrativeArea,
          country: place.country,
        );
      } else {
        return Future.error('Could not determine address for the location.');
      }
    } catch (e) {
      // Handle potential errors from the geocoding service.
      return Future.error('Failed to get place details: ${e.toString()}');
    }
  }
}
