import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/api/api_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetService {
  final ApiClient _apiClient;

  PetService(this._apiClient);

  Future<Map<String, dynamic>> getPets({
    int page = 1,
    int limit = 10,
    String? q,
    String? species,
    String? size,
    String? gender,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (q != null && q.isNotEmpty) 'q': q,
        if (species != null && species.isNotEmpty) 'species': species,
        if (size != null && size.isNotEmpty) 'size': size,
        if (gender != null && gender.isNotEmpty) 'gender': gender,
      };
      final response = await _apiClient.get(
        '/pets',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> getAdminPets({
    int page = 1,
    int limit = 10,
    String? search,
    String? status,
    String? species,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null) 'status': status,
        if (species != null) 'species': species,
      };
      // Note: Endpoint from adminRoutes.js is /api/admin/pets
      final response = await _apiClient.get(
        '/admin/pets',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> createPet(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/admin/pets', data: data);
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> updatePet(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.patch('/admin/pets/$id', data: data);
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deletePet(String id) async {
    try {
      await _apiClient.delete('/admin/pets/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final petServiceProvider = Provider<PetService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PetService(apiClient);
});
