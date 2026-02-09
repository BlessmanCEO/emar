// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OutboxEventsTable extends OutboxEvents
    with TableInfo<$OutboxEventsTable, OutboxEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orgIdMeta = const VerificationMeta('orgId');
  @override
  late final GeneratedColumn<String> orgId = GeneratedColumn<String>(
    'org_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actorUserIdMeta = const VerificationMeta(
    'actorUserId',
  );
  @override
  late final GeneratedColumn<String> actorUserId = GeneratedColumn<String>(
    'actor_user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    orgId,
    siteId,
    actorUserId,
    deviceId,
    eventType,
    entityType,
    entityId,
    occurredAt,
    schemaVersion,
    payloadJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('org_id')) {
      context.handle(
        _orgIdMeta,
        orgId.isAcceptableOrUnknown(data['org_id']!, _orgIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orgIdMeta);
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    }
    if (data.containsKey('actor_user_id')) {
      context.handle(
        _actorUserIdMeta,
        actorUserId.isAcceptableOrUnknown(
          data['actor_user_id']!,
          _actorUserIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actorUserIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  OutboxEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEvent(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      orgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}org_id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      ),
      actorUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_user_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxEventsTable createAlias(String alias) {
    return $OutboxEventsTable(attachedDatabase, alias);
  }
}

class OutboxEvent extends DataClass implements Insertable<OutboxEvent> {
  final String eventId;
  final String orgId;
  final String? siteId;
  final String actorUserId;
  final String deviceId;
  final String eventType;
  final String entityType;
  final String entityId;
  final int occurredAt;
  final int schemaVersion;
  final String payloadJson;
  final int createdAt;
  const OutboxEvent({
    required this.eventId,
    required this.orgId,
    this.siteId,
    required this.actorUserId,
    required this.deviceId,
    required this.eventType,
    required this.entityType,
    required this.entityId,
    required this.occurredAt,
    required this.schemaVersion,
    required this.payloadJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['org_id'] = Variable<String>(orgId);
    if (!nullToAbsent || siteId != null) {
      map['site_id'] = Variable<String>(siteId);
    }
    map['actor_user_id'] = Variable<String>(actorUserId);
    map['device_id'] = Variable<String>(deviceId);
    map['event_type'] = Variable<String>(eventType);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['occurred_at'] = Variable<int>(occurredAt);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  OutboxEventsCompanion toCompanion(bool nullToAbsent) {
    return OutboxEventsCompanion(
      eventId: Value(eventId),
      orgId: Value(orgId),
      siteId: siteId == null && nullToAbsent
          ? const Value.absent()
          : Value(siteId),
      actorUserId: Value(actorUserId),
      deviceId: Value(deviceId),
      eventType: Value(eventType),
      entityType: Value(entityType),
      entityId: Value(entityId),
      occurredAt: Value(occurredAt),
      schemaVersion: Value(schemaVersion),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEvent(
      eventId: serializer.fromJson<String>(json['eventId']),
      orgId: serializer.fromJson<String>(json['orgId']),
      siteId: serializer.fromJson<String?>(json['siteId']),
      actorUserId: serializer.fromJson<String>(json['actorUserId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'orgId': serializer.toJson<String>(orgId),
      'siteId': serializer.toJson<String?>(siteId),
      'actorUserId': serializer.toJson<String>(actorUserId),
      'deviceId': serializer.toJson<String>(deviceId),
      'eventType': serializer.toJson<String>(eventType),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'occurredAt': serializer.toJson<int>(occurredAt),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  OutboxEvent copyWith({
    String? eventId,
    String? orgId,
    Value<String?> siteId = const Value.absent(),
    String? actorUserId,
    String? deviceId,
    String? eventType,
    String? entityType,
    String? entityId,
    int? occurredAt,
    int? schemaVersion,
    String? payloadJson,
    int? createdAt,
  }) => OutboxEvent(
    eventId: eventId ?? this.eventId,
    orgId: orgId ?? this.orgId,
    siteId: siteId.present ? siteId.value : this.siteId,
    actorUserId: actorUserId ?? this.actorUserId,
    deviceId: deviceId ?? this.deviceId,
    eventType: eventType ?? this.eventType,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    occurredAt: occurredAt ?? this.occurredAt,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    payloadJson: payloadJson ?? this.payloadJson,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxEvent copyWithCompanion(OutboxEventsCompanion data) {
    return OutboxEvent(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      orgId: data.orgId.present ? data.orgId.value : this.orgId,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      actorUserId: data.actorUserId.present
          ? data.actorUserId.value
          : this.actorUserId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEvent(')
          ..write('eventId: $eventId, ')
          ..write('orgId: $orgId, ')
          ..write('siteId: $siteId, ')
          ..write('actorUserId: $actorUserId, ')
          ..write('deviceId: $deviceId, ')
          ..write('eventType: $eventType, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    orgId,
    siteId,
    actorUserId,
    deviceId,
    eventType,
    entityType,
    entityId,
    occurredAt,
    schemaVersion,
    payloadJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEvent &&
          other.eventId == this.eventId &&
          other.orgId == this.orgId &&
          other.siteId == this.siteId &&
          other.actorUserId == this.actorUserId &&
          other.deviceId == this.deviceId &&
          other.eventType == this.eventType &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.occurredAt == this.occurredAt &&
          other.schemaVersion == this.schemaVersion &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt);
}

class OutboxEventsCompanion extends UpdateCompanion<OutboxEvent> {
  final Value<String> eventId;
  final Value<String> orgId;
  final Value<String?> siteId;
  final Value<String> actorUserId;
  final Value<String> deviceId;
  final Value<String> eventType;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<int> occurredAt;
  final Value<int> schemaVersion;
  final Value<String> payloadJson;
  final Value<int> createdAt;
  final Value<int> rowid;
  const OutboxEventsCompanion({
    this.eventId = const Value.absent(),
    this.orgId = const Value.absent(),
    this.siteId = const Value.absent(),
    this.actorUserId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxEventsCompanion.insert({
    required String eventId,
    required String orgId,
    this.siteId = const Value.absent(),
    required String actorUserId,
    required String deviceId,
    required String eventType,
    required String entityType,
    required String entityId,
    required int occurredAt,
    this.schemaVersion = const Value.absent(),
    required String payloadJson,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       orgId = Value(orgId),
       actorUserId = Value(actorUserId),
       deviceId = Value(deviceId),
       eventType = Value(eventType),
       entityType = Value(entityType),
       entityId = Value(entityId),
       occurredAt = Value(occurredAt),
       payloadJson = Value(payloadJson),
       createdAt = Value(createdAt);
  static Insertable<OutboxEvent> custom({
    Expression<String>? eventId,
    Expression<String>? orgId,
    Expression<String>? siteId,
    Expression<String>? actorUserId,
    Expression<String>? deviceId,
    Expression<String>? eventType,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<int>? occurredAt,
    Expression<int>? schemaVersion,
    Expression<String>? payloadJson,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (orgId != null) 'org_id': orgId,
      if (siteId != null) 'site_id': siteId,
      if (actorUserId != null) 'actor_user_id': actorUserId,
      if (deviceId != null) 'device_id': deviceId,
      if (eventType != null) 'event_type': eventType,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxEventsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? orgId,
    Value<String?>? siteId,
    Value<String>? actorUserId,
    Value<String>? deviceId,
    Value<String>? eventType,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<int>? occurredAt,
    Value<int>? schemaVersion,
    Value<String>? payloadJson,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return OutboxEventsCompanion(
      eventId: eventId ?? this.eventId,
      orgId: orgId ?? this.orgId,
      siteId: siteId ?? this.siteId,
      actorUserId: actorUserId ?? this.actorUserId,
      deviceId: deviceId ?? this.deviceId,
      eventType: eventType ?? this.eventType,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      occurredAt: occurredAt ?? this.occurredAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (orgId.present) {
      map['org_id'] = Variable<String>(orgId.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (actorUserId.present) {
      map['actor_user_id'] = Variable<String>(actorUserId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEventsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('orgId: $orgId, ')
          ..write('siteId: $siteId, ')
          ..write('actorUserId: $actorUserId, ')
          ..write('deviceId: $deviceId, ')
          ..write('eventType: $eventType, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxErrorsTable extends OutboxErrors
    with TableInfo<$OutboxErrorsTable, OutboxError> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxErrorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldPathMeta = const VerificationMeta(
    'fieldPath',
  );
  @override
  late final GeneratedColumn<String> fieldPath = GeneratedColumn<String>(
    'field_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    code,
    message,
    fieldPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_errors';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxError> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('field_path')) {
      context.handle(
        _fieldPathMeta,
        fieldPath.isAcceptableOrUnknown(data['field_path']!, _fieldPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  OutboxError map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxError(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      fieldPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxErrorsTable createAlias(String alias) {
    return $OutboxErrorsTable(attachedDatabase, alias);
  }
}

class OutboxError extends DataClass implements Insertable<OutboxError> {
  final String eventId;
  final String code;
  final String message;
  final String? fieldPath;
  final int createdAt;
  const OutboxError({
    required this.eventId,
    required this.code,
    required this.message,
    this.fieldPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['code'] = Variable<String>(code);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || fieldPath != null) {
      map['field_path'] = Variable<String>(fieldPath);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  OutboxErrorsCompanion toCompanion(bool nullToAbsent) {
    return OutboxErrorsCompanion(
      eventId: Value(eventId),
      code: Value(code),
      message: Value(message),
      fieldPath: fieldPath == null && nullToAbsent
          ? const Value.absent()
          : Value(fieldPath),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxError.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxError(
      eventId: serializer.fromJson<String>(json['eventId']),
      code: serializer.fromJson<String>(json['code']),
      message: serializer.fromJson<String>(json['message']),
      fieldPath: serializer.fromJson<String?>(json['fieldPath']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'code': serializer.toJson<String>(code),
      'message': serializer.toJson<String>(message),
      'fieldPath': serializer.toJson<String?>(fieldPath),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  OutboxError copyWith({
    String? eventId,
    String? code,
    String? message,
    Value<String?> fieldPath = const Value.absent(),
    int? createdAt,
  }) => OutboxError(
    eventId: eventId ?? this.eventId,
    code: code ?? this.code,
    message: message ?? this.message,
    fieldPath: fieldPath.present ? fieldPath.value : this.fieldPath,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxError copyWithCompanion(OutboxErrorsCompanion data) {
    return OutboxError(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      code: data.code.present ? data.code.value : this.code,
      message: data.message.present ? data.message.value : this.message,
      fieldPath: data.fieldPath.present ? data.fieldPath.value : this.fieldPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxError(')
          ..write('eventId: $eventId, ')
          ..write('code: $code, ')
          ..write('message: $message, ')
          ..write('fieldPath: $fieldPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, code, message, fieldPath, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxError &&
          other.eventId == this.eventId &&
          other.code == this.code &&
          other.message == this.message &&
          other.fieldPath == this.fieldPath &&
          other.createdAt == this.createdAt);
}

class OutboxErrorsCompanion extends UpdateCompanion<OutboxError> {
  final Value<String> eventId;
  final Value<String> code;
  final Value<String> message;
  final Value<String?> fieldPath;
  final Value<int> createdAt;
  final Value<int> rowid;
  const OutboxErrorsCompanion({
    this.eventId = const Value.absent(),
    this.code = const Value.absent(),
    this.message = const Value.absent(),
    this.fieldPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxErrorsCompanion.insert({
    required String eventId,
    required String code,
    required String message,
    this.fieldPath = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       code = Value(code),
       message = Value(message),
       createdAt = Value(createdAt);
  static Insertable<OutboxError> custom({
    Expression<String>? eventId,
    Expression<String>? code,
    Expression<String>? message,
    Expression<String>? fieldPath,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (code != null) 'code': code,
      if (message != null) 'message': message,
      if (fieldPath != null) 'field_path': fieldPath,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxErrorsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? code,
    Value<String>? message,
    Value<String?>? fieldPath,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return OutboxErrorsCompanion(
      eventId: eventId ?? this.eventId,
      code: code ?? this.code,
      message: message ?? this.message,
      fieldPath: fieldPath ?? this.fieldPath,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (fieldPath.present) {
      map['field_path'] = Variable<String>(fieldPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxErrorsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('code: $code, ')
          ..write('message: $message, ')
          ..write('fieldPath: $fieldPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _orgIdMeta = const VerificationMeta('orgId');
  @override
  late final GeneratedColumn<String> orgId = GeneratedColumn<String>(
    'org_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<int> cursor = GeneratedColumn<int>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, orgId, siteId, cursor, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('org_id')) {
      context.handle(
        _orgIdMeta,
        orgId.isAcceptableOrUnknown(data['org_id']!, _orgIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orgIdMeta);
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      orgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}org_id'],
      )!,
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      ),
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cursor'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final int id;
  final String orgId;
  final String? siteId;
  final int cursor;
  final int updatedAt;
  const SyncStateData({
    required this.id,
    required this.orgId,
    this.siteId,
    required this.cursor,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['org_id'] = Variable<String>(orgId);
    if (!nullToAbsent || siteId != null) {
      map['site_id'] = Variable<String>(siteId);
    }
    map['cursor'] = Variable<int>(cursor);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      id: Value(id),
      orgId: Value(orgId),
      siteId: siteId == null && nullToAbsent
          ? const Value.absent()
          : Value(siteId),
      cursor: Value(cursor),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      id: serializer.fromJson<int>(json['id']),
      orgId: serializer.fromJson<String>(json['orgId']),
      siteId: serializer.fromJson<String?>(json['siteId']),
      cursor: serializer.fromJson<int>(json['cursor']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orgId': serializer.toJson<String>(orgId),
      'siteId': serializer.toJson<String?>(siteId),
      'cursor': serializer.toJson<int>(cursor),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  SyncStateData copyWith({
    int? id,
    String? orgId,
    Value<String?> siteId = const Value.absent(),
    int? cursor,
    int? updatedAt,
  }) => SyncStateData(
    id: id ?? this.id,
    orgId: orgId ?? this.orgId,
    siteId: siteId.present ? siteId.value : this.siteId,
    cursor: cursor ?? this.cursor,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      id: data.id.present ? data.id.value : this.id,
      orgId: data.orgId.present ? data.orgId.value : this.orgId,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('id: $id, ')
          ..write('orgId: $orgId, ')
          ..write('siteId: $siteId, ')
          ..write('cursor: $cursor, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orgId, siteId, cursor, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.id == this.id &&
          other.orgId == this.orgId &&
          other.siteId == this.siteId &&
          other.cursor == this.cursor &&
          other.updatedAt == this.updatedAt);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<int> id;
  final Value<String> orgId;
  final Value<String?> siteId;
  final Value<int> cursor;
  final Value<int> updatedAt;
  const SyncStateCompanion({
    this.id = const Value.absent(),
    this.orgId = const Value.absent(),
    this.siteId = const Value.absent(),
    this.cursor = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SyncStateCompanion.insert({
    this.id = const Value.absent(),
    required String orgId,
    this.siteId = const Value.absent(),
    this.cursor = const Value.absent(),
    required int updatedAt,
  }) : orgId = Value(orgId),
       updatedAt = Value(updatedAt);
  static Insertable<SyncStateData> custom({
    Expression<int>? id,
    Expression<String>? orgId,
    Expression<String>? siteId,
    Expression<int>? cursor,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orgId != null) 'org_id': orgId,
      if (siteId != null) 'site_id': siteId,
      if (cursor != null) 'cursor': cursor,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SyncStateCompanion copyWith({
    Value<int>? id,
    Value<String>? orgId,
    Value<String?>? siteId,
    Value<int>? cursor,
    Value<int>? updatedAt,
  }) {
    return SyncStateCompanion(
      id: id ?? this.id,
      orgId: orgId ?? this.orgId,
      siteId: siteId ?? this.siteId,
      cursor: cursor ?? this.cursor,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orgId.present) {
      map['org_id'] = Variable<String>(orgId.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<int>(cursor.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('id: $id, ')
          ..write('orgId: $orgId, ')
          ..write('siteId: $siteId, ')
          ..write('cursor: $cursor, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ResidentsTable extends Residents
    with TableInfo<$ResidentsTable, Resident> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResidentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _residentIdMeta = const VerificationMeta(
    'residentId',
  );
  @override
  late final GeneratedColumn<String> residentId = GeneratedColumn<String>(
    'resident_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orgIdMeta = const VerificationMeta('orgId');
  @override
  late final GeneratedColumn<String> orgId = GeneratedColumn<String>(
    'org_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    residentId,
    orgId,
    firstName,
    lastName,
    status,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'residents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Resident> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('resident_id')) {
      context.handle(
        _residentIdMeta,
        residentId.isAcceptableOrUnknown(data['resident_id']!, _residentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_residentIdMeta);
    }
    if (data.containsKey('org_id')) {
      context.handle(
        _orgIdMeta,
        orgId.isAcceptableOrUnknown(data['org_id']!, _orgIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orgIdMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    } else if (isInserting) {
      context.missing(_lastNameMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {residentId};
  @override
  Resident map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Resident(
      residentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resident_id'],
      )!,
      orgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}org_id'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ResidentsTable createAlias(String alias) {
    return $ResidentsTable(attachedDatabase, alias);
  }
}

class Resident extends DataClass implements Insertable<Resident> {
  final String residentId;
  final String orgId;
  final String firstName;
  final String lastName;
  final String status;
  final int updatedAt;
  const Resident({
    required this.residentId,
    required this.orgId,
    required this.firstName,
    required this.lastName,
    required this.status,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['resident_id'] = Variable<String>(residentId);
    map['org_id'] = Variable<String>(orgId);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ResidentsCompanion toCompanion(bool nullToAbsent) {
    return ResidentsCompanion(
      residentId: Value(residentId),
      orgId: Value(orgId),
      firstName: Value(firstName),
      lastName: Value(lastName),
      status: Value(status),
      updatedAt: Value(updatedAt),
    );
  }

  factory Resident.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Resident(
      residentId: serializer.fromJson<String>(json['residentId']),
      orgId: serializer.fromJson<String>(json['orgId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      status: serializer.fromJson<String>(json['status']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'residentId': serializer.toJson<String>(residentId),
      'orgId': serializer.toJson<String>(orgId),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Resident copyWith({
    String? residentId,
    String? orgId,
    String? firstName,
    String? lastName,
    String? status,
    int? updatedAt,
  }) => Resident(
    residentId: residentId ?? this.residentId,
    orgId: orgId ?? this.orgId,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Resident copyWithCompanion(ResidentsCompanion data) {
    return Resident(
      residentId: data.residentId.present
          ? data.residentId.value
          : this.residentId,
      orgId: data.orgId.present ? data.orgId.value : this.orgId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Resident(')
          ..write('residentId: $residentId, ')
          ..write('orgId: $orgId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(residentId, orgId, firstName, lastName, status, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Resident &&
          other.residentId == this.residentId &&
          other.orgId == this.orgId &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt);
}

class ResidentsCompanion extends UpdateCompanion<Resident> {
  final Value<String> residentId;
  final Value<String> orgId;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String> status;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ResidentsCompanion({
    this.residentId = const Value.absent(),
    this.orgId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResidentsCompanion.insert({
    required String residentId,
    required String orgId,
    required String firstName,
    required String lastName,
    this.status = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : residentId = Value(residentId),
       orgId = Value(orgId),
       firstName = Value(firstName),
       lastName = Value(lastName),
       updatedAt = Value(updatedAt);
  static Insertable<Resident> custom({
    Expression<String>? residentId,
    Expression<String>? orgId,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? status,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (residentId != null) 'resident_id': residentId,
      if (orgId != null) 'org_id': orgId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResidentsCompanion copyWith({
    Value<String>? residentId,
    Value<String>? orgId,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String>? status,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ResidentsCompanion(
      residentId: residentId ?? this.residentId,
      orgId: orgId ?? this.orgId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (residentId.present) {
      map['resident_id'] = Variable<String>(residentId.value);
    }
    if (orgId.present) {
      map['org_id'] = Variable<String>(orgId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResidentsCompanion(')
          ..write('residentId: $residentId, ')
          ..write('orgId: $orgId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationOrdersTable extends MedicationOrders
    with TableInfo<$MedicationOrdersTable, MedicationOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationOrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orgIdMeta = const VerificationMeta('orgId');
  @override
  late final GeneratedColumn<String> orgId = GeneratedColumn<String>(
    'org_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _residentIdMeta = const VerificationMeta(
    'residentId',
  );
  @override
  late final GeneratedColumn<String> residentId = GeneratedColumn<String>(
    'resident_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _medicationNameMeta = const VerificationMeta(
    'medicationName',
  );
  @override
  late final GeneratedColumn<String> medicationName = GeneratedColumn<String>(
    'medication_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _doseValueMeta = const VerificationMeta(
    'doseValue',
  );
  @override
  late final GeneratedColumn<double> doseValue = GeneratedColumn<double>(
    'dose_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _doseUnitMeta = const VerificationMeta(
    'doseUnit',
  );
  @override
  late final GeneratedColumn<String> doseUnit = GeneratedColumn<String>(
    'dose_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _routeMeta = const VerificationMeta('route');
  @override
  late final GeneratedColumn<String> route = GeneratedColumn<String>(
    'route',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<int> startDate = GeneratedColumn<int>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<int> endDate = GeneratedColumn<int>(
    'end_date',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    orderId,
    orgId,
    residentId,
    medicationName,
    doseValue,
    doseUnit,
    route,
    frequency,
    startDate,
    endDate,
    status,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicationOrder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('org_id')) {
      context.handle(
        _orgIdMeta,
        orgId.isAcceptableOrUnknown(data['org_id']!, _orgIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orgIdMeta);
    }
    if (data.containsKey('resident_id')) {
      context.handle(
        _residentIdMeta,
        residentId.isAcceptableOrUnknown(data['resident_id']!, _residentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_residentIdMeta);
    }
    if (data.containsKey('medication_name')) {
      context.handle(
        _medicationNameMeta,
        medicationName.isAcceptableOrUnknown(
          data['medication_name']!,
          _medicationNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_medicationNameMeta);
    }
    if (data.containsKey('dose_value')) {
      context.handle(
        _doseValueMeta,
        doseValue.isAcceptableOrUnknown(data['dose_value']!, _doseValueMeta),
      );
    }
    if (data.containsKey('dose_unit')) {
      context.handle(
        _doseUnitMeta,
        doseUnit.isAcceptableOrUnknown(data['dose_unit']!, _doseUnitMeta),
      );
    }
    if (data.containsKey('route')) {
      context.handle(
        _routeMeta,
        route.isAcceptableOrUnknown(data['route']!, _routeMeta),
      );
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {orderId};
  @override
  MedicationOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationOrder(
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      orgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}org_id'],
      )!,
      residentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resident_id'],
      )!,
      medicationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medication_name'],
      )!,
      doseValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dose_value'],
      ),
      doseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dose_unit'],
      ),
      route: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}route'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      ),
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_date'],
      ),
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_date'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MedicationOrdersTable createAlias(String alias) {
    return $MedicationOrdersTable(attachedDatabase, alias);
  }
}

class MedicationOrder extends DataClass implements Insertable<MedicationOrder> {
  final String orderId;
  final String orgId;
  final String residentId;
  final String medicationName;
  final double? doseValue;
  final String? doseUnit;
  final String? route;
  final String? frequency;
  final int? startDate;
  final int? endDate;
  final String status;
  final int updatedAt;
  const MedicationOrder({
    required this.orderId,
    required this.orgId,
    required this.residentId,
    required this.medicationName,
    this.doseValue,
    this.doseUnit,
    this.route,
    this.frequency,
    this.startDate,
    this.endDate,
    required this.status,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['order_id'] = Variable<String>(orderId);
    map['org_id'] = Variable<String>(orgId);
    map['resident_id'] = Variable<String>(residentId);
    map['medication_name'] = Variable<String>(medicationName);
    if (!nullToAbsent || doseValue != null) {
      map['dose_value'] = Variable<double>(doseValue);
    }
    if (!nullToAbsent || doseUnit != null) {
      map['dose_unit'] = Variable<String>(doseUnit);
    }
    if (!nullToAbsent || route != null) {
      map['route'] = Variable<String>(route);
    }
    if (!nullToAbsent || frequency != null) {
      map['frequency'] = Variable<String>(frequency);
    }
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<int>(startDate);
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<int>(endDate);
    }
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  MedicationOrdersCompanion toCompanion(bool nullToAbsent) {
    return MedicationOrdersCompanion(
      orderId: Value(orderId),
      orgId: Value(orgId),
      residentId: Value(residentId),
      medicationName: Value(medicationName),
      doseValue: doseValue == null && nullToAbsent
          ? const Value.absent()
          : Value(doseValue),
      doseUnit: doseUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(doseUnit),
      route: route == null && nullToAbsent
          ? const Value.absent()
          : Value(route),
      frequency: frequency == null && nullToAbsent
          ? const Value.absent()
          : Value(frequency),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      status: Value(status),
      updatedAt: Value(updatedAt),
    );
  }

  factory MedicationOrder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationOrder(
      orderId: serializer.fromJson<String>(json['orderId']),
      orgId: serializer.fromJson<String>(json['orgId']),
      residentId: serializer.fromJson<String>(json['residentId']),
      medicationName: serializer.fromJson<String>(json['medicationName']),
      doseValue: serializer.fromJson<double?>(json['doseValue']),
      doseUnit: serializer.fromJson<String?>(json['doseUnit']),
      route: serializer.fromJson<String?>(json['route']),
      frequency: serializer.fromJson<String?>(json['frequency']),
      startDate: serializer.fromJson<int?>(json['startDate']),
      endDate: serializer.fromJson<int?>(json['endDate']),
      status: serializer.fromJson<String>(json['status']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'orderId': serializer.toJson<String>(orderId),
      'orgId': serializer.toJson<String>(orgId),
      'residentId': serializer.toJson<String>(residentId),
      'medicationName': serializer.toJson<String>(medicationName),
      'doseValue': serializer.toJson<double?>(doseValue),
      'doseUnit': serializer.toJson<String?>(doseUnit),
      'route': serializer.toJson<String?>(route),
      'frequency': serializer.toJson<String?>(frequency),
      'startDate': serializer.toJson<int?>(startDate),
      'endDate': serializer.toJson<int?>(endDate),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  MedicationOrder copyWith({
    String? orderId,
    String? orgId,
    String? residentId,
    String? medicationName,
    Value<double?> doseValue = const Value.absent(),
    Value<String?> doseUnit = const Value.absent(),
    Value<String?> route = const Value.absent(),
    Value<String?> frequency = const Value.absent(),
    Value<int?> startDate = const Value.absent(),
    Value<int?> endDate = const Value.absent(),
    String? status,
    int? updatedAt,
  }) => MedicationOrder(
    orderId: orderId ?? this.orderId,
    orgId: orgId ?? this.orgId,
    residentId: residentId ?? this.residentId,
    medicationName: medicationName ?? this.medicationName,
    doseValue: doseValue.present ? doseValue.value : this.doseValue,
    doseUnit: doseUnit.present ? doseUnit.value : this.doseUnit,
    route: route.present ? route.value : this.route,
    frequency: frequency.present ? frequency.value : this.frequency,
    startDate: startDate.present ? startDate.value : this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MedicationOrder copyWithCompanion(MedicationOrdersCompanion data) {
    return MedicationOrder(
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      orgId: data.orgId.present ? data.orgId.value : this.orgId,
      residentId: data.residentId.present
          ? data.residentId.value
          : this.residentId,
      medicationName: data.medicationName.present
          ? data.medicationName.value
          : this.medicationName,
      doseValue: data.doseValue.present ? data.doseValue.value : this.doseValue,
      doseUnit: data.doseUnit.present ? data.doseUnit.value : this.doseUnit,
      route: data.route.present ? data.route.value : this.route,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationOrder(')
          ..write('orderId: $orderId, ')
          ..write('orgId: $orgId, ')
          ..write('residentId: $residentId, ')
          ..write('medicationName: $medicationName, ')
          ..write('doseValue: $doseValue, ')
          ..write('doseUnit: $doseUnit, ')
          ..write('route: $route, ')
          ..write('frequency: $frequency, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    orderId,
    orgId,
    residentId,
    medicationName,
    doseValue,
    doseUnit,
    route,
    frequency,
    startDate,
    endDate,
    status,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationOrder &&
          other.orderId == this.orderId &&
          other.orgId == this.orgId &&
          other.residentId == this.residentId &&
          other.medicationName == this.medicationName &&
          other.doseValue == this.doseValue &&
          other.doseUnit == this.doseUnit &&
          other.route == this.route &&
          other.frequency == this.frequency &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt);
}

class MedicationOrdersCompanion extends UpdateCompanion<MedicationOrder> {
  final Value<String> orderId;
  final Value<String> orgId;
  final Value<String> residentId;
  final Value<String> medicationName;
  final Value<double?> doseValue;
  final Value<String?> doseUnit;
  final Value<String?> route;
  final Value<String?> frequency;
  final Value<int?> startDate;
  final Value<int?> endDate;
  final Value<String> status;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const MedicationOrdersCompanion({
    this.orderId = const Value.absent(),
    this.orgId = const Value.absent(),
    this.residentId = const Value.absent(),
    this.medicationName = const Value.absent(),
    this.doseValue = const Value.absent(),
    this.doseUnit = const Value.absent(),
    this.route = const Value.absent(),
    this.frequency = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationOrdersCompanion.insert({
    required String orderId,
    required String orgId,
    required String residentId,
    required String medicationName,
    this.doseValue = const Value.absent(),
    this.doseUnit = const Value.absent(),
    this.route = const Value.absent(),
    this.frequency = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.status = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : orderId = Value(orderId),
       orgId = Value(orgId),
       residentId = Value(residentId),
       medicationName = Value(medicationName),
       updatedAt = Value(updatedAt);
  static Insertable<MedicationOrder> custom({
    Expression<String>? orderId,
    Expression<String>? orgId,
    Expression<String>? residentId,
    Expression<String>? medicationName,
    Expression<double>? doseValue,
    Expression<String>? doseUnit,
    Expression<String>? route,
    Expression<String>? frequency,
    Expression<int>? startDate,
    Expression<int>? endDate,
    Expression<String>? status,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (orderId != null) 'order_id': orderId,
      if (orgId != null) 'org_id': orgId,
      if (residentId != null) 'resident_id': residentId,
      if (medicationName != null) 'medication_name': medicationName,
      if (doseValue != null) 'dose_value': doseValue,
      if (doseUnit != null) 'dose_unit': doseUnit,
      if (route != null) 'route': route,
      if (frequency != null) 'frequency': frequency,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationOrdersCompanion copyWith({
    Value<String>? orderId,
    Value<String>? orgId,
    Value<String>? residentId,
    Value<String>? medicationName,
    Value<double?>? doseValue,
    Value<String?>? doseUnit,
    Value<String?>? route,
    Value<String?>? frequency,
    Value<int?>? startDate,
    Value<int?>? endDate,
    Value<String>? status,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return MedicationOrdersCompanion(
      orderId: orderId ?? this.orderId,
      orgId: orgId ?? this.orgId,
      residentId: residentId ?? this.residentId,
      medicationName: medicationName ?? this.medicationName,
      doseValue: doseValue ?? this.doseValue,
      doseUnit: doseUnit ?? this.doseUnit,
      route: route ?? this.route,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (orgId.present) {
      map['org_id'] = Variable<String>(orgId.value);
    }
    if (residentId.present) {
      map['resident_id'] = Variable<String>(residentId.value);
    }
    if (medicationName.present) {
      map['medication_name'] = Variable<String>(medicationName.value);
    }
    if (doseValue.present) {
      map['dose_value'] = Variable<double>(doseValue.value);
    }
    if (doseUnit.present) {
      map['dose_unit'] = Variable<String>(doseUnit.value);
    }
    if (route.present) {
      map['route'] = Variable<String>(route.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<int>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<int>(endDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationOrdersCompanion(')
          ..write('orderId: $orderId, ')
          ..write('orgId: $orgId, ')
          ..write('residentId: $residentId, ')
          ..write('medicationName: $medicationName, ')
          ..write('doseValue: $doseValue, ')
          ..write('doseUnit: $doseUnit, ')
          ..write('route: $route, ')
          ..write('frequency: $frequency, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MarEntriesTable extends MarEntries
    with TableInfo<$MarEntriesTable, MarEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _marEntryIdMeta = const VerificationMeta(
    'marEntryId',
  );
  @override
  late final GeneratedColumn<String> marEntryId = GeneratedColumn<String>(
    'mar_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orgIdMeta = const VerificationMeta('orgId');
  @override
  late final GeneratedColumn<String> orgId = GeneratedColumn<String>(
    'org_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _residentIdMeta = const VerificationMeta(
    'residentId',
  );
  @override
  late final GeneratedColumn<String> residentId = GeneratedColumn<String>(
    'resident_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledAtMeta = const VerificationMeta(
    'scheduledAt',
  );
  @override
  late final GeneratedColumn<int> scheduledAt = GeneratedColumn<int>(
    'scheduled_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('scheduled'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    marEntryId,
    orgId,
    residentId,
    orderId,
    scheduledAt,
    status,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mar_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mar_entry_id')) {
      context.handle(
        _marEntryIdMeta,
        marEntryId.isAcceptableOrUnknown(
          data['mar_entry_id']!,
          _marEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_marEntryIdMeta);
    }
    if (data.containsKey('org_id')) {
      context.handle(
        _orgIdMeta,
        orgId.isAcceptableOrUnknown(data['org_id']!, _orgIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orgIdMeta);
    }
    if (data.containsKey('resident_id')) {
      context.handle(
        _residentIdMeta,
        residentId.isAcceptableOrUnknown(data['resident_id']!, _residentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_residentIdMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
        _scheduledAtMeta,
        scheduledAt.isAcceptableOrUnknown(
          data['scheduled_at']!,
          _scheduledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {marEntryId};
  @override
  MarEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarEntry(
      marEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mar_entry_id'],
      )!,
      orgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}org_id'],
      )!,
      residentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resident_id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      scheduledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}scheduled_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MarEntriesTable createAlias(String alias) {
    return $MarEntriesTable(attachedDatabase, alias);
  }
}

class MarEntry extends DataClass implements Insertable<MarEntry> {
  final String marEntryId;
  final String orgId;
  final String residentId;
  final String orderId;
  final int scheduledAt;
  final String status;
  final int updatedAt;
  const MarEntry({
    required this.marEntryId,
    required this.orgId,
    required this.residentId,
    required this.orderId,
    required this.scheduledAt,
    required this.status,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mar_entry_id'] = Variable<String>(marEntryId);
    map['org_id'] = Variable<String>(orgId);
    map['resident_id'] = Variable<String>(residentId);
    map['order_id'] = Variable<String>(orderId);
    map['scheduled_at'] = Variable<int>(scheduledAt);
    map['status'] = Variable<String>(status);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  MarEntriesCompanion toCompanion(bool nullToAbsent) {
    return MarEntriesCompanion(
      marEntryId: Value(marEntryId),
      orgId: Value(orgId),
      residentId: Value(residentId),
      orderId: Value(orderId),
      scheduledAt: Value(scheduledAt),
      status: Value(status),
      updatedAt: Value(updatedAt),
    );
  }

  factory MarEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarEntry(
      marEntryId: serializer.fromJson<String>(json['marEntryId']),
      orgId: serializer.fromJson<String>(json['orgId']),
      residentId: serializer.fromJson<String>(json['residentId']),
      orderId: serializer.fromJson<String>(json['orderId']),
      scheduledAt: serializer.fromJson<int>(json['scheduledAt']),
      status: serializer.fromJson<String>(json['status']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'marEntryId': serializer.toJson<String>(marEntryId),
      'orgId': serializer.toJson<String>(orgId),
      'residentId': serializer.toJson<String>(residentId),
      'orderId': serializer.toJson<String>(orderId),
      'scheduledAt': serializer.toJson<int>(scheduledAt),
      'status': serializer.toJson<String>(status),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  MarEntry copyWith({
    String? marEntryId,
    String? orgId,
    String? residentId,
    String? orderId,
    int? scheduledAt,
    String? status,
    int? updatedAt,
  }) => MarEntry(
    marEntryId: marEntryId ?? this.marEntryId,
    orgId: orgId ?? this.orgId,
    residentId: residentId ?? this.residentId,
    orderId: orderId ?? this.orderId,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MarEntry copyWithCompanion(MarEntriesCompanion data) {
    return MarEntry(
      marEntryId: data.marEntryId.present
          ? data.marEntryId.value
          : this.marEntryId,
      orgId: data.orgId.present ? data.orgId.value : this.orgId,
      residentId: data.residentId.present
          ? data.residentId.value
          : this.residentId,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      scheduledAt: data.scheduledAt.present
          ? data.scheduledAt.value
          : this.scheduledAt,
      status: data.status.present ? data.status.value : this.status,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarEntry(')
          ..write('marEntryId: $marEntryId, ')
          ..write('orgId: $orgId, ')
          ..write('residentId: $residentId, ')
          ..write('orderId: $orderId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    marEntryId,
    orgId,
    residentId,
    orderId,
    scheduledAt,
    status,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarEntry &&
          other.marEntryId == this.marEntryId &&
          other.orgId == this.orgId &&
          other.residentId == this.residentId &&
          other.orderId == this.orderId &&
          other.scheduledAt == this.scheduledAt &&
          other.status == this.status &&
          other.updatedAt == this.updatedAt);
}

class MarEntriesCompanion extends UpdateCompanion<MarEntry> {
  final Value<String> marEntryId;
  final Value<String> orgId;
  final Value<String> residentId;
  final Value<String> orderId;
  final Value<int> scheduledAt;
  final Value<String> status;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const MarEntriesCompanion({
    this.marEntryId = const Value.absent(),
    this.orgId = const Value.absent(),
    this.residentId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.status = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarEntriesCompanion.insert({
    required String marEntryId,
    required String orgId,
    required String residentId,
    required String orderId,
    required int scheduledAt,
    this.status = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : marEntryId = Value(marEntryId),
       orgId = Value(orgId),
       residentId = Value(residentId),
       orderId = Value(orderId),
       scheduledAt = Value(scheduledAt),
       updatedAt = Value(updatedAt);
  static Insertable<MarEntry> custom({
    Expression<String>? marEntryId,
    Expression<String>? orgId,
    Expression<String>? residentId,
    Expression<String>? orderId,
    Expression<int>? scheduledAt,
    Expression<String>? status,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (marEntryId != null) 'mar_entry_id': marEntryId,
      if (orgId != null) 'org_id': orgId,
      if (residentId != null) 'resident_id': residentId,
      if (orderId != null) 'order_id': orderId,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (status != null) 'status': status,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarEntriesCompanion copyWith({
    Value<String>? marEntryId,
    Value<String>? orgId,
    Value<String>? residentId,
    Value<String>? orderId,
    Value<int>? scheduledAt,
    Value<String>? status,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return MarEntriesCompanion(
      marEntryId: marEntryId ?? this.marEntryId,
      orgId: orgId ?? this.orgId,
      residentId: residentId ?? this.residentId,
      orderId: orderId ?? this.orderId,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (marEntryId.present) {
      map['mar_entry_id'] = Variable<String>(marEntryId.value);
    }
    if (orgId.present) {
      map['org_id'] = Variable<String>(orgId.value);
    }
    if (residentId.present) {
      map['resident_id'] = Variable<String>(residentId.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<int>(scheduledAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarEntriesCompanion(')
          ..write('marEntryId: $marEntryId, ')
          ..write('orgId: $orgId, ')
          ..write('residentId: $residentId, ')
          ..write('orderId: $orderId, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('status: $status, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdministrationsTable extends Administrations
    with TableInfo<$AdministrationsTable, Administration> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdministrationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _administrationIdMeta = const VerificationMeta(
    'administrationId',
  );
  @override
  late final GeneratedColumn<String> administrationId = GeneratedColumn<String>(
    'administration_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orgIdMeta = const VerificationMeta('orgId');
  @override
  late final GeneratedColumn<String> orgId = GeneratedColumn<String>(
    'org_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _residentIdMeta = const VerificationMeta(
    'residentId',
  );
  @override
  late final GeneratedColumn<String> residentId = GeneratedColumn<String>(
    'resident_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIdMeta = const VerificationMeta(
    'orderId',
  );
  @override
  late final GeneratedColumn<String> orderId = GeneratedColumn<String>(
    'order_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marEntryIdMeta = const VerificationMeta(
    'marEntryId',
  );
  @override
  late final GeneratedColumn<String> marEntryId = GeneratedColumn<String>(
    'mar_entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _administeredAtMeta = const VerificationMeta(
    'administeredAt',
  );
  @override
  late final GeneratedColumn<int> administeredAt = GeneratedColumn<int>(
    'administered_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonCodeMeta = const VerificationMeta(
    'reasonCode',
  );
  @override
  late final GeneratedColumn<String> reasonCode = GeneratedColumn<String>(
    'reason_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    administrationId,
    orgId,
    residentId,
    orderId,
    marEntryId,
    administeredAt,
    status,
    reasonCode,
    notes,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'administrations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Administration> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('administration_id')) {
      context.handle(
        _administrationIdMeta,
        administrationId.isAcceptableOrUnknown(
          data['administration_id']!,
          _administrationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_administrationIdMeta);
    }
    if (data.containsKey('org_id')) {
      context.handle(
        _orgIdMeta,
        orgId.isAcceptableOrUnknown(data['org_id']!, _orgIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orgIdMeta);
    }
    if (data.containsKey('resident_id')) {
      context.handle(
        _residentIdMeta,
        residentId.isAcceptableOrUnknown(data['resident_id']!, _residentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_residentIdMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(
        _orderIdMeta,
        orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('mar_entry_id')) {
      context.handle(
        _marEntryIdMeta,
        marEntryId.isAcceptableOrUnknown(
          data['mar_entry_id']!,
          _marEntryIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_marEntryIdMeta);
    }
    if (data.containsKey('administered_at')) {
      context.handle(
        _administeredAtMeta,
        administeredAt.isAcceptableOrUnknown(
          data['administered_at']!,
          _administeredAtMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('reason_code')) {
      context.handle(
        _reasonCodeMeta,
        reasonCode.isAcceptableOrUnknown(data['reason_code']!, _reasonCodeMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {administrationId};
  @override
  Administration map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Administration(
      administrationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}administration_id'],
      )!,
      orgId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}org_id'],
      )!,
      residentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resident_id'],
      )!,
      orderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_id'],
      )!,
      marEntryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mar_entry_id'],
      )!,
      administeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}administered_at'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      reasonCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_code'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AdministrationsTable createAlias(String alias) {
    return $AdministrationsTable(attachedDatabase, alias);
  }
}

class Administration extends DataClass implements Insertable<Administration> {
  final String administrationId;
  final String orgId;
  final String residentId;
  final String orderId;
  final String marEntryId;
  final int? administeredAt;
  final String status;
  final String? reasonCode;
  final String? notes;
  final int updatedAt;
  const Administration({
    required this.administrationId,
    required this.orgId,
    required this.residentId,
    required this.orderId,
    required this.marEntryId,
    this.administeredAt,
    required this.status,
    this.reasonCode,
    this.notes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['administration_id'] = Variable<String>(administrationId);
    map['org_id'] = Variable<String>(orgId);
    map['resident_id'] = Variable<String>(residentId);
    map['order_id'] = Variable<String>(orderId);
    map['mar_entry_id'] = Variable<String>(marEntryId);
    if (!nullToAbsent || administeredAt != null) {
      map['administered_at'] = Variable<int>(administeredAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || reasonCode != null) {
      map['reason_code'] = Variable<String>(reasonCode);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  AdministrationsCompanion toCompanion(bool nullToAbsent) {
    return AdministrationsCompanion(
      administrationId: Value(administrationId),
      orgId: Value(orgId),
      residentId: Value(residentId),
      orderId: Value(orderId),
      marEntryId: Value(marEntryId),
      administeredAt: administeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(administeredAt),
      status: Value(status),
      reasonCode: reasonCode == null && nullToAbsent
          ? const Value.absent()
          : Value(reasonCode),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      updatedAt: Value(updatedAt),
    );
  }

  factory Administration.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Administration(
      administrationId: serializer.fromJson<String>(json['administrationId']),
      orgId: serializer.fromJson<String>(json['orgId']),
      residentId: serializer.fromJson<String>(json['residentId']),
      orderId: serializer.fromJson<String>(json['orderId']),
      marEntryId: serializer.fromJson<String>(json['marEntryId']),
      administeredAt: serializer.fromJson<int?>(json['administeredAt']),
      status: serializer.fromJson<String>(json['status']),
      reasonCode: serializer.fromJson<String?>(json['reasonCode']),
      notes: serializer.fromJson<String?>(json['notes']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'administrationId': serializer.toJson<String>(administrationId),
      'orgId': serializer.toJson<String>(orgId),
      'residentId': serializer.toJson<String>(residentId),
      'orderId': serializer.toJson<String>(orderId),
      'marEntryId': serializer.toJson<String>(marEntryId),
      'administeredAt': serializer.toJson<int?>(administeredAt),
      'status': serializer.toJson<String>(status),
      'reasonCode': serializer.toJson<String?>(reasonCode),
      'notes': serializer.toJson<String?>(notes),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  Administration copyWith({
    String? administrationId,
    String? orgId,
    String? residentId,
    String? orderId,
    String? marEntryId,
    Value<int?> administeredAt = const Value.absent(),
    String? status,
    Value<String?> reasonCode = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? updatedAt,
  }) => Administration(
    administrationId: administrationId ?? this.administrationId,
    orgId: orgId ?? this.orgId,
    residentId: residentId ?? this.residentId,
    orderId: orderId ?? this.orderId,
    marEntryId: marEntryId ?? this.marEntryId,
    administeredAt: administeredAt.present
        ? administeredAt.value
        : this.administeredAt,
    status: status ?? this.status,
    reasonCode: reasonCode.present ? reasonCode.value : this.reasonCode,
    notes: notes.present ? notes.value : this.notes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Administration copyWithCompanion(AdministrationsCompanion data) {
    return Administration(
      administrationId: data.administrationId.present
          ? data.administrationId.value
          : this.administrationId,
      orgId: data.orgId.present ? data.orgId.value : this.orgId,
      residentId: data.residentId.present
          ? data.residentId.value
          : this.residentId,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      marEntryId: data.marEntryId.present
          ? data.marEntryId.value
          : this.marEntryId,
      administeredAt: data.administeredAt.present
          ? data.administeredAt.value
          : this.administeredAt,
      status: data.status.present ? data.status.value : this.status,
      reasonCode: data.reasonCode.present
          ? data.reasonCode.value
          : this.reasonCode,
      notes: data.notes.present ? data.notes.value : this.notes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Administration(')
          ..write('administrationId: $administrationId, ')
          ..write('orgId: $orgId, ')
          ..write('residentId: $residentId, ')
          ..write('orderId: $orderId, ')
          ..write('marEntryId: $marEntryId, ')
          ..write('administeredAt: $administeredAt, ')
          ..write('status: $status, ')
          ..write('reasonCode: $reasonCode, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    administrationId,
    orgId,
    residentId,
    orderId,
    marEntryId,
    administeredAt,
    status,
    reasonCode,
    notes,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Administration &&
          other.administrationId == this.administrationId &&
          other.orgId == this.orgId &&
          other.residentId == this.residentId &&
          other.orderId == this.orderId &&
          other.marEntryId == this.marEntryId &&
          other.administeredAt == this.administeredAt &&
          other.status == this.status &&
          other.reasonCode == this.reasonCode &&
          other.notes == this.notes &&
          other.updatedAt == this.updatedAt);
}

class AdministrationsCompanion extends UpdateCompanion<Administration> {
  final Value<String> administrationId;
  final Value<String> orgId;
  final Value<String> residentId;
  final Value<String> orderId;
  final Value<String> marEntryId;
  final Value<int?> administeredAt;
  final Value<String> status;
  final Value<String?> reasonCode;
  final Value<String?> notes;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const AdministrationsCompanion({
    this.administrationId = const Value.absent(),
    this.orgId = const Value.absent(),
    this.residentId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.marEntryId = const Value.absent(),
    this.administeredAt = const Value.absent(),
    this.status = const Value.absent(),
    this.reasonCode = const Value.absent(),
    this.notes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdministrationsCompanion.insert({
    required String administrationId,
    required String orgId,
    required String residentId,
    required String orderId,
    required String marEntryId,
    this.administeredAt = const Value.absent(),
    required String status,
    this.reasonCode = const Value.absent(),
    this.notes = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : administrationId = Value(administrationId),
       orgId = Value(orgId),
       residentId = Value(residentId),
       orderId = Value(orderId),
       marEntryId = Value(marEntryId),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<Administration> custom({
    Expression<String>? administrationId,
    Expression<String>? orgId,
    Expression<String>? residentId,
    Expression<String>? orderId,
    Expression<String>? marEntryId,
    Expression<int>? administeredAt,
    Expression<String>? status,
    Expression<String>? reasonCode,
    Expression<String>? notes,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (administrationId != null) 'administration_id': administrationId,
      if (orgId != null) 'org_id': orgId,
      if (residentId != null) 'resident_id': residentId,
      if (orderId != null) 'order_id': orderId,
      if (marEntryId != null) 'mar_entry_id': marEntryId,
      if (administeredAt != null) 'administered_at': administeredAt,
      if (status != null) 'status': status,
      if (reasonCode != null) 'reason_code': reasonCode,
      if (notes != null) 'notes': notes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdministrationsCompanion copyWith({
    Value<String>? administrationId,
    Value<String>? orgId,
    Value<String>? residentId,
    Value<String>? orderId,
    Value<String>? marEntryId,
    Value<int?>? administeredAt,
    Value<String>? status,
    Value<String?>? reasonCode,
    Value<String?>? notes,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return AdministrationsCompanion(
      administrationId: administrationId ?? this.administrationId,
      orgId: orgId ?? this.orgId,
      residentId: residentId ?? this.residentId,
      orderId: orderId ?? this.orderId,
      marEntryId: marEntryId ?? this.marEntryId,
      administeredAt: administeredAt ?? this.administeredAt,
      status: status ?? this.status,
      reasonCode: reasonCode ?? this.reasonCode,
      notes: notes ?? this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (administrationId.present) {
      map['administration_id'] = Variable<String>(administrationId.value);
    }
    if (orgId.present) {
      map['org_id'] = Variable<String>(orgId.value);
    }
    if (residentId.present) {
      map['resident_id'] = Variable<String>(residentId.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<String>(orderId.value);
    }
    if (marEntryId.present) {
      map['mar_entry_id'] = Variable<String>(marEntryId.value);
    }
    if (administeredAt.present) {
      map['administered_at'] = Variable<int>(administeredAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (reasonCode.present) {
      map['reason_code'] = Variable<String>(reasonCode.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdministrationsCompanion(')
          ..write('administrationId: $administrationId, ')
          ..write('orgId: $orgId, ')
          ..write('residentId: $residentId, ')
          ..write('orderId: $orderId, ')
          ..write('marEntryId: $marEntryId, ')
          ..write('administeredAt: $administeredAt, ')
          ..write('status: $status, ')
          ..write('reasonCode: $reasonCode, ')
          ..write('notes: $notes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OutboxEventsTable outboxEvents = $OutboxEventsTable(this);
  late final $OutboxErrorsTable outboxErrors = $OutboxErrorsTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $ResidentsTable residents = $ResidentsTable(this);
  late final $MedicationOrdersTable medicationOrders = $MedicationOrdersTable(
    this,
  );
  late final $MarEntriesTable marEntries = $MarEntriesTable(this);
  late final $AdministrationsTable administrations = $AdministrationsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    outboxEvents,
    outboxErrors,
    syncState,
    residents,
    medicationOrders,
    marEntries,
    administrations,
  ];
}

typedef $$OutboxEventsTableCreateCompanionBuilder =
    OutboxEventsCompanion Function({
      required String eventId,
      required String orgId,
      Value<String?> siteId,
      required String actorUserId,
      required String deviceId,
      required String eventType,
      required String entityType,
      required String entityId,
      required int occurredAt,
      Value<int> schemaVersion,
      required String payloadJson,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$OutboxEventsTableUpdateCompanionBuilder =
    OutboxEventsCompanion Function({
      Value<String> eventId,
      Value<String> orgId,
      Value<String?> siteId,
      Value<String> actorUserId,
      Value<String> deviceId,
      Value<String> eventType,
      Value<String> entityType,
      Value<String> entityId,
      Value<int> occurredAt,
      Value<int> schemaVersion,
      Value<String> payloadJson,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$OutboxEventsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get orgId =>
      $composableBuilder(column: $table.orgId, builder: (column) => column);

  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<String> get actorUserId => $composableBuilder(
    column: $table.actorUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxEventsTable,
          OutboxEvent,
          $$OutboxEventsTableFilterComposer,
          $$OutboxEventsTableOrderingComposer,
          $$OutboxEventsTableAnnotationComposer,
          $$OutboxEventsTableCreateCompanionBuilder,
          $$OutboxEventsTableUpdateCompanionBuilder,
          (
            OutboxEvent,
            BaseReferences<_$AppDatabase, $OutboxEventsTable, OutboxEvent>,
          ),
          OutboxEvent,
          PrefetchHooks Function()
        > {
  $$OutboxEventsTableTableManager(_$AppDatabase db, $OutboxEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> orgId = const Value.absent(),
                Value<String?> siteId = const Value.absent(),
                Value<String> actorUserId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEventsCompanion(
                eventId: eventId,
                orgId: orgId,
                siteId: siteId,
                actorUserId: actorUserId,
                deviceId: deviceId,
                eventType: eventType,
                entityType: entityType,
                entityId: entityId,
                occurredAt: occurredAt,
                schemaVersion: schemaVersion,
                payloadJson: payloadJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String orgId,
                Value<String?> siteId = const Value.absent(),
                required String actorUserId,
                required String deviceId,
                required String eventType,
                required String entityType,
                required String entityId,
                required int occurredAt,
                Value<int> schemaVersion = const Value.absent(),
                required String payloadJson,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OutboxEventsCompanion.insert(
                eventId: eventId,
                orgId: orgId,
                siteId: siteId,
                actorUserId: actorUserId,
                deviceId: deviceId,
                eventType: eventType,
                entityType: entityType,
                entityId: entityId,
                occurredAt: occurredAt,
                schemaVersion: schemaVersion,
                payloadJson: payloadJson,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxEventsTable,
      OutboxEvent,
      $$OutboxEventsTableFilterComposer,
      $$OutboxEventsTableOrderingComposer,
      $$OutboxEventsTableAnnotationComposer,
      $$OutboxEventsTableCreateCompanionBuilder,
      $$OutboxEventsTableUpdateCompanionBuilder,
      (
        OutboxEvent,
        BaseReferences<_$AppDatabase, $OutboxEventsTable, OutboxEvent>,
      ),
      OutboxEvent,
      PrefetchHooks Function()
    >;
typedef $$OutboxErrorsTableCreateCompanionBuilder =
    OutboxErrorsCompanion Function({
      required String eventId,
      required String code,
      required String message,
      Value<String?> fieldPath,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$OutboxErrorsTableUpdateCompanionBuilder =
    OutboxErrorsCompanion Function({
      Value<String> eventId,
      Value<String> code,
      Value<String> message,
      Value<String?> fieldPath,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$OutboxErrorsTableFilterComposer
    extends Composer<_$AppDatabase, $OutboxErrorsTable> {
  $$OutboxErrorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldPath => $composableBuilder(
    column: $table.fieldPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxErrorsTableOrderingComposer
    extends Composer<_$AppDatabase, $OutboxErrorsTable> {
  $$OutboxErrorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldPath => $composableBuilder(
    column: $table.fieldPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxErrorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OutboxErrorsTable> {
  $$OutboxErrorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get fieldPath =>
      $composableBuilder(column: $table.fieldPath, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxErrorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxErrorsTable,
          OutboxError,
          $$OutboxErrorsTableFilterComposer,
          $$OutboxErrorsTableOrderingComposer,
          $$OutboxErrorsTableAnnotationComposer,
          $$OutboxErrorsTableCreateCompanionBuilder,
          $$OutboxErrorsTableUpdateCompanionBuilder,
          (
            OutboxError,
            BaseReferences<_$AppDatabase, $OutboxErrorsTable, OutboxError>,
          ),
          OutboxError,
          PrefetchHooks Function()
        > {
  $$OutboxErrorsTableTableManager(_$AppDatabase db, $OutboxErrorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxErrorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxErrorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxErrorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String?> fieldPath = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxErrorsCompanion(
                eventId: eventId,
                code: code,
                message: message,
                fieldPath: fieldPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String code,
                required String message,
                Value<String?> fieldPath = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => OutboxErrorsCompanion.insert(
                eventId: eventId,
                code: code,
                message: message,
                fieldPath: fieldPath,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxErrorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxErrorsTable,
      OutboxError,
      $$OutboxErrorsTableFilterComposer,
      $$OutboxErrorsTableOrderingComposer,
      $$OutboxErrorsTableAnnotationComposer,
      $$OutboxErrorsTableCreateCompanionBuilder,
      $$OutboxErrorsTableUpdateCompanionBuilder,
      (
        OutboxError,
        BaseReferences<_$AppDatabase, $OutboxErrorsTable, OutboxError>,
      ),
      OutboxError,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      Value<int> id,
      required String orgId,
      Value<String?> siteId,
      Value<int> cursor,
      required int updatedAt,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<int> id,
      Value<String> orgId,
      Value<String?> siteId,
      Value<int> cursor,
      Value<int> updatedAt,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orgId =>
      $composableBuilder(column: $table.orgId, builder: (column) => column);

  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<int> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$AppDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> orgId = const Value.absent(),
                Value<String?> siteId = const Value.absent(),
                Value<int> cursor = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => SyncStateCompanion(
                id: id,
                orgId: orgId,
                siteId: siteId,
                cursor: cursor,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String orgId,
                Value<String?> siteId = const Value.absent(),
                Value<int> cursor = const Value.absent(),
                required int updatedAt,
              }) => SyncStateCompanion.insert(
                id: id,
                orgId: orgId,
                siteId: siteId,
                cursor: cursor,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateData,
        BaseReferences<_$AppDatabase, $SyncStateTable, SyncStateData>,
      ),
      SyncStateData,
      PrefetchHooks Function()
    >;
typedef $$ResidentsTableCreateCompanionBuilder =
    ResidentsCompanion Function({
      required String residentId,
      required String orgId,
      required String firstName,
      required String lastName,
      Value<String> status,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$ResidentsTableUpdateCompanionBuilder =
    ResidentsCompanion Function({
      Value<String> residentId,
      Value<String> orgId,
      Value<String> firstName,
      Value<String> lastName,
      Value<String> status,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$ResidentsTableFilterComposer
    extends Composer<_$AppDatabase, $ResidentsTable> {
  $$ResidentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get residentId => $composableBuilder(
    column: $table.residentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ResidentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResidentsTable> {
  $$ResidentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get residentId => $composableBuilder(
    column: $table.residentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ResidentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResidentsTable> {
  $$ResidentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get residentId => $composableBuilder(
    column: $table.residentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orgId =>
      $composableBuilder(column: $table.orgId, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ResidentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResidentsTable,
          Resident,
          $$ResidentsTableFilterComposer,
          $$ResidentsTableOrderingComposer,
          $$ResidentsTableAnnotationComposer,
          $$ResidentsTableCreateCompanionBuilder,
          $$ResidentsTableUpdateCompanionBuilder,
          (Resident, BaseReferences<_$AppDatabase, $ResidentsTable, Resident>),
          Resident,
          PrefetchHooks Function()
        > {
  $$ResidentsTableTableManager(_$AppDatabase db, $ResidentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResidentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResidentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResidentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> residentId = const Value.absent(),
                Value<String> orgId = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResidentsCompanion(
                residentId: residentId,
                orgId: orgId,
                firstName: firstName,
                lastName: lastName,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String residentId,
                required String orgId,
                required String firstName,
                required String lastName,
                Value<String> status = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ResidentsCompanion.insert(
                residentId: residentId,
                orgId: orgId,
                firstName: firstName,
                lastName: lastName,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ResidentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResidentsTable,
      Resident,
      $$ResidentsTableFilterComposer,
      $$ResidentsTableOrderingComposer,
      $$ResidentsTableAnnotationComposer,
      $$ResidentsTableCreateCompanionBuilder,
      $$ResidentsTableUpdateCompanionBuilder,
      (Resident, BaseReferences<_$AppDatabase, $ResidentsTable, Resident>),
      Resident,
      PrefetchHooks Function()
    >;
typedef $$MedicationOrdersTableCreateCompanionBuilder =
    MedicationOrdersCompanion Function({
      required String orderId,
      required String orgId,
      required String residentId,
      required String medicationName,
      Value<double?> doseValue,
      Value<String?> doseUnit,
      Value<String?> route,
      Value<String?> frequency,
      Value<int?> startDate,
      Value<int?> endDate,
      Value<String> status,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$MedicationOrdersTableUpdateCompanionBuilder =
    MedicationOrdersCompanion Function({
      Value<String> orderId,
      Value<String> orgId,
      Value<String> residentId,
      Value<String> medicationName,
      Value<double?> doseValue,
      Value<String?> doseUnit,
      Value<String?> route,
      Value<String?> frequency,
      Value<int?> startDate,
      Value<int?> endDate,
      Value<String> status,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$MedicationOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationOrdersTable> {
  $$MedicationOrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get residentId => $composableBuilder(
    column: $table.residentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get doseValue => $composableBuilder(
    column: $table.doseValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get doseUnit => $composableBuilder(
    column: $table.doseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicationOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationOrdersTable> {
  $$MedicationOrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get residentId => $composableBuilder(
    column: $table.residentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get doseValue => $composableBuilder(
    column: $table.doseValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get doseUnit => $composableBuilder(
    column: $table.doseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get route => $composableBuilder(
    column: $table.route,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicationOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationOrdersTable> {
  $$MedicationOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get orgId =>
      $composableBuilder(column: $table.orgId, builder: (column) => column);

  GeneratedColumn<String> get residentId => $composableBuilder(
    column: $table.residentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medicationName => $composableBuilder(
    column: $table.medicationName,
    builder: (column) => column,
  );

  GeneratedColumn<double> get doseValue =>
      $composableBuilder(column: $table.doseValue, builder: (column) => column);

  GeneratedColumn<String> get doseUnit =>
      $composableBuilder(column: $table.doseUnit, builder: (column) => column);

  GeneratedColumn<String> get route =>
      $composableBuilder(column: $table.route, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<int> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MedicationOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MedicationOrdersTable,
          MedicationOrder,
          $$MedicationOrdersTableFilterComposer,
          $$MedicationOrdersTableOrderingComposer,
          $$MedicationOrdersTableAnnotationComposer,
          $$MedicationOrdersTableCreateCompanionBuilder,
          $$MedicationOrdersTableUpdateCompanionBuilder,
          (
            MedicationOrder,
            BaseReferences<
              _$AppDatabase,
              $MedicationOrdersTable,
              MedicationOrder
            >,
          ),
          MedicationOrder,
          PrefetchHooks Function()
        > {
  $$MedicationOrdersTableTableManager(
    _$AppDatabase db,
    $MedicationOrdersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> orderId = const Value.absent(),
                Value<String> orgId = const Value.absent(),
                Value<String> residentId = const Value.absent(),
                Value<String> medicationName = const Value.absent(),
                Value<double?> doseValue = const Value.absent(),
                Value<String?> doseUnit = const Value.absent(),
                Value<String?> route = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<int?> startDate = const Value.absent(),
                Value<int?> endDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicationOrdersCompanion(
                orderId: orderId,
                orgId: orgId,
                residentId: residentId,
                medicationName: medicationName,
                doseValue: doseValue,
                doseUnit: doseUnit,
                route: route,
                frequency: frequency,
                startDate: startDate,
                endDate: endDate,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String orderId,
                required String orgId,
                required String residentId,
                required String medicationName,
                Value<double?> doseValue = const Value.absent(),
                Value<String?> doseUnit = const Value.absent(),
                Value<String?> route = const Value.absent(),
                Value<String?> frequency = const Value.absent(),
                Value<int?> startDate = const Value.absent(),
                Value<int?> endDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MedicationOrdersCompanion.insert(
                orderId: orderId,
                orgId: orgId,
                residentId: residentId,
                medicationName: medicationName,
                doseValue: doseValue,
                doseUnit: doseUnit,
                route: route,
                frequency: frequency,
                startDate: startDate,
                endDate: endDate,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicationOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MedicationOrdersTable,
      MedicationOrder,
      $$MedicationOrdersTableFilterComposer,
      $$MedicationOrdersTableOrderingComposer,
      $$MedicationOrdersTableAnnotationComposer,
      $$MedicationOrdersTableCreateCompanionBuilder,
      $$MedicationOrdersTableUpdateCompanionBuilder,
      (
        MedicationOrder,
        BaseReferences<_$AppDatabase, $MedicationOrdersTable, MedicationOrder>,
      ),
      MedicationOrder,
      PrefetchHooks Function()
    >;
typedef $$MarEntriesTableCreateCompanionBuilder =
    MarEntriesCompanion Function({
      required String marEntryId,
      required String orgId,
      required String residentId,
      required String orderId,
      required int scheduledAt,
      Value<String> status,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$MarEntriesTableUpdateCompanionBuilder =
    MarEntriesCompanion Function({
      Value<String> marEntryId,
      Value<String> orgId,
      Value<String> residentId,
      Value<String> orderId,
      Value<int> scheduledAt,
      Value<String> status,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$MarEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MarEntriesTable> {
  $$MarEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get marEntryId => $composableBuilder(
    column: $table.marEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get residentId => $composableBuilder(
    column: $table.residentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MarEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MarEntriesTable> {
  $$MarEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get marEntryId => $composableBuilder(
    column: $table.marEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get residentId => $composableBuilder(
    column: $table.residentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MarEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarEntriesTable> {
  $$MarEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get marEntryId => $composableBuilder(
    column: $table.marEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orgId =>
      $composableBuilder(column: $table.orgId, builder: (column) => column);

  GeneratedColumn<String> get residentId => $composableBuilder(
    column: $table.residentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<int> get scheduledAt => $composableBuilder(
    column: $table.scheduledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MarEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarEntriesTable,
          MarEntry,
          $$MarEntriesTableFilterComposer,
          $$MarEntriesTableOrderingComposer,
          $$MarEntriesTableAnnotationComposer,
          $$MarEntriesTableCreateCompanionBuilder,
          $$MarEntriesTableUpdateCompanionBuilder,
          (MarEntry, BaseReferences<_$AppDatabase, $MarEntriesTable, MarEntry>),
          MarEntry,
          PrefetchHooks Function()
        > {
  $$MarEntriesTableTableManager(_$AppDatabase db, $MarEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> marEntryId = const Value.absent(),
                Value<String> orgId = const Value.absent(),
                Value<String> residentId = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<int> scheduledAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarEntriesCompanion(
                marEntryId: marEntryId,
                orgId: orgId,
                residentId: residentId,
                orderId: orderId,
                scheduledAt: scheduledAt,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String marEntryId,
                required String orgId,
                required String residentId,
                required String orderId,
                required int scheduledAt,
                Value<String> status = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MarEntriesCompanion.insert(
                marEntryId: marEntryId,
                orgId: orgId,
                residentId: residentId,
                orderId: orderId,
                scheduledAt: scheduledAt,
                status: status,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MarEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarEntriesTable,
      MarEntry,
      $$MarEntriesTableFilterComposer,
      $$MarEntriesTableOrderingComposer,
      $$MarEntriesTableAnnotationComposer,
      $$MarEntriesTableCreateCompanionBuilder,
      $$MarEntriesTableUpdateCompanionBuilder,
      (MarEntry, BaseReferences<_$AppDatabase, $MarEntriesTable, MarEntry>),
      MarEntry,
      PrefetchHooks Function()
    >;
typedef $$AdministrationsTableCreateCompanionBuilder =
    AdministrationsCompanion Function({
      required String administrationId,
      required String orgId,
      required String residentId,
      required String orderId,
      required String marEntryId,
      Value<int?> administeredAt,
      required String status,
      Value<String?> reasonCode,
      Value<String?> notes,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$AdministrationsTableUpdateCompanionBuilder =
    AdministrationsCompanion Function({
      Value<String> administrationId,
      Value<String> orgId,
      Value<String> residentId,
      Value<String> orderId,
      Value<String> marEntryId,
      Value<int?> administeredAt,
      Value<String> status,
      Value<String?> reasonCode,
      Value<String?> notes,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$AdministrationsTableFilterComposer
    extends Composer<_$AppDatabase, $AdministrationsTable> {
  $$AdministrationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get administrationId => $composableBuilder(
    column: $table.administrationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get residentId => $composableBuilder(
    column: $table.residentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marEntryId => $composableBuilder(
    column: $table.marEntryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get administeredAt => $composableBuilder(
    column: $table.administeredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonCode => $composableBuilder(
    column: $table.reasonCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdministrationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AdministrationsTable> {
  $$AdministrationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get administrationId => $composableBuilder(
    column: $table.administrationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orgId => $composableBuilder(
    column: $table.orgId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get residentId => $composableBuilder(
    column: $table.residentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderId => $composableBuilder(
    column: $table.orderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marEntryId => $composableBuilder(
    column: $table.marEntryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get administeredAt => $composableBuilder(
    column: $table.administeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonCode => $composableBuilder(
    column: $table.reasonCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdministrationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdministrationsTable> {
  $$AdministrationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get administrationId => $composableBuilder(
    column: $table.administrationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orgId =>
      $composableBuilder(column: $table.orgId, builder: (column) => column);

  GeneratedColumn<String> get residentId => $composableBuilder(
    column: $table.residentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get marEntryId => $composableBuilder(
    column: $table.marEntryId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get administeredAt => $composableBuilder(
    column: $table.administeredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get reasonCode => $composableBuilder(
    column: $table.reasonCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AdministrationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdministrationsTable,
          Administration,
          $$AdministrationsTableFilterComposer,
          $$AdministrationsTableOrderingComposer,
          $$AdministrationsTableAnnotationComposer,
          $$AdministrationsTableCreateCompanionBuilder,
          $$AdministrationsTableUpdateCompanionBuilder,
          (
            Administration,
            BaseReferences<
              _$AppDatabase,
              $AdministrationsTable,
              Administration
            >,
          ),
          Administration,
          PrefetchHooks Function()
        > {
  $$AdministrationsTableTableManager(
    _$AppDatabase db,
    $AdministrationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdministrationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdministrationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdministrationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> administrationId = const Value.absent(),
                Value<String> orgId = const Value.absent(),
                Value<String> residentId = const Value.absent(),
                Value<String> orderId = const Value.absent(),
                Value<String> marEntryId = const Value.absent(),
                Value<int?> administeredAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> reasonCode = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdministrationsCompanion(
                administrationId: administrationId,
                orgId: orgId,
                residentId: residentId,
                orderId: orderId,
                marEntryId: marEntryId,
                administeredAt: administeredAt,
                status: status,
                reasonCode: reasonCode,
                notes: notes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String administrationId,
                required String orgId,
                required String residentId,
                required String orderId,
                required String marEntryId,
                Value<int?> administeredAt = const Value.absent(),
                required String status,
                Value<String?> reasonCode = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AdministrationsCompanion.insert(
                administrationId: administrationId,
                orgId: orgId,
                residentId: residentId,
                orderId: orderId,
                marEntryId: marEntryId,
                administeredAt: administeredAt,
                status: status,
                reasonCode: reasonCode,
                notes: notes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdministrationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdministrationsTable,
      Administration,
      $$AdministrationsTableFilterComposer,
      $$AdministrationsTableOrderingComposer,
      $$AdministrationsTableAnnotationComposer,
      $$AdministrationsTableCreateCompanionBuilder,
      $$AdministrationsTableUpdateCompanionBuilder,
      (
        Administration,
        BaseReferences<_$AppDatabase, $AdministrationsTable, Administration>,
      ),
      Administration,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OutboxEventsTableTableManager get outboxEvents =>
      $$OutboxEventsTableTableManager(_db, _db.outboxEvents);
  $$OutboxErrorsTableTableManager get outboxErrors =>
      $$OutboxErrorsTableTableManager(_db, _db.outboxErrors);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$ResidentsTableTableManager get residents =>
      $$ResidentsTableTableManager(_db, _db.residents);
  $$MedicationOrdersTableTableManager get medicationOrders =>
      $$MedicationOrdersTableTableManager(_db, _db.medicationOrders);
  $$MarEntriesTableTableManager get marEntries =>
      $$MarEntriesTableTableManager(_db, _db.marEntries);
  $$AdministrationsTableTableManager get administrations =>
      $$AdministrationsTableTableManager(_db, _db.administrations);
}
