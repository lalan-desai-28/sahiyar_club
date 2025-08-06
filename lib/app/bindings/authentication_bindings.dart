import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/authentication_controller.dart';

class AuthenticationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthenticationController>(() => AuthenticationController());
  }
}
