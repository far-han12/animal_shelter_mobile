import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/api/api_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventService {
  final ApiClient _apiClient;

  EventService(this._apiClient);

  Future<Map<String, dynamic>> getEvents({int page = 1, int limit = 10}) async {
    try {
      final response = await _apiClient.get(
        '/events',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> createEvent(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/admin/events', data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> updateEvent(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.patch('/admin/events/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _apiClient.delete('/admin/events/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final eventServiceProvider = Provider<EventService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventService(apiClient);
});
