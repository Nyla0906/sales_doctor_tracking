import 'package:dio/dio.dart';

class LoginApi {
  final Dio dio;
  LoginApi(this.dio);

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final res = await dio.post(
      '/api/v1/auth/login',
      data: {
        'usernameOrEmail': username,
        'password': password,
      },

      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    );

    return (res.data as Map).cast<String, dynamic>();
  }
}

