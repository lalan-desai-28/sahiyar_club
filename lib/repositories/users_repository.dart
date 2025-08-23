import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:sahiyar_club/models/user.dart';
import 'package:sahiyar_club/utils/dio_client.dart';

class UsersRepository {
  DioClient dioClient = Get.find<DioClient>();

  Future<Response> login({
    required String mobile,
    required String password,
  }) async {
    return await dioClient.post(
      '/auth/login',
      data: {'mobile': mobile, 'password': password},
    );
  }

  Future<Response<User>> validateOtp({
    required String mobile,
    required String otp,
  }) async {
    final response = await dioClient.post(
      '/auth/login/verify',
      data: {'mobile': mobile, 'otp': otp},
    );
    return Response<User>(
      data: User.fromJson(response.data),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      headers: response.headers,
      requestOptions: RequestOptions(
        path: '/auth/login/verify',
        method: 'POST',
        data: {'mobile': mobile, 'otp': otp},
      ),
    );
  }

  Future<Response<User?>> me({required String token}) async {
    final response = await dioClient.get(
      '/auth/me',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return Response<User?>(
      data: User.fromJson(response.data),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      headers: response.headers,
      requestOptions: RequestOptions(
        path: '/auth/me',
        method: 'GET',
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
  }

  Future<Response<List<User>>> getSubAgents() async {
    final response = await dioClient.get('/users/my-subagents');
    return Response<List<User>>(
      data: (response.data as List).map((e) => User.fromJson(e)).toList(),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      headers: response.headers,
      requestOptions: RequestOptions(
        path: '/users/my-subagents',
        method: 'GET',
      ),
    );
  }

  Future<Response<User?>> createSubAgent({
    required String fullname,
    required String email,
    required String mobile,
    required String password,
    required String parentAgentId,
    required String parentAgentCode,
    required String nickName,
  }) async {
    final response = await dioClient.post(
      '/users/create',
      data: {
        'fullName': fullname,
        'email': email,
        'mobile': mobile,
        'password': password,
        'gender': 'male',
        'role': 'subagent',
        'parentAgentId': parentAgentId,
        'nickName': nickName,
        'parentAgentCode': parentAgentCode,
      },
    );
    return Response<User?>(
      data: User.fromJson(response.data),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      headers: response.headers,
      requestOptions: RequestOptions(
        path: '/users/create',
        method: 'POST',
        data: {
          'fullName': fullname,
          'email': email,
          'mobile': mobile,
          'role': 'subagent',
          'gender': 'male',
          'password': password,
          'parentAgentId': parentAgentId,
        },
      ),
    );
  }

  Future<Response<String>> forgotPassword({
    required String mobile,
    required String role,
  }) async {
    return await dioClient.post(
      '/auth/forgot-password',
      data: {'mobile': mobile, 'role': role},
    );
  }

  Future<Response<String>> resetPassword({
    required String mobile,
    required String otp,
    required String role,
    required String newPassword,
  }) async {
    return await dioClient.post(
      '/auth/reset-password',
      data: {
        'mobile': mobile,
        'otp': otp,
        'newPassword': newPassword,
        'role': role,
      },
    );
  }

  // create same for update agent
  Future<Response<User?>> updateSubAgent({
    required String id,
    required String fullname,
    required String email,
    required String mobile,
    required String? password,
    required String nickName,
    required bool isActive,
  }) async {
    final response = await dioClient.patch(
      '/users/$id',
      data: {
        'fullName': fullname,
        'email': email,
        'mobile': mobile,
        if (password != null) 'password': password,
        'gender': 'male',
        'role': 'subagent',
        'nickName': nickName,
        'isActive': isActive,
      },
    );
    return Response<User?>(
      data: User.fromJson(response.data),
      statusCode: response.statusCode,
      statusMessage: response.statusMessage,
      headers: response.headers,
      requestOptions: RequestOptions(
        path: '/users/update/$id',
        method: 'PUT',
        data: {
          'fullName': fullname,
          'email': email,
          'mobile': mobile,
          'role': 'subagent',
          'gender': 'male',
          'password': password,
        },
      ),
    );
  }
}
