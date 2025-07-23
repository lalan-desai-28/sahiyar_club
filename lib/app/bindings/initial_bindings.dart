import 'package:get/get.dart';
import 'package:sahiyar_club/controllers/create_pass_controller.dart';
import 'package:sahiyar_club/utils/dio_client.dart';
import 'package:sahiyar_club/utils/hive_database.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // bind dioClient and other HiveDatabase dependencies here
    Get.lazyPut(() => DioClient(), fenix: true);
    Get.lazyPut(() => HiveDatabase(), fenix: true);
    // bind controllers
    Get.lazyPut(() => CreatePassController(), fenix: true);
  }
}
