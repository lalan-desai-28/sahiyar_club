import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/pass_list_controller.dart';

class PassListBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassListController>(() => PassListController());
  }
}
