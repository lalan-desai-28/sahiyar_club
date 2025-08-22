import 'package:get/get.dart';
import 'package:sahiyar_club/utils/dio_client.dart';

class MiscRepository {
  DioClient dioClient = Get.find<DioClient>();

  Future<String> getAppVersion() async {
    try {
      final response = await dioClient.get('/api/latestAppVersion');
      return "v${response.data['version']}";
    } catch (e) {
      return "v1.3.1 (5)";
    }
  }
}
