import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/api/api_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 10,
    String? search,
    String? role,
    bool? isDisabled,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (role != null) 'role': role,
        if (isDisabled != null) 'isDisabled': isDisabled.toString(),
      };
      final response = await _apiClient.get(
        '/users',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      final response = await _apiClient.get('/users/$id');
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> updateUser(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.patch('/users/$id', data: data);
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _apiClient.delete('/users/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserService(apiClient);
});
