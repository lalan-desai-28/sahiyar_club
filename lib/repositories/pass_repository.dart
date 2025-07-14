import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:sahiyar_club/models/pass.dart';
import 'package:sahiyar_club/models/pass_full.dart';
import 'package:sahiyar_club/utils/dio_client.dart';

class PassRepository {
  final DioClient dioClient = Get.find<DioClient>();

  Future<Response<Pass>> createPass({
    required String fullname,
    required String mobile,
    required String dob,
    required String gender,
  }) async {
    final response = await dioClient.post(
      '/passes/request',
      data: {
        "passes": [
          {
            "fullName": fullname,
            "gender": gender,
            "dob": dob,
            "mobile": mobile,
            "passType": "season",
          },
        ],
      },
    );

    return Response<Pass>(
      data: Pass.fromJson(response.data),
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

  Future<Response<Pass>> updatePass({
    required String passId,
    required String firstName,
    required String lastName,
    required String mobile,
    required String dob,
    required String gender,
  }) async {
    final response = await dioClient.put(
      '/passes/$passId',
      data: {
        "firstName": firstName,
        "lastName": lastName,
        "gender": gender,
        "dob": dob,
        "mobile": mobile,
      },
    );

    return Response<Pass>(
      data: Pass.fromJson(response.data),
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

  Future<Response<Pass>> uploadProfileAndIdProofImage({
    required String passId,
    required File? profileImage,
    required File? idProofImage,
    required Function(int, int) onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      if (profileImage != null)
        'profilePhoto': await MultipartFile.fromFile(profileImage.path),
      if (idProofImage != null)
        'idProof': await MultipartFile.fromFile(idProofImage.path),
    });

    final response = await dioClient.post(
      '/passes/$passId/upload',
      data: formData,
    );

    return Response<Pass>(
      data: Pass.fromJson(response.data),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: RequestOptions(
        onSendProgress: onSendProgress,
        data: response.data,
        method: response.requestOptions.method,
        headers: response.requestOptions.headers,
        queryParameters: response.requestOptions.queryParameters,
      ),
    );
  }

  Future<Response<List<FullPass>>> getMyPasses({
    required int? page,
    required int? limit,
    required String? status,
    required String? gender,
  }) async {
    final response = await dioClient.get(
      '/passes/my',
      queryParameters: {
        'page': page ?? 1,
        'limit': limit ?? 5,
        if (status != null) 'passStatus': status,
        if (gender != null) 'gender': gender,
      },
    );

    return Response<List<FullPass>>(
      data:
          (response.data['passes'] as List)
              .map((e) => FullPass.fromJson(e))
              .toList(),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: RequestOptions(
        data: response.data,
        method: response.requestOptions.method,
        headers: response.requestOptions.headers,
        queryParameters: response.requestOptions.queryParameters,
      ),
    );
  }

  /// Marks payment as done for a pending pass
  /// Endpoint: POST /api/admin/{id}/pending
  Future<Response<dynamic>> isPaymentDone(String passId) async {
    final response = await dioClient.post('/admin/$passId/pending', data: {});

    return Response<dynamic>(
      data: response.data,
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
