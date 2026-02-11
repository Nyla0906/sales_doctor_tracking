import 'package:dio/dio.dart';

class RegisterApi {
  final Dio dio;
  RegisterApi(this.dio);

  Future<void> register({
    required String username,
    required String email,
    required String password,
  }) async {
    await dio.post(
      "/api/v1/auth/register",
      data: {
        "username": username,
        "email": email,
        "password": password,
      },
    );
  }
}
