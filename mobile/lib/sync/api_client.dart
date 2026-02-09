import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/audit_event.dart';
import '../models/auth_response.dart';
import '../models/bootstrap.dart';
import '../models/login_request.dart';

class ApiClient {
  ApiClient({required this.baseUrl, this.accessToken});

  final String baseUrl;
  final String? accessToken;

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        if (accessToken != null) 'Authorization': 'Bearer $accessToken',
      };

  Future<AuthResponse> login(LoginRequest request) async {
    final uri = Uri.parse('$baseUrl/auth/login');
    final body = jsonEncode(request.toJson());
    final response = await http.post(uri, headers: _headersWithoutAuth(), body: body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('login failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> refresh(String refreshToken) async {
    final uri = Uri.parse('$baseUrl/auth/refresh');
    final body = jsonEncode({'refresh_token': refreshToken});
    final response = await http.post(uri, headers: _headersWithoutAuth(), body: body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('refresh failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthResponse.fromJson(data);
  }

  Map<String, String> _headersWithoutAuth() => {
        'Content-Type': 'application/json',
      };

  Future<PushResult> pushEvents(List<AuditEventInput> events) async {
    final uri = Uri.parse('$baseUrl/sync/push');
    final body = jsonEncode({'events': events.map((e) => e.toJson()).toList()});
    final response = await http.post(uri, headers: _headers(), body: body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('push failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final accepted = (data['accepted'] as List).cast<String>();
    final rejected = (data['rejected'] as List)
        .map((e) => RejectedEvent.fromJson(e as Map<String, dynamic>))
        .toList();
    return PushResult(accepted: accepted, rejected: rejected);
  }

  Future<PullResult> pullEvents({required int cursor, int limit = 200}) async {
    final uri = Uri.parse('$baseUrl/sync/pull?cursor=$cursor&limit=$limit');
    final response = await http.get(uri, headers: _headers());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('pull failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final events = (data['events'] as List)
        .map((e) => AuditEvent.fromJson(e as Map<String, dynamic>))
        .toList();
    final nextCursor = data['next_cursor'] as int;
    return PullResult(events: events, nextCursor: nextCursor);
  }

  Future<BootstrapResponse> bootstrap() async {
    final uri = Uri.parse('$baseUrl/bootstrap');
    final response = await http.get(uri, headers: _headers());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('bootstrap failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return BootstrapResponse.fromJson(data);
  }
}

class PushResult {
  PushResult({required this.accepted, required this.rejected});

  final List<String> accepted;
  final List<RejectedEvent> rejected;
}

class PullResult {
  PullResult({required this.events, required this.nextCursor});

  final List<AuditEvent> events;
  final int nextCursor;
}
