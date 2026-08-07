import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    // 10.0.2.2 is loopback to host for Android emulator. localhost for iOS simulator / web.
    final String baseUrl = kIsWeb || defaultTargetPlatform == TargetPlatform.iOS
        ? 'http://localhost:8080'
        : 'http://10.0.2.2:8080';

    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    );

    dio = Dio(options);

    // Logging & Custom Interceptor configuration
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('--> API REQUEST: ${options.method} ${options.uri}');
            if (options.data != null) {
              print('Body: ${options.data}');
            }
          }
          // We can attach JWT authentication token from SharedPreferences here in future
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('<-- API RESPONSE: [${response.statusCode}] ${response.requestOptions.uri}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            print('<-- API ERROR: [${e.response?.statusCode}] ${e.message}');
            if (e.response?.data != null) {
              print('Error Details: ${e.response?.data}');
            }
          }
          return handler.next(e);
        },
      ),
    );
  }
}
