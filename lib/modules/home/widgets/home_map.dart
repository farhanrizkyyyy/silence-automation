// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:silence_automation/constants/strings.dart';

class HomeMap extends StatelessWidget {
  Rxn<LatLng> coordinate;
  MapController mapController;
  MapOptions mapOptions;

  HomeMap({
    super.key,
    required this.coordinate,
    required this.mapController,
    required this.mapOptions,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: mapOptions,
      children: [
        TileLayer(
          urlTemplate: Strings.mapUrlTemplate,
          userAgentPackageName: Strings.packageName,
        ),
        Obx(
          () {
            return AnimatedMarkerLayer(
              markers: [
                AnimatedMarker(
                  point: coordinate.value ?? const LatLng(0, 0),
                  builder: (BuildContext context, Animation<double> animation) {
                    final size = 32.sp * animation.value;
                    return Icon(
                      Icons.location_on,
                      size: size,
                      color: Colors.red,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
