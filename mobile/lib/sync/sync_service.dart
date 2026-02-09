import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/audit_event.dart';
import '../models/bootstrap.dart';
import 'api_client.dart';

class SyncService {
  SyncService({required this.db, required this.apiClient});

  final AppDatabase db;
  final ApiClient apiClient;

  Future<void> runSync({required String orgId, String? siteId}) async {
    await _pushOutbox();
    await _pullRemote(orgId: orgId, siteId: siteId);
  }

  Future<void> runBootstrap({required String orgId, String? siteId}) async {
    final snapshot = await apiClient.bootstrap();
    await _applyBootstrap(snapshot);
    await db.upsertSyncState(
      orgId: orgId,
      siteId: siteId,
      cursor: snapshot.cursor,
    );
  }

  Future<void> _pushOutbox() async {
    final batch = await db.getOutboxBatch(200);
    if (batch.isEmpty) return;

    final events = batch.map((row) {
      final payload = jsonDecode(row.payloadJson) as Map<String, dynamic>;
      return AuditEventInput(
        eventId: row.eventId,
        orgId: row.orgId,
        siteId: row.siteId,
        actorUserId: row.actorUserId,
        deviceId: row.deviceId,
        eventType: row.eventType,
        entityType: row.entityType,
        entityId: row.entityId,
        occurredAt: DateTime.fromMillisecondsSinceEpoch(row.occurredAt),
        schemaVersion: row.schemaVersion,
        payload: payload,
      );
    }).toList();

    final result = await apiClient.pushEvents(events);
    if (result.accepted.isNotEmpty) {
      await db.deleteOutboxEvents(result.accepted);
    }
    for (final rejection in result.rejected) {
      await db.upsertOutboxError(
        eventId: rejection.eventId,
        code: rejection.code,
        message: rejection.message,
        fieldPath: rejection.fieldPath,
      );
    }
  }

  Future<void> _pullRemote({required String orgId, String? siteId}) async {
    final cursor = await db.getCursor(orgId, siteId);
    final result = await apiClient.pullEvents(cursor: cursor, limit: 200);

    for (final event in result.events) {
      await _applyEvent(event);
    }
    await db.upsertSyncState(
      orgId: orgId,
      siteId: siteId,
      cursor: result.nextCursor,
    );
  }

  Future<void> _applyEvent(AuditEvent event) async {
    final payload = event.payload;
    final updatedAt = event.occurredAt.millisecondsSinceEpoch;

    switch (event.eventType) {
      case 'ResidentUpserted':
        await db
            .into(db.residents)
            .insertOnConflictUpdate(
              ResidentsCompanion(
                residentId: Value(event.entityId),
                orgId: Value(event.orgId),
                firstName: Value(payload['first_name'] as String? ?? ''),
                lastName: Value(payload['last_name'] as String? ?? ''),
                status: Value(payload['status'] as String? ?? 'active'),
                updatedAt: Value(updatedAt),
              ),
            );
        break;
      case 'MedicationOrderCreated':
      case 'MedicationOrderUpdated':
      case 'MedicationOrderDiscontinued':
        final doseValueRaw = payload['dose_value'];
        final doseValue = doseValueRaw is num ? doseValueRaw.toDouble() : null;
        await db
            .into(db.medicationOrders)
            .insertOnConflictUpdate(
              MedicationOrdersCompanion(
                orderId: Value(event.entityId),
                orgId: Value(event.orgId),
                residentId: Value(payload['resident_id'] as String? ?? ''),
                medicationName: Value(
                  payload['medication_name'] as String? ?? '',
                ),
                doseValue: Value(doseValue),
                doseUnit: Value(payload['dose_unit'] as String?),
                route: Value(payload['route'] as String?),
                frequency: Value(payload['frequency'] as String?),
                startDate: Value(payload['start_date'] as int?),
                endDate: Value(payload['end_date'] as int?),
                status: Value(payload['status'] as String? ?? 'active'),
                updatedAt: Value(updatedAt),
              ),
            );
        break;
      case 'AdministrationRecorded':
        await db
            .into(db.administrations)
            .insertOnConflictUpdate(
              AdministrationsCompanion(
                administrationId: Value(event.entityId),
                orgId: Value(event.orgId),
                residentId: Value(payload['resident_id'] as String? ?? ''),
                orderId: Value(payload['order_id'] as String? ?? ''),
                marEntryId: Value(payload['mar_entry_id'] as String? ?? ''),
                administeredAt: Value(payload['administered_at'] as int?),
                status: Value(payload['status'] as String? ?? 'given'),
                reasonCode: Value(payload['reason_code'] as String?),
                notes: Value(payload['notes'] as String?),
                updatedAt: Value(updatedAt),
              ),
            );
        break;
      default:
        break;
    }
  }

