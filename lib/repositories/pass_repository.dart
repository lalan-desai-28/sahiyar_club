import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:sahiyar_club/models/pass.dart';
import 'package:sahiyar_club/models/pass_full.dart';
import 'package:sahiyar_club/utils/dio_client.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class PassRepository {
  final DioClient dioClient = Get.find<DioClient>();

  String capitalizeFirstLetterOfEachWord(String text) {
    return text
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : '',
        )
        .join(' ');
  }

  /// Converts Uint8List to temporary File
  Future<File> uint8ListToFile(Uint8List data, String filename) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$filename');
    return await file.writeAsBytes(data);
  }

  /// Compresses an image file and returns a temporary File
  Future<File?> compressImageFile(
    File imageFile,
    String outputFilename, {
    int minWidth = 800,
    int minHeight = 800,
    int quality = 85,
    CompressFormat format = CompressFormat.jpeg,
  }) async {
    try {
      final compressedData = await FlutterImageCompress.compressWithFile(
        imageFile.path,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
        format: format,
      );

      if (compressedData == null) {
        return null;
      }

      return await uint8ListToFile(compressedData, outputFilename);
    } catch (e) {
      print('Error compressing image: $e');
      return null;
    }
  }

  Future<Response<Pass>> createPass({
    required String fullname,
    required String mobile,
    required String dob,
    required String gender,
    required String status,
    required File profilePhoto,
    required File idProof,
  }) async {
    final formData = FormData.fromMap({
      'pass': jsonEncode({
        'passType': 'season',
        'fullName': capitalizeFirstLetterOfEachWord(fullname),
        'gender': gender,
        'dob': dob,
        'mobile': mobile,
        'status': status,
      }),
      'profilePhoto': await MultipartFile.fromFile(
        profilePhoto.path,
        filename: basename(profilePhoto.path),
        contentType: DioMediaType('image', 'jpeg'),
      ),
      'idProof': await MultipartFile.fromFile(
        idProof.path,
        filename: basename(idProof.path),
        contentType: DioMediaType('image', 'jpeg'),
      ),
    });

    final response = await dioClient.post('/passes/pass', data: formData);

    return Response<Pass>(
      data: Pass.fromJson(response.data),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      requestOptions: response.requestOptions,
    );
  }

  Future<Response<Pass>> updatePass({
    required String passId,
    required String fullName,
    required String mobile,
    required String dob,
    required String gender,
  }) async {
    final response = await dioClient.put(
      '/passes/$passId',
      data: {
        "fullName": capitalizeFirstLetterOfEachWord(fullName),
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
    File? compressedProfileImage;
    File? compressedIdProofImage;

    try {
      // Compress profile image if provided
      if (profileImage != null) {
        compressedProfileImage = await compressImageFile(
          profileImage,
          'profile_upload_${DateTime.now().millisecondsSinceEpoch}.jpeg',
        );

        if (compressedProfileImage == null) {
          throw Exception('Profile image compression failed');
        }
      }

      // Compress ID proof image if provided
      if (idProofImage != null) {
        compressedIdProofImage = await compressImageFile(
          idProofImage,
          'id_proof_upload_${DateTime.now().millisecondsSinceEpoch}.jpeg',
        );

        if (compressedIdProofImage == null) {
          throw Exception('ID proof image compression failed');
        }
      }

      final formData = FormData.fromMap({
        if (compressedProfileImage != null)
          'profilePhoto': await MultipartFile.fromFile(
            compressedProfileImage.path,
            filename: basename(compressedProfileImage.path),
            contentType: DioMediaType('image', 'jpeg'),
          ),
        if (compressedIdProofImage != null)
          'idProof': await MultipartFile.fromFile(
            compressedIdProofImage.path,
            filename: basename(compressedIdProofImage.path),
            contentType: DioMediaType('image', 'jpeg'),
          ),
      });

      final response = await dioClient.post(
        '/passes/$passId/upload',
        data: formData,
      );

      return Response<Pass>(
        data: Pass.fromJson(response.data),
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        requestOptions: response.requestOptions,
      );
    } finally {
      // Clean up temporary files
      // await cleanupFiles([compressedProfileImage, compressedIdProofImage]);
    }
  }

  Future<Response<List<FullPass>>> getMyPasses({
    String? search,
    required int? page,
    required int? limit,
    required String? status,
    required String? gender,
    required String? subAgentId,
  }) async {
    final response = await dioClient.get(
      '/passes/my',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page ?? 1,
        'limit': limit ?? 5,
        if (status != null) 'passStatus': status,
        if (gender != null) 'gender': gender.toLowerCase(),
        if (subAgentId != null) 'subAgentId': subAgentId,
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
        path: response.requestOptions.path,
      ),
    );
  }

  /// Marks payment as done for a pending pass
  /// Endpoint: POST /api/admin/{id}/pending
  Future<Response<dynamic>> changeToPending(String passId) async {
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

  Future<Response<dynamic>> changeToInRequest(String passId) async {
    final response = await dioClient.post(
      '/admin/$passId/in-request',
      data: {},
    );

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
