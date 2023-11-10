// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:silence_automation/constants/pallete.dart';
import 'package:silence_automation/constants/values.dart';

enum LabelPosition { top, bottom }

class HomeMap extends StatelessWidget {
  Rxn<LatLng> deviceCoordinate;
  LatLng targetCoordinate;
  MapController mapController;
  MapOptions mapOptions;

  HomeMap({
    super.key,
    required this.deviceCoordinate,
    required this.mapController,
    required this.mapOptions,
    required this.targetCoordinate,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: mapOptions,
      children: [
        TileLayer(
          urlTemplate: Constants.mapUrlTemplate,
        ),
        AnimatedMarkerLayer(
          markers: [
            _buildMarker(
              coordinate: targetCoordinate,
              label: 'Iqomah Mosque',
              labelPosition: LabelPosition.top,
              markerColor: Colors.green,
            ),
          ],
        ),
        Obx(
          () {
            return AnimatedMarkerLayer(
              markers: [
                _buildMarker(
                  coordinate: deviceCoordinate.value ?? const LatLng(0, 0),
                  label: 'You',
                  labelPosition: LabelPosition.bottom,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildLabel(String label) => Container(
        padding: EdgeInsets.symmetric(
          vertical: 8.sp,
          horizontal: 16.sp,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.sp),
          color: Pallete.white,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
          ),
        ),
      );

  AnimatedMarker _buildMarker({
    required LatLng coordinate,
    required String label,
    required LabelPosition labelPosition,
    Color markerColor = Colors.red,
  }) =>
      AnimatedMarker(
        point: coordinate,
        curve: Curves.easeIn,
        width: 200.sp,
        height: 72.sp,
        duration: const Duration(milliseconds: 500),
        builder: (BuildContext context, Animation<double> animation) {
          final size = 36.sp * animation.value;
          return Column(
            children: [
              labelPosition == LabelPosition.top
                  ? _buildLabel(label)
                  : Icon(
                      Icons.location_on,
                      size: size,
                      color: markerColor,
                    ),
              SizedBox(height: 4.sp),
              labelPosition == LabelPosition.bottom
                  ? _buildLabel(label)
                  : Icon(
                      Icons.location_on,
                      size: size,
                      color: markerColor,
                    ),
            ],
          );
        },
      );
}