  Future<void> _applyBootstrap(BootstrapResponse snapshot) async {
    for (final resident in snapshot.residents) {
      await db
          .into(db.residents)
          .insertOnConflictUpdate(
            ResidentsCompanion(
              residentId: Value(resident['resident_id'] as String? ?? ''),
              orgId: Value(resident['org_id'] as String? ?? ''),
              firstName: Value(resident['first_name'] as String? ?? ''),
              lastName: Value(resident['last_name'] as String? ?? ''),
              status: Value(resident['status'] as String? ?? 'active'),
              updatedAt: Value(
                resident['updated_at'] as int? ??
                    DateTime.now().millisecondsSinceEpoch,
              ),
            ),
          );
    }

    for (final order in snapshot.medicationOrders) {
      final doseValueRaw = order['dose_value'];
      final doseValue = doseValueRaw is num ? doseValueRaw.toDouble() : null;
      await db
          .into(db.medicationOrders)
          .insertOnConflictUpdate(
            MedicationOrdersCompanion(
              orderId: Value(order['order_id'] as String? ?? ''),
              orgId: Value(order['org_id'] as String? ?? ''),
              residentId: Value(order['resident_id'] as String? ?? ''),
              medicationName: Value(order['medication_name'] as String? ?? ''),
              doseValue: Value(doseValue),
              doseUnit: Value(order['dose_unit'] as String?),
              route: Value(order['route'] as String?),
              frequency: Value(order['frequency'] as String?),
              startDate: Value(order['start_date'] as int?),
              endDate: Value(order['end_date'] as int?),
              status: Value(order['status'] as String? ?? 'active'),
              updatedAt: Value(
                order['updated_at'] as int? ??
                    DateTime.now().millisecondsSinceEpoch,
              ),
            ),
          );
    }

    for (final entry in snapshot.marEntries) {
      await db
          .into(db.marEntries)
          .insertOnConflictUpdate(
            MarEntriesCompanion(
              marEntryId: Value(entry['mar_entry_id'] as String? ?? ''),
              orgId: Value(entry['org_id'] as String? ?? ''),
              residentId: Value(entry['resident_id'] as String? ?? ''),
              orderId: Value(entry['order_id'] as String? ?? ''),
              scheduledAt: Value(entry['scheduled_at'] as int? ?? 0),
              status: Value(entry['status'] as String? ?? 'scheduled'),
              updatedAt: Value(
                entry['updated_at'] as int? ??
                    DateTime.now().millisecondsSinceEpoch,
              ),
            ),
          );
    }

    for (final admin in snapshot.administrations) {
      await db
          .into(db.administrations)
          .insertOnConflictUpdate(
            AdministrationsCompanion(
              administrationId: Value(
                admin['administration_id'] as String? ?? '',
              ),
              orgId: Value(admin['org_id'] as String? ?? ''),
              residentId: Value(admin['resident_id'] as String? ?? ''),
              orderId: Value(admin['order_id'] as String? ?? ''),
              marEntryId: Value(admin['mar_entry_id'] as String? ?? ''),
              administeredAt: Value(admin['administered_at'] as int?),
              status: Value(admin['status'] as String? ?? 'given'),
              reasonCode: Value(admin['reason_code'] as String?),
              notes: Value(admin['notes'] as String?),
              updatedAt: Value(
                admin['updated_at'] as int? ??
                    DateTime.now().millisecondsSinceEpoch,
              ),
            ),
          );
    }
  }
}
