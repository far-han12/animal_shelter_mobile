import 'package:dio/dio.dart';

class ApiError implements Exception {
  final String message;
  final int? statusCode;

  ApiError(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiException {
  static ApiError fromDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError("Connection timeout. Please check your internet.");
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          return ApiError(data['message'], statusCode: e.response?.statusCode);
        }
        return ApiError(
          "Backend error: ${e.response?.statusCode}",
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.cancel:
        return ApiError("Request cancelled.");
      default:
        return ApiError("Something went wrong. Please try again.");
    }
  }
}
