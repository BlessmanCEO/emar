import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../sync/api_client.dart';

class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _orgIdKey = 'org_id';
  static const String _usernameKey = 'username';
  static const String _expiresAtKey = 'expires_at';

  final ApiClient apiClient;
  final FlutterSecureStorage secureStorage;
  final SharedPreferences prefs;

  AuthService({
    required this.apiClient,
    required this.secureStorage,
    required this.prefs,
  });

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await apiClient.login(request);
    await _saveTokens(response);
    await _saveUserInfo(request.username, response.accessToken);
    return response;
  }

  Future<void> logout() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_orgIdKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_expiresAtKey);
  }

  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: _refreshTokenKey);
  }

  bool isLoggedIn() {
    return prefs.getString(_userIdKey) != null;
  }

  String? getUserId() => prefs.getString(_userIdKey);
  String? getOrgId() => prefs.getString(_orgIdKey);
  String? getUsername() => prefs.getString(_usernameKey);

  Future<bool> isTokenExpired() async {
    final expiresAt = prefs.getInt(_expiresAtKey);
    if (expiresAt == null) return true;
    return DateTime.now().millisecondsSinceEpoch > expiresAt;
  }

  Future<AuthResponse?> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await apiClient.refresh(refreshToken);
      await _saveTokens(response);
      await _saveUserInfo(
        prefs.getString(_usernameKey) ?? '',
        response.accessToken,
      );
      return response;
    } catch (_) {
      await logout();
      return null;
    }
  }

  Future<void> _saveTokens(AuthResponse response) async {
    await secureStorage.write(key: _accessTokenKey, value: response.accessToken);
    await secureStorage.write(key: _refreshTokenKey, value: response.refreshToken);
    final expiresAt = DateTime.now().millisecondsSinceEpoch + (response.expiresIn * 1000);
    await prefs.setInt(_expiresAtKey, expiresAt);
  }

  Future<void> _saveUserInfo(String username, String accessToken) async {
    try {
      final parts = accessToken.split('.');
      if (parts.length == 3) {
        final payload = jsonDecode(utf8.decode(base64Decode(base64Normalize(parts[1]))));
        await prefs.setString(_userIdKey, payload['sub'] ?? '');
        await prefs.setString(_orgIdKey, payload['org_id'] ?? '');
      }
    } catch (_) {}
    await prefs.setString(_usernameKey, username);
  }

  String base64Normalize(String input) {
    final output = input.replaceAll('-', '+').replaceAll('_', '/');
    final padLength = (4 - output.length % 4) % 4;
    return output + '=' * padLength;
  }
}
