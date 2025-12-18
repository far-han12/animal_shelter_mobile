import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/api/api_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DonationService {
  final ApiClient _apiClient;

  DonationService(this._apiClient);

  Future<Map<String, dynamic>> getDonations({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Backend getDonations currently doesn't seem to support pagination in the controller code I saw,
      // but the route expects it if we want to be consistent.
      // Let's check the controller again. It just does .find({}).populate('petId', 'name').sort({ createdAt: -1 });
      // I'll assume the backend might need an update or I'll just handle the list for now.
      final response = await _apiClient.get(
        '/admin/donations',
        queryParameters: {'page': page, 'limit': limit},
      );
      return response.data;
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<String> initDonation({
    required double amount,
    required String purpose,
    String? donorName,
    String? donorEmail,
    String? donorPhone,
    String? userId,
    String? petId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/donations/init',
        data: {
          'amount': amount,
          'purpose': purpose,
          'donorName': donorName,
          'donorEmail': donorEmail,
          'donorPhone': donorPhone,
          'userId': userId,
          'petId': petId,
        },
      );
      if (response.data['success'] == true) {
        return response.data['url'];
      } else {
        throw ApiError('Failed to initialize payment');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final donationServiceProvider = Provider<DonationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DonationService(apiClient);
});
