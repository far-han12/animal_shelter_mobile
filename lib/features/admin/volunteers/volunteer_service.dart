import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/api/api_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VolunteerService {
  final ApiClient _apiClient;

  VolunteerService(this._apiClient);

  Future<Map<String, dynamic>> getVolunteers({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/admin/volunteers',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> updateVolunteerStatus(
    String id,
    String status,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/admin/volunteers/$id',
        data: {'status': status},
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> applyVolunteer({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String availability,
    required String interests,
    String? notes,
  }) async {
    try {
      await _apiClient.post(
        '/volunteers/apply',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'availability': availability,
          'interests': interests,
          'notes': notes,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final volunteerServiceProvider = Provider<VolunteerService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VolunteerService(apiClient);
});
