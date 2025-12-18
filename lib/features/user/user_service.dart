import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/api/api_client.dart';

class UserService {
  final ApiClient _api;

  UserService(this._api);

  // Profile
  Future<Map<String, dynamic>> getProfile() async {
    final response = await _api.get('/auth/me');
    return response.data['data'];
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _api.patch('/users/me', data: data);
    return response.data['data'];
  }

  // Pet Submissions
  Future<void> submitPet(Map<String, dynamic> data) async {
    await _api.post('/pets/submit', data: data);
  }

  Future<List<dynamic>> getMySubmissions() async {
    final response = await _api.get('/pets/my-submissions');
    return response.data['data'];
  }

  Future<void> updateSubmission(String id, Map<String, dynamic> data) async {
    await _api.patch('/pets/my-submissions/$id', data: data);
  }

  Future<void> withdrawSubmission(String id) async {
    await _api.delete('/pets/my-submissions/$id');
  }

  // Adoptions
  Future<void> applyForAdoption(Map<String, dynamic> data) async {
    await _api.post('/adoptions/apply', data: data);
  }

  Future<List<dynamic>> getMyAdoptions() async {
    final response = await _api.get('/adoptions/my');
    return response.data['data'];
  }

  // Donations
  Future<List<dynamic>> getMyDonations() async {
    final response = await _api.get('/donations/my');
    return response.data['data'];
  }
}

final userServiceProvider = Provider<UserService>((ref) {
  final api = ref.watch(apiClientProvider);
  return UserService(api);
});

final userProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(userServiceProvider).getProfile();
});

final mySubmissionsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(userServiceProvider).getMySubmissions();
});

final myAdoptionsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(userServiceProvider).getMyAdoptions();
});

final myDonationsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(userServiceProvider).getMyDonations();
});
