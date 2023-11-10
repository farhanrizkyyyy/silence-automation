import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:silence_automation/constants/pallete.dart';
import 'package:silence_automation/constants/values.dart';
import 'package:silence_automation/modules/home/controllers/home_controller.dart';
import 'package:silence_automation/modules/home/widgets/home_map.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () {
          return Scaffold(
            body: _buildBody(),
            floatingActionButton:
                controller.permission.value == PermissionStatus.granted
                    ? _buildFab()
                    : null,
          );
        },
      ),
    );
  }

  Widget _buildBody() => Center(
        child: Obx(
          () {
            if (controller.permission.value == PermissionStatus.granted) {
              return HomeMap(
                deviceCoordinate: controller.deviceCoordinate,
                mapController: controller.animatedMapController.mapController,
                mapOptions: controller.mapOptions,
                targetCoordinate: controller.targetCoordinate,
              );
            } else if (controller.permission.value == PermissionStatus.denied ||
                controller.permission.value ==
                    PermissionStatus.permanentlyDenied) {
              return _buildPermissionNotGranted();
            } else {
              return Container();
            }
          },
        ),
      );

  Widget _buildPermissionNotGranted() => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              Constants.locationDeniedMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.sp),
            ElevatedButton(
              onPressed: () async => await openAppSettings(),
              child: const Text('Set App Permission'),
            ),
          ],
        ),
      );

  Widget _buildFab() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _buildDistanceInfo(),
          ),
          SizedBox(width: 60.sp),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () async => await controller.pauseTracking(),
                tooltip: controller.isTracking.value
                    ? 'Pause Live Tracking'
                    : 'Resume Live Tracking',
                child: Obx(
                  () {
                    return Icon(
                      controller.isTracking.value
                          ? Icons.pause
                          : Icons.play_arrow,
                    );
                  },
                ),
              ),
              SizedBox(height: 12.sp),
              FloatingActionButton(
                onPressed: () async => await controller.getDeviceCoordinate(),
                tooltip: 'Jump to Your Location',
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ],
      );

  Widget _buildDistanceInfo() => Container(
        padding: EdgeInsets.symmetric(
          vertical: 10.sp,
          horizontal: 20.sp,
        ),
        margin: EdgeInsets.only(left: 32.sp),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.sp),
          color: Pallete.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 4.sp),
            _buildInfo(
              title: 'Target coordinate',
              label:
                  '${controller.targetCoordinate.latitude}, ${controller.targetCoordinate.longitude}',
            ),
            SizedBox(height: 4.sp),
            _buildInfo(
              title: 'Device coordinate',
              label:
                  '${controller.deviceCoordinate.value?.latitude ?? 0}, ${controller.deviceCoordinate.value?.longitude ?? 0}',
            ),
            SizedBox(height: 4.sp),
            _buildInfo(
              title: 'Current distance',
              label: '${controller.currentDistance.value} m',
            ),
          ],
        ),
      );

  Widget _buildInfo({
    required String title,
    required String label,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12.sp,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
            ),
          ),
        ],
      );
}
