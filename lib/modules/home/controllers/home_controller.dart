// ignore_for_file: prefer_final_fields

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:silence_automation/constants/values.dart';
import 'package:silence_automation/utils/functions.dart';

class HomeController extends GetxController with GetTickerProviderStateMixin {
  final double _zoom = 19;
  final LatLng _targetCoordinate = const LatLng(
    Constants.targetLatitude,
    Constants.targetLongitude,
  );

  var _permission = Rxn<PermissionStatus>();
  var _deviceCoordinate = Rxn<LatLng>();

  late StreamSubscription<Position> _streamPosition;
  late AnimatedMapController _animatedMapController;
  late fm.MapOptions _mapOptions;

  RxBool _isTracking = true.obs;
  RxDouble _currentDistance = 0.0.obs;

  AnimatedMapController get animatedMapController => _animatedMapController;
  fm.MapOptions get mapOptions => _mapOptions;
  LatLng get targetCoordinate => _targetCoordinate;

  Rxn<PermissionStatus> get permission => _permission;
  Rxn<LatLng> get deviceCoordinate => _deviceCoordinate;
  RxBool get isTracking => _isTracking;
  RxDouble get currentDistance => _currentDistance;

  @override
  void onInit() async {
    _animatedMapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );

    _mapOptions = fm.MapOptions(
      initialCenter: LatLng(
        _deviceCoordinate.value?.latitude ?? 0,
        _deviceCoordinate.value?.longitude ?? 0,
      ),
      initialZoom: _zoom,
      interactionOptions: const fm.InteractionOptions(
        flags: fm.InteractiveFlag.pinchZoom | fm.InteractiveFlag.drag,
      ),
    );

    await requestLocationPermission();

    _streamPosition = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    ).listen((position) {
      _deviceCoordinate.value = LatLng(
        position.latitude,
        position.longitude,
      );

      _setMarkerCoordinate(_deviceCoordinate.value!);

      currentDistance.value = Functions.haversine(
        deviceCoordinate.value!,
        targetCoordinate,
      ).toPrecision(3);
    });

    super.onInit();
  }

  @override
  void dispose() {
    _animatedMapController.dispose();
    _streamPosition.cancel();
    super.dispose();
  }

  requestLocationPermission() async {
    var locationPermission = await Permission.location.request();
    _permission.value = locationPermission;

    if (locationPermission == PermissionStatus.granted) {
      await getDeviceCoordinate();
    }
  }

  getDeviceCoordinate() async {
    var position = await Geolocator.getCurrentPosition();
    _deviceCoordinate.value = LatLng(
      position.latitude,
      position.longitude,
    );

    _animatedMapController.animateTo(
      dest: _deviceCoordinate.value,
      curve: Curves.easeIn,
      zoom: _zoom,
    );

    _setMarkerCoordinate(_deviceCoordinate.value!);

    log('DEVICE COORDINATE ${_deviceCoordinate.value}');
    log('TARGET COORDINATE $_targetCoordinate');

    currentDistance.value = Functions.haversine(
      deviceCoordinate.value!,
      targetCoordinate,
    ).toPrecision(3);

    log('DISTANCE: ${currentDistance.value} m');
  }

  _setMarkerCoordinate(LatLng coordinate) {
    _deviceCoordinate.value = LatLng(
      coordinate.latitude,
      coordinate.longitude,
    );

    _animatedMapController.animateTo(
      dest: _deviceCoordinate.value,
      curve: Curves.easeIn,
      zoom: _zoom,
    );
  }

  pauseTracking() {
    if (_isTracking.value) {
      _streamPosition.pause();
      _isTracking.value = false;
    } else {
      _streamPosition.resume();
      _isTracking.value = true;
    }
  }
}
