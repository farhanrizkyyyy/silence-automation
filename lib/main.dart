import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:silence_automation/configs/route_pages.dart';
import 'package:silence_automation/constants/pallete.dart';
import 'package:silence_automation/constants/route_names.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: GetMaterialApp(
        theme: ThemeData(
          scaffoldBackgroundColor: Pallete.white,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: RouteNames.home,
        getPages: RoutePages.pages,
      ),
    );
  }
}
