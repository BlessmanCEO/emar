import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../sync/api_client.dart';
import 'medication_round_screen.dart';

class EmarScreen extends StatefulWidget {
  const EmarScreen({super.key, this.siteFilter});

  final String? siteFilter;

  @override
  State<EmarScreen> createState() => _EmarScreenState();
}

class _EmarScreenState extends State<EmarScreen> {
  static const _apiBaseUrlFromEnv = String.fromEnvironment('API_BASE_URL');
  final _searchController = TextEditingController();
  late final ApiClient _apiClient;
  late Future<List<DemoResident>> _residentsFuture;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(baseUrl: _resolveApiBaseUrl());
    _residentsFuture = _fetchResidents();
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

  Future<List<DemoResident>> _fetchResidents() {
    return _apiClient.fetchDemoResidents();
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF4F7F9), Color(0xFFEAF2F6)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _ScreenDecor(),
              Padding(
                padding: const EdgeInsets.all(16),
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
                        Text(
                          'Residents',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF163447),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search by name',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: FutureBuilder<List<DemoResident>>(
                        future: _residentsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return _ErrorCard(
                              message:
                                  'Failed to load residents: ${snapshot.error}\n${_connectionHint()}',
                              onRetry: () {
                                setState(() {
                                  _residentsFuture = _fetchResidents();
                                });
                              },
                            );
                          }

                          final allResidents = snapshot.data ?? const [];
                          final q = _searchController.text.trim().toLowerCase();
                          final filtered = allResidents.where((resident) {
                            final siteFilter = widget.siteFilter?.trim();
                            if (siteFilter != null &&
                                siteFilter.isNotEmpty &&
                                resident.siteName.toLowerCase() !=
                                    siteFilter.toLowerCase()) {
                              return false;
                            }
                            if (q.isEmpty) return true;
                            return resident.fullName.toLowerCase().contains(
                                  q,
                                ) ||
                                resident.siteName.toLowerCase().contains(q) ||
                                (resident.addressLine1 ?? '')
                                    .toLowerCase()
                                    .contains(q);
                          }).toList();

                          if (filtered.isEmpty) {
                            final siteFilter = widget.siteFilter?.trim();
                            return _EmptyCard(
                              message: q.isEmpty
                                  ? (siteFilter == null || siteFilter.isEmpty
                                        ? 'No active residents in database.'
                                        : 'No active residents found for $siteFilter.')
                                  : 'No residents match "$q".',
                            );
                          }

                          if (_selectedIndex >= filtered.length) {
                            _selectedIndex = 0;
                          }

                          final selected = filtered[_selectedIndex];

                          return Column(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xF7FFFFFF),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: const Color(0xFFD4E1E8),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x12263A47),
                                        blurRadius: 24,
                                        offset: Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: ListView.builder(
                                    itemCount: filtered.length,
                                    itemBuilder: (context, index) {
                                      final resident = filtered[index];
                                      return _ResidentTile(
                                        resident: resident,
                                        selected: index == _selectedIndex,
                                        onTap: () => setState(
                                          () => _selectedIndex = index,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () async {
                                    try {
                                      final medications = await _apiClient
                                          .fetchDemoMedications(
                                            selected.residentId,
                                          );
                                      if (!context.mounted) return;
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => MedicationRoundScreen(
                                            residentName: selected.fullName,
                                            roomLabel: selected.siteName,
                                            dateOfBirth: selected.dateOfBirth,
                                            addressLine1: selected.addressLine1,
                                            allergies: selected.allergies,
                                            specialPreferences:
                                                selected.specialPreferences,
                                            medications: medications,
                                          ),
                                        ),
                                      );
                                    } catch (err) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Unable to load medications: $err. ${_connectionHint()}',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.play_arrow_rounded),
                                  label: Text(
                                    'Start Round',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF1C6CA1),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
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

class _ResidentTile extends StatelessWidget {
  const _ResidentTile({
    required this.resident,
    required this.selected,
    required this.onTap,
  });

  final DemoResident resident;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF1C6CA1) : const Color(0xFFF3F7FA);
    final fg = selected ? Colors.white : const Color(0xFF213948);
    final sub = selected ? Colors.white70 : const Color(0xFF5E7582);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: selected
                  ? const Color(0x40FFFFFF)
                  : const Color(0xFF2A7EB6),
              child: Text(
                resident.firstName.substring(0, 1),
                style: GoogleFonts.nunitoSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resident.fullName,
                    style: GoogleFonts.nunitoSans(
                      color: fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${resident.siteName} • ${resident.addressLine1 ?? 'No address'}',
                    style: GoogleFonts.nunitoSans(
                      color: sub,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF2E8F75),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScreenDecor extends StatelessWidget {
  const _ScreenDecor();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1F1C6CA1),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -50,
            child: Container(
              width: 170,
              height: 170,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1A2E8F75),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

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
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(message),
      ),
    );
  }
}
