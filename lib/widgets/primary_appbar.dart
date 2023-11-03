import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:silence_automation/constants/pallete.dart';

class PrimaryAppbar extends AppBar {
  PrimaryAppbar({
    super.key,
    Color? statusBarColor,
    Brightness? statusBarIconBrightness,
    Brightness? statusBarBrightness,
    Color? navbarColor,
    Brightness? navbarIconBrightness,
    Brightness? navbarBrightness,
    Color? backgroundColor,
  }) : super(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: statusBarColor,
            statusBarBrightness: statusBarBrightness,
            statusBarIconBrightness: statusBarIconBrightness,
          ),
          backgroundColor: backgroundColor ?? Pallete.white,
          surfaceTintColor: Pallete.white,
          elevation: 0,
          scrolledUnderElevation: 0,
        );
}
