import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/app_database.dart';
import '../sync/api_client.dart';
import 'emar_screen.dart';
import 'medication_round_screen.dart';

class OperationalDashboardScreen extends StatefulWidget {
  const OperationalDashboardScreen({super.key, required this.siteFilter});

  final String siteFilter;

  @override
  State<OperationalDashboardScreen> createState() =>
      _OperationalDashboardScreenState();
}

class _OperationalDashboardScreenState
    extends State<OperationalDashboardScreen> {
  static const _apiBaseUrlFromEnv = String.fromEnvironment('API_BASE_URL');

  static const _rounds = [
    _RoundSpec(index: 0, label: 'Morning', window: '08:00-09:00'),
    _RoundSpec(index: 1, label: 'Noon', window: '12:00-13:00'),
    _RoundSpec(index: 2, label: 'Evening', window: '18:00-19:00'),
    _RoundSpec(index: 3, label: 'Night', window: '21:00-22:00'),
  ];

  final _db = AppDatabase();
  late final ApiClient _apiClient;
  late Future<List<_ResidentBundle>> _bundlesFuture;
  late Future<RoundActorIdentity> _actorIdentityFuture;
  Timer? _clockTicker;
  bool _residentsExpanded = false;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(baseUrl: _resolveApiBaseUrl());
    _actorIdentityFuture = _loadActorIdentity();
    _bundlesFuture = _loadBundles();
    _clockTicker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTicker?.cancel();
    unawaited(_db.close());
    super.dispose();
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

  Future<List<_ResidentBundle>> _loadBundles() async {
    final residents = await _fetchResidentsConnected();
    final filtered = residents
        .where(
          (resident) =>
              resident.siteName.toLowerCase() ==
              widget.siteFilter.toLowerCase(),
        )
        .toList();

    return Future.wait(
      filtered.map((resident) async {
        try {
          final meds = await _fetchMedicationsConnected(resident.residentId);
          return _ResidentBundle(resident: resident, medications: meds);
        } catch (err) {
          return _ResidentBundle(
            resident: resident,
            medications: const [],
            loadError: err.toString(),
          );
        }
      }),
    );
  }

  Future<List<DemoResident>> _fetchResidentsConnected() async {
    return _apiClient.fetchDemoResidents();
  }

  Future<List<DemoMedication>> _fetchMedicationsConnected(
    String residentId,
  ) async {
    return _apiClient.fetchDemoMedications(residentId);
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

  int _dueResidentCountForRound(List<_ResidentBundle> bundles, int roundIndex) {
    var count = 0;
    for (final bundle in bundles) {
      final hasDue = bundle.medications.any(
        (med) =>
            !med.prn && _roundIndicesForMedication(med).contains(roundIndex),
      );
      if (hasDue) count += 1;
    }
    return count;
  }

  int _dueMedicationCountForRound(
    List<_ResidentBundle> bundles,
    int roundIndex,
  ) {
    var count = 0;
    for (final bundle in bundles) {
      count += bundle.medications
          .where(
            (med) =>
                !med.prn &&
                _roundIndicesForMedication(med).contains(roundIndex),
          )
          .length;
    }
    return count;
  }

  Future<void> _openResidentQuickAdmin(_ResidentBundle bundle) async {
    final actorIdentity = await _actorIdentityFuture;

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MedicationRoundScreen(
          residentId: bundle.resident.residentId,
          residentName: bundle.resident.fullName,
          siteName: bundle.resident.siteName,
          dateOfBirth: bundle.resident.dateOfBirth,
          allergies: bundle.resident.allergies,
          preferences: bundle.resident.specialPreferences,
          medicalConditions: const [],
          additionalNotes: null,
          medications: bundle.medications,
          roundLabel: 'Resident Profile',
          roundWindow: 'All active medications',
          roundIndex: 0,
          db: _db,
          actorIdentity: actorIdentity,
          roundKey: AppDatabase.roundKeyFor(DateTime.now(), 0),
          showAllMedications: true,
          autoAdvanceOnComplete: false,
          initialActions: const {},
        ),
      ),
    );

    if (!mounted) return;
    setState(() {
      _bundlesFuture = _loadBundles();
    });
  }

  String _todayLabel() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year.toString().padLeft(4, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF6FAF8), Color(0xFFEAF2EF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Operations Dashboard',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF173647),
                            ),
                          ),
                          Text(
                            '${widget.siteFilter} - ${_todayLabel()}',
                            style: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF56707F),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _bundlesFuture = _loadBundles();
                        });
                      },
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FutureBuilder<List<_ResidentBundle>>(
                    future: _bundlesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return _DashboardErrorCard(
                          message:
                              'Failed to load dashboard: ${snapshot.error}\n${_connectionHint()}',
                          onRetry: () {
                            setState(() {
                              _bundlesFuture = _loadBundles();
                            });
                          },
                        );
                      }

                      final bundles = snapshot.data ?? const [];
                      final residentBundles = [...bundles]
                        ..sort(
                          (a, b) => a.resident.fullName.toLowerCase().compareTo(
                            b.resident.fullName.toLowerCase(),
                          ),
                        );

                      return ListView(
                        children: [
                          Text(
                            'Rounds',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF1D3D4F),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ..._rounds.map((round) {
                            final dueResidents = _dueResidentCountForRound(
                              bundles,
                              round.index,
                            );
                            final dueMeds = _dueMedicationCountForRound(
                              bundles,
                              round.index,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _RoundLaunchCard(
                                round: round,
                                dueResidents: dueResidents,
                                dueMeds: dueMeds,
                                onOpen: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => EmarScreen(
                                        siteFilter: widget.siteFilter,
                                        roundOverrideIndex: round.index,
                                        roundOverrideLabel: round.label,
                                        roundOverrideWindow: round.window,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _residentsExpanded = !_residentsExpanded;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 4,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Residents',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1D3D4F),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${residentBundles.length})',
                                    style: GoogleFonts.nunitoSans(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF56707F),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    _residentsExpanded
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    color: const Color(0xFF56707F),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_residentsExpanded && residentBundles.isEmpty)
                            const _SimpleEmptyCard(
                              message: 'No residents available for this site.',
                            ),
                          if (_residentsExpanded)
                            ...residentBundles.map((bundle) {
                              final dueCount = bundle.medications
                                  .where((med) => !med.prn)
                                  .length;
                              final prnCount = bundle.medications
                                  .where((med) => med.prn)
                                  .length;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _PrnResidentCard(
                                  residentName: bundle.resident.fullName,
                                  dueCount: dueCount,
                                  prnCount: prnCount,
                                  hasLoadError: bundle.loadError != null,
                                  onOpen: () => _openResidentQuickAdmin(bundle),
                                ),
                              );
                            }),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResidentBundle {
  const _ResidentBundle({
    required this.resident,
    required this.medications,
    this.loadError,
  });

  final DemoResident resident;
  final List<DemoMedication> medications;
  final String? loadError;
}

class _RoundSpec {
  const _RoundSpec({
    required this.index,
    required this.label,
    required this.window,
  });

  final int index;
  final String label;
  final String window;
}

class _RoundLaunchCard extends StatelessWidget {
  const _RoundLaunchCard({
    required this.round,
    required this.dueResidents,
    required this.dueMeds,
    required this.onOpen,
  });

  final _RoundSpec round;
  final int dueResidents;
  final int dueMeds;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5E3EC)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${round.label} Round',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF183748),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${round.window}  -  $dueResidents residents · $dueMeds meds',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5B7482),
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: dueMeds == 0 ? null : onOpen,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1F6EA3),
            ),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class _PrnResidentCard extends StatelessWidget {
  const _PrnResidentCard({
    required this.residentName,
    required this.dueCount,
    required this.prnCount,
    required this.hasLoadError,
    required this.onOpen,
  });

  final String residentName;
  final int dueCount;
  final int prnCount;
  final bool hasLoadError;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5E3EC)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  residentName,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF183748),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasLoadError
                      ? 'Medication list unavailable'
                      : '$dueCount scheduled · $prnCount PRN',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w700,
                    color: hasLoadError
                        ? const Color(0xFF9B3F3F)
                        : const Color(0xFF5B7482),
                  ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: hasLoadError ? null : onOpen,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2F8E71),
            ),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

class _DashboardErrorCard extends StatelessWidget {
  const _DashboardErrorCard({required this.message, required this.onRetry});

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

class _SimpleEmptyCard extends StatelessWidget {
  const _SimpleEmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD5E3EC)),
      ),
      child: Text(
        message,
        style: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w700,
          color: const Color(0xFF556F7E),
        ),
      ),
    );
  }
}
