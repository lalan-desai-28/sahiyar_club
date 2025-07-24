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
}
