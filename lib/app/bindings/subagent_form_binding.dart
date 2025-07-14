import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/sub_agent_form_controller.dart';

class SubagentFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SubAgentFormController());
  }
}
