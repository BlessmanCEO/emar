import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/app_database.dart';
import '../sync/api_client.dart';
import 'medication_round_screen.dart';

class EmarScreen extends StatefulWidget {
  const EmarScreen({
    super.key,
    this.siteFilter,
    this.roundOverrideIndex,
    this.roundOverrideLabel,
    this.roundOverrideWindow,
  });

  final String? siteFilter;
  final int? roundOverrideIndex;
  final String? roundOverrideLabel;
  final String? roundOverrideWindow;

  @override
  State<EmarScreen> createState() => _EmarScreenState();
}

class _EmarScreenState extends State<EmarScreen> {
  static const _apiBaseUrlFromEnv = String.fromEnvironment('API_BASE_URL');

  final _searchController = TextEditingController();
  final _db = AppDatabase();
  late final ApiClient _apiClient;
  late final Future<RoundActorIdentity> _actorIdentityFuture;
  late Future<List<_ResidentQueueItem>> _queueFuture;
  final Map<String, RoundExecutionResult> _residentResults = {};
  final Map<String, Map<String, MedicationRoundInitialAction>>
  _persistedActionsByResident = {};
  Timer? _clockTicker;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(baseUrl: _resolveApiBaseUrl());
    _actorIdentityFuture = _loadActorIdentity();
    _queueFuture = _loadQueue();
    _clockTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTicker?.cancel();
    _searchController.dispose();
    unawaited(_db.close());
    super.dispose();
  }

  Future<RoundActorIdentity> _loadActorIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    final orgId = prefs.getString('org_id')?.trim();
    final userId = prefs.getString('user_id')?.trim();
    final username = prefs.getString('username')?.trim();

    return RoundActorIdentity(
      orgId: (orgId == null || orgId.isEmpty) ? AppDatabase.dummyOrgId : orgId,
      actorUserId: (userId == null || userId.isEmpty) ? 'demo-user' : userId,
      deviceId: 'mobile-local-device',
      staffName: username,
      siteId: widget.siteFilter,
    );
  }

  String _resolveApiBaseUrl() {
    if (_apiBaseUrlFromEnv.trim().isNotEmpty) {
      return _apiBaseUrlFromEnv.trim();
    }
    if (kIsWeb) {
      final pageUri = Uri.base;
      final scheme = pageUri.scheme.isEmpty ? 'http' : pageUri.scheme;
      final host = pageUri.host.isEmpty ? 'localhost' : pageUri.host;
      return '$scheme://$host:8080';
    }
    return 'http://10.0.2.2:8080';
  }

  String _connectionHint() {
    if (_apiBaseUrlFromEnv.trim().isNotEmpty) {
      return 'Using API_BASE_URL=$_apiBaseUrlFromEnv. Verify backend is reachable from this device.';
    }
    if (kIsWeb) {
      return 'Check backend is reachable on port 8080 from this browser host.';
    }
    return 'Set --dart-define=API_BASE_URL=http://<your-lan-ip>:8080 for physical phones, or use 10.0.2.2:8080 on Android emulator.';
  }

  Future<List<_ResidentQueueItem>> _loadQueue() async {
    final round = _currentRoundSlot();
    final roundKey = AppDatabase.roundKeyFor(DateTime.now(), round.index);
    final persisted = await _db.getAdministrationsForRoundKey(roundKey);

    final persistedByResident =
        <String, Map<String, MedicationRoundInitialAction>>{};
    for (final entry in persisted) {
      final status = _statusFromAdministration(entry.status);
      if (status == null) continue;
      persistedByResident.putIfAbsent(entry.residentId, () => {});
      persistedByResident[entry.residentId]![entry.orderId] =
          MedicationRoundInitialAction(
            status: status,
            timestamp: DateTime.fromMillisecondsSinceEpoch(
              entry.administeredAt ?? entry.updatedAt,
            ),
            reason: entry.reasonCode,
            note: entry.notes,
          );
    }

    _persistedActionsByResident
      ..clear()
      ..addAll(persistedByResident);

    final residents = await _fetchResidentsConnected();
    final siteFilter = widget.siteFilter?.trim();
    final filtered = residents.where((resident) {
      if (siteFilter == null || siteFilter.isEmpty) {
        return true;
      }
      return resident.siteName.toLowerCase() == siteFilter.toLowerCase();
    }).toList();

    final items = await Future.wait(
      filtered.map((resident) async {
        try {
          final meds = await _fetchMedicationsConnected(resident.residentId);
          return _ResidentQueueItem(resident: resident, medications: meds);
        } catch (err) {
          return _ResidentQueueItem(
            resident: resident,
            medications: const [],
            medicationLoadError: err.toString(),
          );
        }
      }),
    );

    final seededResults = <String, RoundExecutionResult>{};
    for (final item in items) {
      final persistedActions =
          _persistedActionsByResident[item.resident.residentId] ??
          const <String, MedicationRoundInitialAction>{};

      final due = item.medications.where((med) {
        if (med.prn) return false;
        final rounds = _roundIndicesForMedication(med);
        return rounds.contains(round.index);
      }).toList();

      var taken = 0;
      var refused = 0;
      var withheld = 0;
      var completed = 0;

      for (final med in due) {
        final action = persistedActions[med.orderId];
        if (action == null) continue;
        completed += 1;
        switch (action.status) {
          case RoundActionStatus.taken:
            taken += 1;
            break;
          case RoundActionStatus.refused:
            refused += 1;
            break;
          case RoundActionStatus.withheld:
            withheld += 1;
            break;
        }
      }

      final pending = due.length - completed;
      seededResults[item.resident.residentId] = RoundExecutionResult(
        totalDue: due.length,
        completed: completed,
        pending: pending,
        taken: taken,
        refused: refused,
        withheld: withheld,
        prnFollowUpsScheduled: 0,
        roundComplete: due.isNotEmpty && pending == 0,
        autoAdvance: false,
      );
    }

    _residentResults
      ..clear()
      ..addAll(seededResults);

    return items;
  }

  Future<List<DemoResident>> _fetchResidentsConnected() async {
    try {
      return await _apiClient.fetchDemoResidents();
    } catch (_) {
      final rows = await _db.getActiveResidents();
      return rows
          .map(
            (row) => DemoResident(
              residentId: row.residentId,
              firstName: row.firstName,
              lastName: row.lastName,
              status: row.status,
              dateOfBirth: null,
              siteName: AppDatabase.siteNameForResidentId(row.residentId),
              addressLine1: null,
              allergies: null,
              specialPreferences: const [],
            ),
          )
          .toList();
    }
  }

  Future<List<DemoMedication>> _fetchMedicationsConnected(
    String residentId,
  ) async {
    try {
      return await _apiClient.fetchDemoMedications(residentId);
    } catch (_) {
      final rows = await _db.getActiveMedicationOrdersForResident(residentId);
      return rows
          .map(
            (row) => DemoMedication(
              orderId: row.orderId,
              residentId: row.residentId,
              medicationName: row.medicationName,
              rawStrength: _strengthFromOrder(row.doseValue, row.doseUnit),
              doseText: _strengthFromOrder(row.doseValue, row.doseUnit),
              doseValue: row.doseValue,
              doseUnit: row.doseUnit,
              route: row.route,
              instructions: null,
              prn: false,
              isControlledDrug: false,
              frequency: row.frequency,
              scheduledTimes: const [],
              timingSlots: _inferTimingSlots(row.frequency),
              timingTimes: const [],
              status: row.status,
            ),
          )
          .toList();
    }
  }

  String? _strengthFromOrder(double? doseValue, String? doseUnit) {
    if (doseValue == null) return null;
    final formatted = doseValue.truncateToDouble() == doseValue
        ? doseValue.toStringAsFixed(0)
        : doseValue.toStringAsFixed(1);
    final unit = doseUnit?.trim();
    if (unit == null || unit.isEmpty) return formatted;
    return '$formatted $unit';
  }

  List<String> _inferTimingSlots(String? frequency) {
    if (frequency == null || frequency.trim().isEmpty) {
      return const [];
    }
    final value = frequency.toLowerCase();
    final output = <String>[];
    if (value.contains('morning')) output.add('Morning');
    if (value.contains('noon')) output.add('Noon');
    if (value.contains('evening')) output.add('Evening');
    if (value.contains('night')) output.add('Night');
    return output;
  }

  RoundActionStatus? _statusFromAdministration(String status) {
    switch (status.toLowerCase()) {
      case 'given':
      case 'taken':
        return RoundActionStatus.taken;
      case 'refused':
        return RoundActionStatus.refused;
      case 'withheld':
        return RoundActionStatus.withheld;
      default:
        return null;
    }
  }

  _RoundSlot _currentRoundSlot() {
    if (widget.roundOverrideIndex != null &&
        widget.roundOverrideLabel != null &&
        widget.roundOverrideWindow != null) {
      return _RoundSlot(
        label: widget.roundOverrideLabel!,
        window: widget.roundOverrideWindow!,
        index: widget.roundOverrideIndex!,
      );
    }

    final hour = DateTime.now().hour;
    if (hour < 11) {
      return const _RoundSlot(
        label: 'Morning',
        window: '08:00-09:00',
        index: 0,
      );
    }
    if (hour < 16) {
      return const _RoundSlot(label: 'Noon', window: '12:00-13:00', index: 1);
    }
    if (hour < 20) {
      return const _RoundSlot(
        label: 'Evening',
        window: '18:00-19:00',
        index: 2,
      );
    }
    return const _RoundSlot(label: 'Night', window: '21:00-22:00', index: 3);
  }

  Set<int> _roundIndicesForMedication(DemoMedication medication) {
    final output = <int>{};

    for (final value in medication.scheduledTimes) {
      final round = _roundFromClock(value);
      if (round != null) output.add(round);
    }

    for (final value in medication.timingTimes) {
      final round = _roundFromClock(value);
      if (round != null) output.add(round);
    }

    for (final slot in medication.timingSlots) {
      final normalized = slot.toLowerCase();
      if (normalized == 'morning') output.add(0);
      if (normalized == 'noon') output.add(1);
      if (normalized == 'evening') output.add(2);
      if (normalized == 'night') output.add(3);
    }

    return output;
  }

  int? _roundFromClock(String value) {
    final hour = int.tryParse(value.split(':').first);
    if (hour == null) return null;
    if (hour < 11) return 0;
    if (hour < 16) return 1;
    if (hour < 20) return 2;
    return 3;
  }

  int? _earliestRoundIndex(DemoMedication medication) {
    final rounds = _roundIndicesForMedication(medication);
    if (rounds.isEmpty) return null;
    return rounds.reduce((a, b) => a < b ? a : b);
  }

  bool _isHighRisk(DemoMedication medication) {
    if (medication.isControlledDrug) return true;
    final name = medication.medicationName.toLowerCase();
    return name.contains('warfarin') ||
        name.contains('insulin') ||
        name.contains('morphine');
  }

  int _overdueCount(_ResidentQueueItem item, int roundIndex) {
    return item.medications.where((med) {
      if (med.prn) return false;
      final earliest = _earliestRoundIndex(med);
      if (earliest == null) return false;
      return earliest < roundIndex &&
          !_roundIndicesForMedication(med).contains(roundIndex);
    }).length;
  }

  int _highRiskDueCount(_ResidentQueueItem item, int roundIndex) {
    return item.medications.where((med) {
      if (med.prn) return false;
      return _roundIndicesForMedication(med).contains(roundIndex) &&
          _isHighRisk(med);
    }).length;
  }

  int _dueCount(_ResidentQueueItem item, int roundIndex) {
    final result = _residentResults[item.resident.residentId];
    if (result != null) {
      return result.pending;
    }
    return item.medications.where((med) {
      if (med.prn) return false;
      return _roundIndicesForMedication(med).contains(roundIndex);
    }).length;
  }

  _ResidentRoundStatus _statusFor(_ResidentQueueItem item, int roundIndex) {
    final result = _residentResults[item.resident.residentId];
    if (result != null) {
      if (result.roundComplete || result.pending == 0) {
        return _ResidentRoundStatus.complete;
      }
      return _ResidentRoundStatus.partial;
    }
    final due = _dueCount(item, roundIndex);
    if (due == 0) return _ResidentRoundStatus.complete;
    return _ResidentRoundStatus.pending;
  }

  List<_ResidentQueueItem> _sortedResidents(
    List<_ResidentQueueItem> residents,
    int roundIndex,
  ) {
    final sorted = [...residents];
    sorted.sort((a, b) {
      final statusA = _statusFor(a, roundIndex).priority;
      final statusB = _statusFor(b, roundIndex).priority;
      if (statusA != statusB) return statusA.compareTo(statusB);

      final overdueA = _overdueCount(a, roundIndex);
      final overdueB = _overdueCount(b, roundIndex);
      if (overdueA != overdueB) return overdueB.compareTo(overdueA);

      final highRiskA = _highRiskDueCount(a, roundIndex);
      final highRiskB = _highRiskDueCount(b, roundIndex);
      if (highRiskA != highRiskB) return highRiskB.compareTo(highRiskA);

      final dueA = _dueCount(a, roundIndex);
      final dueB = _dueCount(b, roundIndex);
      if (dueA != dueB) return dueB.compareTo(dueA);

      return a.resident.fullName.toLowerCase().compareTo(
        b.resident.fullName.toLowerCase(),
      );
    });
    return sorted;
  }

  Future<void> _openResidentRound(
    _ResidentQueueItem item,
    List<_ResidentQueueItem> orderedResidents,
  ) async {
    final round = _currentRoundSlot();
    final roundKey = AppDatabase.roundKeyFor(DateTime.now(), round.index);
    final actorIdentity = await _actorIdentityFuture;

    if (!mounted) return;

    if (item.medicationLoadError != null && item.medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to preload medications for ${item.resident.fullName}: ${item.medicationLoadError}',
          ),
        ),
      );
      return;
    }

    final result = await Navigator.of(context).push<RoundExecutionResult>(
      MaterialPageRoute(
        builder: (_) => MedicationRoundScreen(
          residentId: item.resident.residentId,
          residentName: item.resident.fullName,
          siteName: item.resident.siteName,
          dateOfBirth: item.resident.dateOfBirth,
          allergies: item.resident.allergies,
          medications: item.medications,
          roundLabel: round.label,
          roundWindow: round.window,
          roundIndex: round.index,
          db: _db,
          actorIdentity: actorIdentity,
          roundKey: roundKey,
          initialActions:
              _persistedActionsByResident[item.resident.residentId] ?? const {},
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      _residentResults[item.resident.residentId] = result;
    });

    if (!result.autoAdvance) return;

    final next = _findNextResident(
      orderedResidents,
      currentResidentId: item.resident.residentId,
      roundIndex: round.index,
    );

    if (next == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Round queue complete.')));
      return;
    }

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    await _openResidentRound(next, orderedResidents);
  }

  _ResidentQueueItem? _findNextResident(
    List<_ResidentQueueItem> orderedResidents, {
    required String currentResidentId,
    required int roundIndex,
  }) {
    final currentIndex = orderedResidents.indexWhere(
      (item) => item.resident.residentId == currentResidentId,
    );
    if (currentIndex == -1) return null;
    for (var i = currentIndex + 1; i < orderedResidents.length; i += 1) {
      final candidate = orderedResidents[i];
      final status = _statusFor(candidate, roundIndex);
      if (status != _ResidentRoundStatus.complete &&
          _dueCount(candidate, roundIndex) > 0) {
        return candidate;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final round = _currentRoundSlot();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF5F9FC), Color(0xFFEAF1F5)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _QueueDecor(),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              Navigator.of(
                                context,
                              ).pushReplacementNamed('/site-select');
                            }
                          },
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        Expanded(
                          child: Text(
                            'Round Queue',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 29,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF163447),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _queueFuture = _loadQueue();
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search residents',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: FutureBuilder<List<_ResidentQueueItem>>(
                        future: _queueFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          if (snapshot.hasError) {
                            return _QueueErrorCard(
                              message:
                                  'Failed to load resident queue: ${snapshot.error}\n${_connectionHint()}',
                              onRetry: () {
                                setState(() {
                                  _queueFuture = _loadQueue();
                                });
                              },
                            );
                          }

                          final allResidents = snapshot.data ?? const [];
                          final query = _searchController.text
                              .trim()
                              .toLowerCase();
                          final filtered = allResidents.where((item) {
                            if (query.isEmpty) return true;
                            return item.resident.fullName
                                    .toLowerCase()
                                    .contains(query) ||
                                item.resident.siteName.toLowerCase().contains(
                                  query,
                                );
                          }).toList();

                          if (filtered.isEmpty) {
                            return const _QueueEmptyCard(
                              message: 'No residents match this search.',
                            );
                          }

                          final ordered = _sortedResidents(
                            filtered,
                            round.index,
                          );
                          final completed = ordered
                              .where(
                                (item) =>
                                    _statusFor(item, round.index) ==
                                    _ResidentRoundStatus.complete,
                              )
                              .length;

                          return Column(
                            children: [
                              _RoundStatusBar(
                                roundLabel: round.label,
                                roundWindow: round.window,
                                completedResidents: completed,
                                totalResidents: ordered.length,
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: ordered.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final item = ordered[index];
                                    final dueCount = _dueCount(
                                      item,
                                      round.index,
                                    );
                                    final overdueCount = _overdueCount(
                                      item,
                                      round.index,
                                    );
                                    final highRisk = _highRiskDueCount(
                                      item,
                                      round.index,
                                    );
                                    final status = _statusFor(
                                      item,
                                      round.index,
                                    );

                                    return _ResidentQueueCard(
                                      residentName: item.resident.fullName,
                                      dueCount: dueCount,
                                      overdueCount: overdueCount,
                                      highRiskCount: highRisk,
                                      status: status,
                                      onTap: () =>
                                          _openResidentRound(item, ordered),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundSlot {
  const _RoundSlot({
    required this.label,
    required this.window,
    required this.index,
  });

  final String label;
  final String window;
  final int index;
}

class _ResidentQueueItem {
  const _ResidentQueueItem({
    required this.resident,
    required this.medications,
    this.medicationLoadError,
  });

  final DemoResident resident;
  final List<DemoMedication> medications;
  final String? medicationLoadError;
}

enum _ResidentRoundStatus {
  pending(priority: 0, label: 'pending', color: Color(0xFF4A6B7C)),
  partial(priority: 1, label: 'partial', color: Color(0xFF9B6A2F)),
  complete(priority: 2, label: 'complete', color: Color(0xFF2D8B6F));

  const _ResidentRoundStatus({
    required this.priority,
    required this.label,
    required this.color,
  });

  final int priority;
  final String label;
  final Color color;
}

class _RoundStatusBar extends StatelessWidget {
  const _RoundStatusBar({
    required this.roundLabel,
    required this.roundWindow,
    required this.completedResidents,
    required this.totalResidents,
  });

  final String roundLabel;
  final String roundWindow;
  final int completedResidents;
  final int totalResidents;

  @override
  Widget build(BuildContext context) {
    final progress = totalResidents == 0
        ? 0.0
        : (completedResidents / totalResidents).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD3E1EA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$roundLabel Round - $roundWindow',
            style: GoogleFonts.nunitoSans(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF173647),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Progress: $completedResidents / $totalResidents residents',
            style: GoogleFonts.nunitoSans(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF5A7382),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              color: const Color(0xFF2F8E71),
              backgroundColor: const Color(0xFFE3EEF4),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResidentQueueCard extends StatelessWidget {
  const _ResidentQueueCard({
    required this.residentName,
    required this.dueCount,
    required this.overdueCount,
    required this.highRiskCount,
    required this.status,
    required this.onTap,
  });

  final String residentName;
  final int dueCount;
  final int overdueCount;
  final int highRiskCount;
  final _ResidentRoundStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final riskColor = highRiskCount > 0
        ? const Color(0xFFC45454)
        : overdueCount > 0
        ? const Color(0xFFCA8A2F)
        : const Color(0xFF2F8E71);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD5E2EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: riskColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      residentName,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF173647),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Due meds: $dueCount',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5A7382),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: status.color,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status.label,
                  style: GoogleFonts.nunitoSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF617A88)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueDecor extends StatelessWidget {
  const _QueueDecor();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            right: -54,
            top: -48,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1A2D7DB3),
              ),
            ),
          ),
          Positioned(
            left: -38,
            bottom: -55,
            child: Container(
              width: 160,
              height: 160,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x142C8A6E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueErrorCard extends StatelessWidget {
  const _QueueErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD7E3EB)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _QueueEmptyCard extends StatelessWidget {
  const _QueueEmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD7E3EB)),
        ),
        child: Text(message),
      ),
    );
  }
}
