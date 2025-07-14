import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/sub_agents_list_controller.dart';

class SubAgentsListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubAgentsListController>(() => SubAgentsListController());
  }
}
