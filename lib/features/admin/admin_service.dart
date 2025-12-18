import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/api/api_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminService {
  final ApiClient _apiClient;

  AdminService(this._apiClient);

  Future<Map<String, dynamic>> getAnalytics() async {
    try {
      final response = await _apiClient.get('/admin/analytics');
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  // Common CRUD operations for admin will go here or in specific services
  // For now let's keep it simple
}

final adminServiceProvider = Provider<AdminService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AdminService(apiClient);
});

final adminAnalyticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  return ref.watch(adminServiceProvider).getAnalytics();
});
