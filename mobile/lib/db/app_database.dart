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

  static const String dummyOrgId = '550e8400-e29b-41d4-a716-446655440000';

  static const Set<String> _mobayResidentIds = {
    'b1f7ac2d-3f2e-4b3b-b2ec-5f33135ec001',
    'b1f7ac2d-3f2e-4b3b-b2ec-5f33135ec002',
    'b1f7ac2d-3f2e-4b3b-b2ec-5f33135ec003',
  };

  static String siteNameForResidentId(String residentId) {
    return _mobayResidentIds.contains(residentId) ? 'Mobay' : 'Goldthorn Home';
  }

  static String roundKeyFor(DateTime now, int roundIndex) {
    final date = dateKeyFor(now);
    return '$date-r$roundIndex';
  }

  static String dateKeyFor(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  static String administrationIdForRound({
    required String residentId,
    required String orderId,
    required String roundKey,
  }) {
    return 'adm-$residentId-$orderId-$roundKey';
  }

  static String marEntryIdForRound({
    required String residentId,
    required String orderId,
    required String roundKey,
  }) {
    return 'round:$roundKey:$residentId:$orderId';
  }

  @override
  int get schemaVersion => 1;

  Future<void> upsertSyncState({
    required String orgId,
    String? siteId,
    required int cursor,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing =
        await (select(syncState)
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
    final row =
        await (select(syncState)
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

  Future<List<Resident>> getActiveResidents() {
    return (select(residents)
          ..where((row) => row.status.equals('active'))
          ..orderBy([
            (row) => OrderingTerm(expression: row.lastName),
            (row) => OrderingTerm(expression: row.firstName),
          ]))
        .get();
  }

  Future<List<MedicationOrder>> getActiveMedicationOrdersForResident(
    String residentId,
  ) {
    return (select(medicationOrders)
          ..where((row) => row.residentId.equals(residentId))
          ..where((row) => row.status.equals('active'))
          ..orderBy([(row) => OrderingTerm(expression: row.medicationName)]))
        .get();
  }

  Future<List<Administration>> getAdministrationsForRoundKey(
    String roundKey,
  ) async {
    final prefix = 'round:$roundKey:%';
    return (select(
      administrations,
    )..where((row) => row.marEntryId.like(prefix))).get();
  }

  Future<List<Administration>> getAdministrationsForDateKey(
    String dateKey,
  ) async {
    final prefix = 'round:$dateKey-%';
    return (select(
      administrations,
    )..where((row) => row.marEntryId.like(prefix))).get();
  }

  Future<void> recordRoundAction({
    required String orgId,
    required String actorUserId,
    required String deviceId,
    required String residentId,
    required String orderId,
    required String roundKey,
    required String status,
    String? reasonCode,
    String? notes,
    required DateTime occurredAt,
    String? siteId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final administrationId = administrationIdForRound(
      residentId: residentId,
      orderId: orderId,
      roundKey: roundKey,
    );
    final marEntryId = marEntryIdForRound(
      residentId: residentId,
      orderId: orderId,
      roundKey: roundKey,
    );

    await into(administrations).insertOnConflictUpdate(
      AdministrationsCompanion(
        administrationId: Value(administrationId),
        orgId: Value(orgId),
        residentId: Value(residentId),
        orderId: Value(orderId),
        marEntryId: Value(marEntryId),
        administeredAt: Value(occurredAt.millisecondsSinceEpoch),
        status: Value(status),
        reasonCode: Value(reasonCode),
        notes: Value(notes),
        updatedAt: Value(now),
      ),
    );

    final eventId =
        '$administrationId:${occurredAt.microsecondsSinceEpoch}:$status';
    await enqueueEvent(
      eventId: eventId,
      orgId: orgId,
      siteId: siteId,
      actorUserId: actorUserId,
      deviceId: deviceId,
      eventType: 'AdministrationRecorded',
      entityType: 'administration',
      entityId: administrationId,
      occurredAt: occurredAt,
      payload: {
        'resident_id': residentId,
        'order_id': orderId,
        'mar_entry_id': marEntryId,
        'administered_at': occurredAt.millisecondsSinceEpoch,
        'status': status,
        'reason_code': reasonCode,
        'notes': notes,
        'round_key': roundKey,
      },
    );
  }

  Future<void> seedDummyClinicalDataIfEmpty() async {
    final countExp = residents.residentId.count();
    final countRow = await (selectOnly(
      residents,
    )..addColumns([countExp])).getSingle();
    final residentCount = countRow.read(countExp) ?? 0;
    if (residentCount > 0) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    final residentRows = [
      ResidentsCompanion.insert(
        residentId: 'b1f7ac2d-3f2e-4b3b-b2ec-5f33135ec001',
        orgId: dummyOrgId,
        firstName: 'Gary',
        lastName: 'Reid',
        updatedAt: now,
      ),
      ResidentsCompanion.insert(
        residentId: 'b1f7ac2d-3f2e-4b3b-b2ec-5f33135ec002',
        orgId: dummyOrgId,
        firstName: 'Samuel',
        lastName: 'Oke',
        updatedAt: now,
      ),
      ResidentsCompanion.insert(
        residentId: 'b1f7ac2d-3f2e-4b3b-b2ec-5f33135ec003',
        orgId: dummyOrgId,
        firstName: 'Ada',
        lastName: 'Lovelace',
        updatedAt: now,
      ),
      ResidentsCompanion.insert(
        residentId: 'c8d84cc0-9ff6-4a4f-bc95-20f98b2cf101',
        orgId: dummyOrgId,
        firstName: 'Alan',
        lastName: 'Turing',
        updatedAt: now,
      ),
      ResidentsCompanion.insert(
        residentId: 'c8d84cc0-9ff6-4a4f-bc95-20f98b2cf102',
        orgId: dummyOrgId,
        firstName: 'Toni',
        lastName: 'Morrison',
        updatedAt: now,
      ),
      ResidentsCompanion.insert(
        residentId: 'c8d84cc0-9ff6-4a4f-bc95-20f98b2cf103',
        orgId: dummyOrgId,
        firstName: 'James',
        lastName: 'Baldwin',
        updatedAt: now,
      ),
    ];

    final orderRows = [
      MedicationOrdersCompanion.insert(
        orderId: '97f80d2f-6dd7-4be4-8ca2-e188af390001',
        orgId: dummyOrgId,
        residentId: 'b1f7ac2d-3f2e-4b3b-b2ec-5f33135ec001',
        medicationName: 'Epilim Chrono 200 tablets',
        doseValue: Value(1.0),
        doseUnit: Value('tablet'),
        route: Value('Oral'),
        frequency: Value('Morning'),
        updatedAt: now,
      ),
      MedicationOrdersCompanion.insert(
        orderId: '97f80d2f-6dd7-4be4-8ca2-e188af390002',
        orgId: dummyOrgId,
        residentId: 'b1f7ac2d-3f2e-4b3b-b2ec-5f33135ec001',
        medicationName: 'Epilim Chrono 500 tablets',
        doseValue: Value(2.0),
        doseUnit: Value('tablets'),
        route: Value('Oral'),
        frequency: Value('Morning'),
        updatedAt: now,
      ),
      MedicationOrdersCompanion.insert(
        orderId: '97f80d2f-6dd7-4be4-8ca2-e188af390003',
        orgId: dummyOrgId,
        residentId: 'b1f7ac2d-3f2e-4b3b-b2ec-5f33135ec002',
        medicationName: 'Metformin 500 mg',
        doseValue: Value(1.0),
        doseUnit: Value('tablet'),
        route: Value('Oral'),
        frequency: Value('Morning, Evening'),
        updatedAt: now,
      ),
      MedicationOrdersCompanion.insert(
        orderId: '97f80d2f-6dd7-4be4-8ca2-e188af390004',
        orgId: dummyOrgId,
        residentId: 'c8d84cc0-9ff6-4a4f-bc95-20f98b2cf101',
        medicationName: 'Lisinopril 10 mg',
        doseValue: Value(1.0),
        doseUnit: Value('tablet'),
        route: Value('Oral'),
        frequency: Value('Morning'),
        updatedAt: now,
      ),
      MedicationOrdersCompanion.insert(
        orderId: '97f80d2f-6dd7-4be4-8ca2-e188af390005',
        orgId: dummyOrgId,
        residentId: 'c8d84cc0-9ff6-4a4f-bc95-20f98b2cf102',
        medicationName: 'Atorvastatin 20 mg',
        doseValue: Value(1.0),
        doseUnit: Value('tablet'),
        route: Value('Oral'),
        frequency: Value('Night'),
        updatedAt: now,
      ),
      MedicationOrdersCompanion.insert(
        orderId: '97f80d2f-6dd7-4be4-8ca2-e188af390006',
        orgId: dummyOrgId,
        residentId: 'c8d84cc0-9ff6-4a4f-bc95-20f98b2cf103',
        medicationName: 'Sertraline 50 mg',
        doseValue: Value(1.0),
        doseUnit: Value('tablet'),
        route: Value('Oral'),
        frequency: Value('Morning'),
        updatedAt: now,
      ),
    ];

    await batch((b) {
      b.insertAllOnConflictUpdate(residents, residentRows);
      b.insertAllOnConflictUpdate(medicationOrders, orderRows);
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final db = driftDatabase(name: 'emar.db');
    return db;
  });
}
