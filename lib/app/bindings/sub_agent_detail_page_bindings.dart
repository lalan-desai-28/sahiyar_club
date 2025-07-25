import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/sub_agent_detail_page_controller.dart';

class SubAgentDetailPageBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SubAgentDetailPageController());
  }
}
