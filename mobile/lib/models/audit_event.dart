class AuditEventInput {
  AuditEventInput({
    required this.eventId,
    required this.orgId,
    required this.siteId,
    required this.actorUserId,
    required this.deviceId,
    required this.eventType,
    required this.entityType,
    required this.entityId,
    required this.occurredAt,
    required this.schemaVersion,
    required this.payload,
  });

  final String eventId;
  final String orgId;
  final String? siteId;
  final String actorUserId;
  final String deviceId;
  final String eventType;
  final String entityType;
  final String entityId;
  final DateTime occurredAt;
  final int schemaVersion;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => {
    'event_id': eventId,
    'org_id': orgId,
    'site_id': siteId,
    'actor_user_id': actorUserId,
    'device_id': deviceId,
    'event_type': eventType,
    'entity_type': entityType,
    'entity_id': entityId,
    'occurred_at': occurredAt.toUtc().toIso8601String(),
    'schema_version': schemaVersion,
    'payload': payload,
  };
}

class AuditEvent {
  AuditEvent({
    required this.seq,
    required this.eventId,
    required this.orgId,
    required this.siteId,
    required this.actorUserId,
    required this.deviceId,
    required this.eventType,
    required this.entityType,
    required this.entityId,
    required this.occurredAt,
    required this.receivedAt,
    required this.schemaVersion,
    required this.payload,
  });

  final int seq;
  final String eventId;
  final String orgId;
  final String? siteId;
  final String actorUserId;
  final String deviceId;
  final String eventType;
  final String entityType;
  final String entityId;
  final DateTime occurredAt;
  final DateTime receivedAt;
  final int schemaVersion;
  final Map<String, dynamic> payload;

  static AuditEvent fromJson(Map<String, dynamic> json) {
    return AuditEvent(
      seq: json['seq'] as int,
      eventId: json['event_id'] as String,
      orgId: json['org_id'] as String,
      siteId: json['site_id'] as String?,
      actorUserId: json['actor_user_id'] as String,
      deviceId: json['device_id'] as String,
      eventType: json['event_type'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      receivedAt: DateTime.parse(json['received_at'] as String),
      schemaVersion: json['schema_version'] as int,
      payload: Map<String, dynamic>.from(json['payload'] as Map),
    );
  }
}

class RejectedEvent {
  RejectedEvent({
    required this.eventId,
    required this.code,
    required this.message,
    required this.fieldPath,
  });

  final String eventId;
  final String code;
  final String message;
  final String? fieldPath;

  static RejectedEvent fromJson(Map<String, dynamic> json) {
    return RejectedEvent(
      eventId: json['event_id'] as String,
      code: json['code'] as String,
      message: json['message'] as String,
      fieldPath: json['field_path'] as String?,
    );
  }
}
