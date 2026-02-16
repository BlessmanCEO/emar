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
    final response = await http.post(
      uri,
      headers: _headersWithoutAuth(),
      body: body,
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('login failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthResponse.fromJson(data);
  }

  Future<AuthResponse> refresh(String refreshToken) async {
    final uri = Uri.parse('$baseUrl/auth/refresh');
    final body = jsonEncode({'refresh_token': refreshToken});
    final response = await http.post(
      uri,
      headers: _headersWithoutAuth(),
      body: body,
    );
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

  Future<List<DemoResident>> fetchDemoResidents() async {
    final uri = Uri.parse('$baseUrl/demo/residents');
    final response = await http
        .get(uri, headers: _headersWithoutAuth())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('fetch residents failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => DemoResident.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DemoMedication>> fetchDemoMedications(String residentId) async {
    final uri = Uri.parse('$baseUrl/demo/residents/$residentId/medications');
    final response = await http
        .get(uri, headers: _headersWithoutAuth())
        .timeout(const Duration(seconds: 10));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('fetch medications failed: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => DemoMedication.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class DemoResident {
  DemoResident({
    required this.residentId,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.dateOfBirth,
    required this.siteName,
    required this.addressLine1,
    required this.allergies,
    required this.specialPreferences,
  });

  final String residentId;
  final String firstName;
  final String lastName;
  final String status;
  final String? dateOfBirth;
  final String siteName;
  final String? addressLine1;
  final String? allergies;
  final List<String> specialPreferences;

  String get fullName => '$firstName $lastName';

  factory DemoResident.fromJson(Map<String, dynamic> json) {
    return DemoResident(
      residentId: json['resident_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      status: json['status'] as String,
      dateOfBirth: json['date_of_birth'] as String?,
      siteName: json['site_name'] as String,
      addressLine1: json['address_line1'] as String?,
      allergies: json['allergies'] as String?,
      specialPreferences:
          (json['raw_preferences'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .toList(),
    );
  }
}

class DemoMedication {
  DemoMedication({
    required this.orderId,
    required this.residentId,
    required this.medicationName,
    required this.rawStrength,
    required this.doseText,
    required this.doseValue,
    required this.doseUnit,
    required this.route,
    required this.instructions,
    required this.prn,
    required this.isControlledDrug,
    required this.frequency,
    required this.scheduledTimes,
    required this.timingSlots,
    required this.timingTimes,
    required this.status,
  });

  final String orderId;
  final String residentId;
  final String medicationName;
  final String? rawStrength;
  final String? doseText;
  final double? doseValue;
  final String? doseUnit;
  final String? route;
  final String? instructions;
  final bool prn;
  final bool isControlledDrug;
  final String? frequency;
  final List<String> scheduledTimes;
  final List<String> timingSlots;
  final List<String> timingTimes;
  final String status;

  factory DemoMedication.fromJson(Map<String, dynamic> json) {
    return DemoMedication(
      orderId: json['order_id'] as String,
      residentId: json['resident_id'] as String,
      medicationName: json['medication_name'] as String,
      rawStrength: json['raw_strength'] as String?,
      doseText: json['dose_text'] as String?,
      doseValue: (json['dose_value'] as num?)?.toDouble(),
      doseUnit: json['dose_unit'] as String?,
      route: json['route'] as String?,
      instructions: json['instructions'] as String?,
      prn: json['prn'] as bool? ?? false,
      isControlledDrug: json['is_controlled_drug'] as bool? ?? false,
      frequency: json['frequency'] as String?,
      scheduledTimes: (json['scheduled_times'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      timingSlots: (json['timing_slots'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      timingTimes: (json['timing_times'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      status: json['status'] as String,
    );
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
