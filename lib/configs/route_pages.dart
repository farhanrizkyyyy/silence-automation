import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:silence_automation/constants/route_names.dart';
import 'package:silence_automation/modules/home/bindings/home_binding.dart';
import 'package:silence_automation/modules/home/screens/home_screen.dart';

class RoutePages {
  static List<GetPage> pages = <GetPage>[
    GetPage(
      name: RouteNames.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
  ];
}
