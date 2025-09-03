import 'package:get/get.dart';
import 'package:sahiyar_club/models/fee_batch.dart';
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

  Future<List<FeeBatch>> getAllFeeBatches() async {
    try {
      final response = await dioClient.get('/fees');
      final list =
          (response.data as List)
              .map((feeBatch) => FeeBatch.fromJson(feeBatch))
              .toList();

      return list.where((element) => element.batchType == 'season').toList();
    } catch (e) {
      return [];
    }
  }
}
