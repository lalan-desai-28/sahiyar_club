import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/total_pass_list_controller.dart';

class TotalPassListBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TotalPassListController>(() => TotalPassListController());
  }
}