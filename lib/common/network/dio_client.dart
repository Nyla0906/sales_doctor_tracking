import 'package:dio/dio.dart';
import 'pretty_log.dart';
import '../storage/token_storage.dart';

class DioClient {
  final Dio dio;
  DioClient._(this.dio);

  factory DioClient(TokenStorage storage) {
    final dio = Dio(
      BaseOptions(
        baseUrl: "https://living-likely-monster.ngrok-free.app/backend",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );

    bool _isAuthPath(String path) {
      // path odatda "/api/v1/..." bo‘ladi
      return path.startsWith("/api/v1/auth/");
    }

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (o, h) async {
          try {
            // ✅ Auth endpointlarga token QO‘SHILMAYDI
            if (!_isAuthPath(o.path)) {
              final token = await storage.getToken();
              if (token != null && token.isNotEmpty) {
                o.headers["Authorization"] = "Bearer $token";
              }
            } else {
              o.headers.remove("Authorization");
            }
          } catch (_) {}

          PrettyLog.box(
            "REQUEST",
            "${o.method} ${o.baseUrl}${o.path}\nHeaders: ${o.headers}\nBody: ${o.data}",
          );
          h.next(o);
        },
        onResponse: (r, h) {
          PrettyLog.box(
            "RESPONSE",
            "${r.statusCode} ${r.requestOptions.path}\n${r.data}",
          );
          h.next(r);
        },
        onError: (e, h) {
          PrettyLog.box(
            "DIO ERROR",
            "URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}\n"
                "Status: ${e.response?.statusCode}\n"
                "Response: ${e.response?.data}\n"
                "Message: ${e.message}",
          );
          h.next(e);
        },
      ),
    );

    return DioClient._(dio);
  }
}
