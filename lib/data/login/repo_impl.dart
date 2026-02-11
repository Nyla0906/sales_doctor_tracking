import '../../common/storage/token_storage.dart';
import 'api.dart';

class LoginRepoImpl {
  final LoginApi api;
  final TokenStorage storage;

  LoginRepoImpl({required this.api, required this.storage});


  Future<void> login(String username, String pass) async {
    final r = await api.login(username: username, password: pass);
    final data = (r['data'] as Map).cast<String, dynamic>();
    final token = data['accessToken'] as String;

    await storage.saveToken(token);
    await storage.saveUsername(username);
  }
}



