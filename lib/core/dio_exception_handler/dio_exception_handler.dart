import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/routes/app_routes.dart';
import 'package:technicianapp/core/services/auth_service.dart';

import 'api_exception.dart';

class DioExceptionHandler {
  static Object handle(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        return const ApiException(
          message: 'Connection timeout. Please try again.',
        );

      case DioExceptionType.sendTimeout:
        return const ApiException(
          message: 'Request timeout. Please try again.',
        );

      case DioExceptionType.receiveTimeout:
        return const ApiException(
          message: 'Server response timeout. Please try again.',
        );

      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection.',
        );

      case DioExceptionType.badCertificate:
        return const ApiException(
          message: 'Invalid server certificate.',
        );

      case DioExceptionType.cancel:
        return const ApiException(
          message: 'Request was cancelled.',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(exception);

      case DioExceptionType.unknown:
        return ApiException(
          message: exception.message ?? 'Something went wrong.',
        );
      case DioExceptionType.transformTimeout:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  static Future<ApiException> _handleBadResponse(
      DioException exception,
      ) async {
    final response = exception.response;

    final statusCode = response?.statusCode;

    dynamic responseData = response?.data;

    String message = 'Something went wrong.';

    if (responseData is Map<String, dynamic>) {
      message =
          responseData['message']?.toString() ??
              responseData['error']?.toString() ??
              message;
    }

    switch (statusCode) {
      case 400:
        return ApiException(
          message: message,
          statusCode: statusCode,
        );

      case 401:
        final _authService = AuthService.to;
        if(_authService.token.value !=null){
          await _authService.clearSession();
          Get.offAllNamed(AppRoutes.loginScreen);
        }
        return ApiException(
          message: 'Unauthorized. Please login again.',
          statusCode: statusCode,
        );

      case 403:
        return ApiException(
          message: 'You do not have permission.',
          statusCode: statusCode,
        );

      case 404:
        return ApiException(
          message: 'Requested resource not found.',
          statusCode: statusCode,
        );

      case 422:
        return ApiException(
          message: message,
          statusCode: statusCode,
        );

      case 500:
        return ApiException(
          message: 'Internal server error.',
          statusCode: statusCode,
        );

      default:
        return ApiException(
          message: message,
          statusCode: statusCode,
        );
    }
  }
}