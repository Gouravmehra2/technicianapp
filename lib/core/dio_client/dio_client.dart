import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:technicianapp/core/dio_exception_handler/dio_exception_handler.dart';
import 'package:technicianapp/core/end_point/end_point.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _addInterceptors();
  }

  void _addInterceptors() {
    // Inject Bearer token automatically on every request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: true,
        maxWidth: 120,
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await dio.delete(
        path,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await dio.patch(
        path,
        data: data,
        options: options,
      );
    } on DioException catch (e) {
      throw DioExceptionHandler.handle(e);
    }
  }
}
