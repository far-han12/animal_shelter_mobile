import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/auth/auth_storage.dart';
import 'dart:convert';

class AuthState {
  final bool isAuthenticated;
  final String? role;
  final Map<String, dynamic>? user;

  AuthState({this.isAuthenticated = false, this.role, this.user});
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthStorage _storage;

  AuthNotifier(this._storage) : super(AuthState()) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final token = await _storage.getToken();
    final userJson = await _storage.getUser();
    if (token != null && userJson != null) {
      final user = jsonDecode(userJson);
      state = AuthState(isAuthenticated: true, role: user['role'], user: user);
    }
  }

  Future<void> login(String token, Map<String, dynamic> user) async {
    await _storage.saveToken(token);
    await _storage.saveUser(jsonEncode(user));
    state = AuthState(isAuthenticated: true, role: user['role'], user: user);
  }

  Future<void> logout() async {
    await _storage.clearAll();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storage = ref.watch(authStorageProvider);
  return AuthNotifier(storage);
});
