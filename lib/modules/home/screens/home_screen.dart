import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:silence_automation/constants/strings.dart';
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
                coordinate: controller.deviceCoordinate,
                mapController: controller.animatedMapController.mapController,
                mapOptions: controller.mapOptions,
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
              Strings.locationDeniedMessage,
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

  Widget _buildFab() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async => await controller.pauseTracking(),
            child: Obx(
              () {
                return Icon(
                  controller.isTracking.value ? Icons.pause : Icons.play_arrow,
                );
              },
            ),
          ),
          SizedBox(height: 12.sp),
          FloatingActionButton(
            onPressed: () async => await controller.getDeviceCoordinate(),
            child: const Icon(Icons.my_location),
          ),
        ],
      );
}
