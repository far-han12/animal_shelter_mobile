import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/api/api_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoryService {
  final ApiClient _apiClient;

  StoryService(this._apiClient);

  Future<Map<String, dynamic>> getStories({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _apiClient.get(
        '/stories',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> createStory(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.post('/admin/stories', data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<Map<String, dynamic>> updateStory(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiClient.patch('/admin/stories/$id', data: data);
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> deleteStory(String id) async {
    try {
      await _apiClient.delete('/admin/stories/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final storyServiceProvider = Provider<StoryService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return StoryService(apiClient);
});
