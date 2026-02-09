import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class OutboxEvents extends Table {
  TextColumn get eventId => text()();
  TextColumn get orgId => text()();
  TextColumn get siteId => text().nullable()();
  TextColumn get actorUserId => text()();
  TextColumn get deviceId => text()();
  TextColumn get eventType => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  IntColumn get occurredAt => integer()();
  IntColumn get schemaVersion => integer().withDefault(const Constant(1))();
  TextColumn get payloadJson => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {eventId};
}

class OutboxErrors extends Table {
  TextColumn get eventId => text()();
  TextColumn get code => text()();
  TextColumn get message => text()();
  TextColumn get fieldPath => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {eventId};
}

class SyncState extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get orgId => text()();
  TextColumn get siteId => text().nullable()();
  IntColumn get cursor => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();
}

class Residents extends Table {
  TextColumn get residentId => text()();
  TextColumn get orgId => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {residentId};
}

class MedicationOrders extends Table {
  TextColumn get orderId => text()();
  TextColumn get orgId => text()();
  TextColumn get residentId => text()();
  TextColumn get medicationName => text()();
  RealColumn get doseValue => real().nullable()();
  TextColumn get doseUnit => text().nullable()();
  TextColumn get route => text().nullable()();
  TextColumn get frequency => text().nullable()();
  IntColumn get startDate => integer().nullable()();
  IntColumn get endDate => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {orderId};
}

class MarEntries extends Table {
  TextColumn get marEntryId => text()();
  TextColumn get orgId => text()();
  TextColumn get residentId => text()();
  TextColumn get orderId => text()();
  IntColumn get scheduledAt => integer()();
  TextColumn get status => text().withDefault(const Constant('scheduled'))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {marEntryId};
}

class Administrations extends Table {
  TextColumn get administrationId => text()();
  TextColumn get orgId => text()();
  TextColumn get residentId => text()();
  TextColumn get orderId => text()();
  TextColumn get marEntryId => text()();
  IntColumn get administeredAt => integer().nullable()();
  TextColumn get status => text()();
  TextColumn get reasonCode => text().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {administrationId};
}

@DriftDatabase(
  tables: [
    OutboxEvents,
    OutboxErrors,
    SyncState,
    Residents,
    MedicationOrders,
    MarEntries,
    Administrations,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  Future<void> upsertSyncState({
    required String orgId,
    String? siteId,
    required int cursor,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing = await (select(syncState)
          ..where((row) => row.orgId.equals(orgId))
          ..where((row) => row.siteId.equalsNullable(siteId)))
        .getSingleOrNull();

    if (existing == null) {
      await into(syncState).insert(
        SyncStateCompanion.insert(
          orgId: orgId,
          siteId: Value(siteId),
          cursor: Value(cursor),
          updatedAt: now,
        ),
      );
    } else {
      await (update(
        syncState,
      )..where((row) => row.id.equals(existing.id))).write(
        SyncStateCompanion(cursor: Value(cursor), updatedAt: Value(now)),
      );
    }
  }

  Future<int> getCursor(String orgId, String? siteId) async {
    final row = await (select(syncState)
          ..where((row) => row.orgId.equals(orgId))
          ..where((row) => row.siteId.equalsNullable(siteId)))
        .getSingleOrNull();
    return row?.cursor ?? 0;
  }

  Future<void> enqueueEvent({
    required String eventId,
    required String orgId,
    String? siteId,
    required String actorUserId,
    required String deviceId,
    required String eventType,
    required String entityType,
    required String entityId,
    required DateTime occurredAt,
    required Map<String, dynamic> payload,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(outboxEvents).insert(
      OutboxEventsCompanion.insert(
        eventId: eventId,
        orgId: orgId,
        siteId: Value(siteId),
        actorUserId: actorUserId,
        deviceId: deviceId,
        eventType: eventType,
        entityType: entityType,
        entityId: entityId,
        occurredAt: occurredAt.millisecondsSinceEpoch,
        payloadJson: jsonEncode(payload),
        createdAt: now,
      ),
    );
  }

  Future<int> outboxCount() async {
    final countExp = outboxEvents.eventId.count();
    final query = selectOnly(outboxEvents)..addColumns([countExp]);
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<List<OutboxEvent>> getOutboxBatch(int limit) async {
    return (select(outboxEvents)..limit(limit)).get();
  }

  Future<void> deleteOutboxEvents(List<String> eventIds) async {
    if (eventIds.isEmpty) return;
    await (delete(
      outboxEvents,
    )..where((row) => row.eventId.isIn(eventIds))).go();
  }

  Future<void> upsertOutboxError({
    required String eventId,
    required String code,
    required String message,
    String? fieldPath,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(outboxErrors).insertOnConflictUpdate(
      OutboxErrorsCompanion(
        eventId: Value(eventId),
        code: Value(code),
        message: Value(message),
        fieldPath: Value(fieldPath),
        createdAt: Value(now),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final db = driftDatabase(name: 'emar.db');
    return db;
  });
}
