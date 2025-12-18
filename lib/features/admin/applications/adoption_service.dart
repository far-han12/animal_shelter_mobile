import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/api/api_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdoptionService {
  final ApiClient _apiClient;

  AdoptionService(this._apiClient);

  // Inquiries
  Future<Map<String, dynamic>> getInquiries({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/admin/inquiries',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> updateInquiryStatus(
    String id,
    String status,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/admin/inquiries/$id',
        data: {'status': status},
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Applications
  Future<Map<String, dynamic>> getAdoptions({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/admin/adoptions',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> updateAdoptionStatus(
    String id,
    String status,
  ) async {
    try {
      final response = await _apiClient.patch(
        '/admin/adoptions/$id',
        data: {'status': status},
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Public/User Inquiries
  Future<void> createInquiry({
    required String petId,
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    try {
      await _apiClient.post(
        '/inquiries',
        data: {
          'petId': petId,
          'name': name,
          'email': email,
          'phone': phone,
          'message': message,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // User Adoption Application
  Future<void> applyForAdoption({
    required String petId,
    required Map<String, dynamic> applicantInfo,
  }) async {
    try {
      await _apiClient.post(
        '/adoptions/apply',
        data: {'petId': petId, 'applicantInfo': applicantInfo},
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final adoptionServiceProvider = Provider<AdoptionService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdoptionService(apiClient);
});
