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

class HomeController extends GetxController with GetTickerProviderStateMixin {
  var _permission = Rxn<PermissionStatus>();
  var _deviceCoordinate = Rxn<LatLng>();

  late LocationSettings _locationSettings;
  late StreamSubscription<Position> _streamPosition;
  late AnimatedMapController _animatedMapController;
  late fm.MapOptions _mapOptions;

  LatLng? _coordinateTomove;

  RxBool _isTracking = true.obs;

  AnimatedMapController get animatedMapController => _animatedMapController;
  fm.MapOptions get mapOptions => _mapOptions;
  Rxn<PermissionStatus> get permission => _permission;
  Rxn<LatLng> get deviceCoordinate => _deviceCoordinate;
  RxBool get isTracking => _isTracking;

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
      initialZoom: 20,
    );

    await requestLocationPermission();

    _locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    _streamPosition = Geolocator.getPositionStream(
      locationSettings: _locationSettings,
    ).listen((position) {
      _coordinateTomove = LatLng(
        position.latitude,
        position.longitude,
      );
      _moveMap(_coordinateTomove!);
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

    log('$locationPermission');
    permission.value = locationPermission;

    if (locationPermission == PermissionStatus.granted) {
      await getDeviceCoordinate();
    }
  }

  getDeviceCoordinate() async {
    var position = await Geolocator.getCurrentPosition();
    var latLong = LatLng(
      position.latitude,
      position.longitude,
    );

    _moveMap(latLong);
    log('POSITION ${_deviceCoordinate.value}');
  }

  _setMarkerCoordinate(LatLng? coordinate) {
    _deviceCoordinate.value = LatLng(
      coordinate?.latitude ?? 0,
      coordinate?.longitude ?? 0,
    );

    _coordinateTomove = _deviceCoordinate.value;
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

  void _moveMap(LatLng coordinate) {
    _setMarkerCoordinate(coordinate);

    const startedId = 'AnimatedMapController#MoveStarted';
    const inProgressId = 'AnimatedMapController#MoveInProgress';
    const finishedId = 'AnimatedMapController#MoveFinished';
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final camera = _animatedMapController.mapController.camera;
    final latTween =
        Tween<double>(begin: camera.center.latitude, end: coordinate.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: coordinate.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: 20);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    // Note this method of encoding the target destination is a workaround.
    // When proper animated movement is supported (see #1263) we should be able
    // to detect an appropriate animated movement event which contains the
    // target zoom/center.
    final startIdWithTarget =
        '$startedId#${coordinate.latitude},${coordinate.longitude},20';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = inProgressId;
      }

      hasTriggeredMove |= _animatedMapController.mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }
}
