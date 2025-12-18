import 'package:dio/dio.dart';
import 'package:mobile/core/api/api_client.dart';
import 'package:mobile/core/api/api_exceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DonationService {
  final ApiClient _apiClient;

  DonationService(this._apiClient);

  Future<String> initSponsorship({
    required double amount,
    required String petId,
    required String donorName,
    required String donorEmail,
    required String donorPhone,
    String? userId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/donations/init',
        data: {
          'amount': amount,
          'purpose': 'SPONSOR_PET',
          'petId': petId,
          'donorName': donorName,
          'donorEmail': donorEmail,
          'donorPhone': donorPhone,
          if (userId != null) 'userId': userId,
        },
      );

      if (response.data['success'] == true) {
        return response.data['url'];
      } else {
        throw Exception(
          response.data['message'] ?? 'Payment initialization failed',
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<List<dynamic>> getMyDonations() async {
    try {
      final response = await _apiClient.get('/donations/my');
      return response.data['data'];
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final donationServiceProvider = Provider<DonationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return DonationService(apiClient);
});
