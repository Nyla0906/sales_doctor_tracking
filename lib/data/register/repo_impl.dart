import 'api.dart';

class RegisterRepoImpl {
  final RegisterApi api;

  RegisterRepoImpl({required this.api});

  Future<void> register(String username, String email, String password) async {
    await api.register(username: username, email: email, password: password);
  }
}
