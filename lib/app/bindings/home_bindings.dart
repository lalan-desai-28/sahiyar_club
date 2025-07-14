import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/home_controller.dart';
import 'package:sahiyar_club/controllers/theme_controller.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.lazyPut(() => ThemeController());
  }
}
