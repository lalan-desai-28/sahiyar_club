import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:sahiyar_club/constants/api_config_constants.dart';
import 'package:sahiyar_club/utils/hive_database.dart';
import 'package:sahiyar_club/utils/snackbar_util.dart';

/// A Dio-based implementation of the [ApiClient] interface.
class DioClient {
  final Dio _dio;

  /// Accepts an optional [ApiConfig]. If none is provided, uses [DioApiConfig].
  DioClient()
    : _dio = (() {
        return Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: ApiConstants.connectTimeout,
            receiveTimeout: ApiConstants.receiveTimeout,
            headers: ApiConstants.defaultHeaders,
          ),
        );
      }()) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = HiveDatabase().getToken(); // Fetch latest token
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          logApiCall(
            options.method,
            options.uri.toString(),
            options.data,
            null,
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          logApiCall(
            response.requestOptions.method,
            response.requestOptions.uri.toString(),
            response.requestOptions.data,
            response,
          );
          handler.next(response);
        },
        onError: (error, handler) {
          logApiCall(
            error.requestOptions.method,
            error.requestOptions.uri.toString(),
            error.requestOptions.data,
            error.response,
          );

          // Handle the error here and decide whether to continue or stop
          _handleDioError(error);

          // Since _handleDioError throws, this won't be reached
          // But if you want to modify the error and continue, you can do:
          // handler.next(error);
        },
      ),
    );
  }

  // create for patch

  Future<Response<T>> patch<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.patch<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    return response;
  }

  Future<Response<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.get<T>(
      endpoint,
      queryParameters: queryParameters,
      options: options,
    );
    return response;
  }

  Future<Response<T>> post<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.post<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    return response;
  }

  Future<Response<T>> put<T>(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.put<T>(
      endpoint,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
    return response;
  }

  Future<Response<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final response = await _dio.delete<T>(
      endpoint,
      queryParameters: queryParameters,
      options: options,
    );
    return response;
  }

  void logApiCall(String method, String url, body, [Response? response]) {
    log('''API Call
         Method: $method
         URL: $url
         Request Body: ${body is FormData ? '${body.fields} \n ${body.files}' : body}
         Status Code: ${response?.statusCode}
         Response Body: ${response?.data}''', name: 'DioClient');
  }

  Never _handleDioError(DioException error) {
    String extractedMessage = 'Something went wrong 😔';

    // Extract custom error message from response body
    if (error.response?.data != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        extractedMessage =
            data['errors']?[0]?['message'] ??
            data['message'] ??
            extractedMessage;
      }
    } else {
      extractedMessage = error.message ?? extractedMessage;
    }

    // Logging for debug
    log('Dio Error: $extractedMessage', name: 'DioClient._handleDioError');

    // Handle specific status codes if needed
    final statusCode = error.response?.statusCode;
    if (statusCode == 401) {
      HiveDatabase().removeToken();
      // check if current route is not login
      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login'); // Navigate to login page on 401
      }
    }
    if (statusCode == 403) {
      // Handle forbidden access
      SnackbarUtil.showErrorSnackbar(
        title: 'Access Denied',
        message: "Your account is deactivated. Please contact support.",
      );
      HiveDatabase().removeToken();
      // remove token
      // check if current route is not login
      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login'); // Navigate to login page on 401
      }
    }

    // Throw new exception with cleaned-up message
    throw DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      message: extractedMessage,
    );
  }
}
