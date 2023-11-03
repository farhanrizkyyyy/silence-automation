import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:silence_automation/modules/home/controllers/home_controller.dart';
import 'package:silence_automation/widgets/primary_appbar.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // appBar: _buildAppbar(),
        body: _buildBody(),
        floatingActionButton: _buildFab(),
      ),
    );
  }

  AppBar _buildAppbar() => PrimaryAppbar();

  Widget _buildBody() => Center(
        child: Obx(
          () {
            if (controller.permission.value == LocationPermission.always ||
                controller.permission.value == LocationPermission.whileInUse) {
              return OSMFlutter(
                controller: controller.mapController,
                osmOption: OSMOption(
                  markerOption: MarkerOption(
                    defaultMarker: const MarkerIcon(
                      icon: Icon(Icons.location_on),
                    ),
                  ),
                  userLocationMarker: UserLocationMaker(
                    personMarker: const MarkerIcon(
                      icon: Icon(Icons.location_on),
                    ),
                    directionArrowMarker: const MarkerIcon(
                      icon: Icon(Icons.location_on),
                    ),
                  ),
                  zoomOption: const ZoomOption(
                    initZoom: 2.5,
                  ),
                ),
                onGeoPointClicked: (point) => log('$point'),
                onLocationChanged: (point) {
                  log('$point');
                },
              );
            } else if (controller.permission.value ==
                    LocationPermission.denied ||
                controller.permission.value ==
                    LocationPermission.deniedForever) {
              return _buildPermissionNotGranted();
            } else {
              return Container();
            }
          },
        ),
      );

  Widget _buildPermissionNotGranted() => Center(
        child: Column(
          children: [
            Text(
              'We can\'t detect your location to calculate the distance between you & Iqomah Mosque unless location permission is granted.',
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.sp),
            ElevatedButton(
              onPressed: () async =>
                  await controller.requestLocationPermission(),
              child: const Text('Request Location Permission'),
            ),
          ],
        ),
      );

  Widget _buildFab() => FloatingActionButton(
        onPressed: () async => await controller.getDeviceCoordinate(),
        child: const Icon(Icons.my_location),
      );
}
