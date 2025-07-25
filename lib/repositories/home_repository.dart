import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:sahiyar_club/models/stat.dart';
import 'package:sahiyar_club/utils/dio_client.dart';

class HomeRepository {
  final DioClient dioClient = Get.find<DioClient>();

  /// Fetches user's pass statistics
  /// Endpoint: GET /api/passes/myStats
  Future<Response<Stat>> getMyStats({String? subAgentId}) async {
    final response = await dioClient.get(
      '/passes/myStats',
      queryParameters: {if (subAgentId != null) 'subAgentId': subAgentId},
    );

    return Response<Stat>(
      data: Stat.fromJson(response.data),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: RequestOptions(
        data: response.data,
        method: response.requestOptions.method,
        headers: response.requestOptions.headers,
        queryParameters: response.requestOptions.queryParameters,
        path: response.requestOptions.path,
      ),
    );
  }
}
