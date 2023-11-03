import 'dart:developer';

import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var permission = Rxn<LocationPermission>();
  Rx<Position> deviceCoordinate = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  ).obs;
  MapController mapController = MapController(
    initPosition: GeoPoint(
      latitude: 0,
      longitude: 0,
    ),
    areaLimit: BoundingBox(
      east: 10.4922941,
      north: 47.8084648,
      south: 45.817995,
      west: 5.9559113,
    ),
  );

  @override
  void onInit() async {
    permission.value = await Geolocator.checkPermission();

    if (permission.value == LocationPermission.denied) {
      await requestLocationPermission();
    }
    super.onInit();
  }

  requestLocationPermission() async {
    var locationPermission = await Geolocator.requestPermission();

    log('$locationPermission');

    if (locationPermission == LocationPermission.always ||
        locationPermission == LocationPermission.whileInUse) {
      permission.value = locationPermission;
      await getDeviceCoordinate();
    } else {
      await Geolocator.requestPermission();
    }
  }

  getDeviceCoordinate() async {
    deviceCoordinate.value = await Geolocator.getCurrentPosition();
    GeoPoint devicePoint = GeoPoint(
      latitude: deviceCoordinate.value.latitude,
      longitude: deviceCoordinate.value.longitude,
    );
    // mapController.setMarkerIcon(
    //   devicePoint,
    //   const MarkerIcon(
    //     icon: Icon(Icons.location_on),
    //   ),
    // );
    await mapController.goToLocation(devicePoint);
    await mapController.setZoom(
      zoomLevel: 16,
      stepZoom: 5,
    );
    log('POSITION ${deviceCoordinate.value}');
  }
}
