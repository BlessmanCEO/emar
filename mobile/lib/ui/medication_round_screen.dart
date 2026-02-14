import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sync/api_client.dart';

class MedicationRoundScreen extends StatefulWidget {
  const MedicationRoundScreen({
    super.key,
    required this.residentName,
    required this.roomLabel,
    required this.dateOfBirth,
    required this.addressLine1,
    required this.allergies,
    required this.specialPreferences,
    required this.medications,
  });

  final String residentName;
  final String roomLabel;
  final String? dateOfBirth;
  final String? addressLine1;
  final String? allergies;
  final List<String> specialPreferences;
  final List<DemoMedication> medications;

  @override
  State<MedicationRoundScreen> createState() => _MedicationRoundScreenState();
}

class _MedicationRoundScreenState extends State<MedicationRoundScreen> {
  static const _tabs = ['Morning', 'Noon', 'Evening', 'Night', 'PRN'];
  static const _regularTabs = ['Morning', 'Noon', 'Evening', 'Night'];
  static const _timeWindows = {
    'Morning': '08:00 - 09:00',
    'Noon': '12:00 - 13:00',
    'Evening': '18:00 - 19:00',
    'Night': '21:00 - 22:00',
    'PRN': 'As required',
  };
  int _tabIndex = 0;
  String? _expandedMedicationId;
  late final TextEditingController _dosageController;
  late final TextEditingController _noteController;
  late final TextEditingController _chainNoteController;
  DateTime _selectedDateTime = DateTime.now();
  String _administeredBy = 'Staff Member';
  bool _chainMode = false;
  final Set<String> _chainSelectedIds = {};
  final Map<String, _TakenRecord> _takenByMedication = {};
  final Map<String, _SkippedRecord> _skippedByMedication = {};

  @override
  void initState() {
    super.initState();
    _dosageController = TextEditingController();
    _noteController = TextEditingController();
    _chainNoteController = TextEditingController();
    _loadAdministeredBy();
  }

  Future<void> _loadAdministeredBy() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username')?.trim();
    if (!mounted) return;
    if (username != null && username.isNotEmpty) {
      setState(() {
        _administeredBy = username;
      });
    }
  }

  @override
  void dispose() {
    _dosageController.dispose();
    _noteController.dispose();
    _chainNoteController.dispose();
    super.dispose();
  }

  void _toggleChainMode() {
    setState(() {
      _chainMode = !_chainMode;
      _expandedMedicationId = null;
      _chainSelectedIds.clear();
      _chainNoteController.clear();
    });
  }

  void _toggleChainSelection(DemoMedication medication) {
    setState(() {
      if (_chainSelectedIds.contains(medication.orderId)) {
        _chainSelectedIds.remove(medication.orderId);
      } else {
        _chainSelectedIds.add(medication.orderId);
      }
    });
  }

  Future<void> _applyChainAction(_ChainAction action) async {
    if (_chainSelectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select medications first.')),
      );
      return;
    }

    final note = _chainNoteController.text.trim();
    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter one general note.')),
      );
      return;
    }

    final now = DateTime.now();
    setState(() {
      for (final id in _chainSelectedIds) {
        if (action == _ChainAction.taken) {
          _takenByMedication[id] = _TakenRecord(
            administeredAt: now,
            administeredBy: _administeredBy,
            note: note,
          );
          _skippedByMedication.remove(id);
        } else {
          _skippedByMedication[id] = _SkippedRecord(
            skippedAt: now,
            skippedBy: _administeredBy,
            reasonType: _SkipReasonType.refused,
            reasonText: 'Refused: $note',
          );
          _takenByMedication.remove(id);
        }
      }
      _chainSelectedIds.clear();
      _chainNoteController.clear();
    });

    final label = action == _ChainAction.taken ? 'taken' : 'refused';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected medications marked as $label.')),
    );
  }

  void _selectTab(int index) {
    setState(() {
      _tabIndex = index;
      _expandedMedicationId = null;
    });
  }

  void _toggleMedication(DemoMedication medication) {
    setState(() {
      if (_expandedMedicationId == medication.orderId) {
        _expandedMedicationId = null;
        return;
      }

      _expandedMedicationId = medication.orderId;
      _selectedDateTime = DateTime.now();
      _dosageController.text = _doseValueFor(medication);
      _noteController.clear();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      _selectedDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (picked == null) return;
    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _handleSkip(DemoMedication medication) async {
    final result = await _showSkipReasonPrompt();
    if (result == null) return;
    if (!mounted) return;

    setState(() {
      _skippedByMedication[medication.orderId] = _SkippedRecord(
        skippedAt: _selectedDateTime,
        skippedBy: _administeredBy,
        reasonType: result.type,
        reasonText: result.reasonText,
      );
      _takenByMedication.remove(medication.orderId);
      _expandedMedicationId = null;
      _noteController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Skipped ${medication.medicationName}: ${result.reasonText}.',
        ),
      ),
    );
  }

  Future<void> _handleTake(DemoMedication medication) async {
    final note = _noteController.text.trim();
    if (note.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a note before confirming.')),
      );
      return;
    }

    setState(() {
      _takenByMedication[medication.orderId] = _TakenRecord(
        administeredAt: _selectedDateTime,
        administeredBy: _administeredBy,
        note: note,
      );
      _skippedByMedication.remove(medication.orderId);
      _expandedMedicationId = null;
      _noteController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Taken at ${_formatTime(_selectedDateTime)} by $_administeredBy.',
        ),
      ),
    );
  }

  Future<_SkipReasonResult?> _showSkipReasonPrompt() {
    return showModalBottomSheet<_SkipReasonResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        var selectedType = _SkipReasonType.refused;
        final reasonController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setModalState) {
            final requiresText =
                selectedType == _SkipReasonType.refused ||
                selectedType == _SkipReasonType.other;

            String defaultReason() {
              return switch (selectedType) {
                _SkipReasonType.refused => 'Refused',
                _SkipReasonType.outOfService => 'Out of service',
                _SkipReasonType.other => 'Other',
              };
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reason for Skip',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF183141),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SkipReasonOption(
                    label: 'Refused',
                    value: _SkipReasonType.refused,
                    groupValue: selectedType,
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => selectedType = value);
                    },
                  ),
                  _SkipReasonOption(
                    label: 'Out of service',
                    value: _SkipReasonType.outOfService,
                    groupValue: selectedType,
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => selectedType = value);
                    },
                  ),
                  _SkipReasonOption(
                    label: 'Other',
                    value: _SkipReasonType.other,
                    groupValue: selectedType,
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() => selectedType = value);
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: requiresText
                          ? 'Enter reason details (required)'
                          : 'Optional details',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final details = reasonController.text.trim();
                        if (requiresText && details.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter the skip reason.'),
                            ),
                          );
                          return;
                        }

                        final reasonText = details.isEmpty
                            ? defaultReason()
                            : '${defaultReason()}: $details';

                        Navigator.of(context).pop(
                          _SkipReasonResult(
                            type: selectedType,
                            reasonText: reasonText,
                          ),
                        );
                      },
                      child: const Text('Confirm Skip Reason'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _doseValueFor(DemoMedication medication) {
    if (medication.doseValue != null) {
      final value = medication.doseValue!;
      final fixed = value.truncateToDouble() == value ? 1 : 2;
      return value.toStringAsFixed(fixed);
    }

    final summary = _doseSummaryFor(medication);
    final match = RegExp(r'\d+(?:\.\d+)?').firstMatch(summary);
    return match?.group(0) ?? '1.0';
  }

  String _formatDate(DateTime value) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = value.day.toString().padLeft(2, '0');
    return '$day-${months[value.month - 1]}-${value.year}';
  }

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<DemoMedication> _medicationsForTab(String tab) {
    return widget.medications.where((med) {
      if (tab == 'PRN') {
        return med.prn;
      }
      if (med.prn) {
        return false;
      }
      if (med.timingSlots.isNotEmpty) {
        return med.timingSlots.contains(tab);
      }

      final fallbackIndex = med.orderId.hashCode.abs() % _regularTabs.length;
      return _regularTabs[fallbackIndex] == tab;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F9FB), Color(0xFFEDF3F8)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _RoundHeader(
                residentName: widget.residentName,
                roomLabel: widget.roomLabel,
                dateOfBirth: widget.dateOfBirth,
                addressLine1: widget.addressLine1,
                allergies: widget.allergies,
                specialPreferences: widget.specialPreferences,
              ),
              const SizedBox(height: 10),
              _ShiftTabs(
                tabs: _tabs,
                selectedIndex: _tabIndex,
                onSelect: _selectTab,
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF92BCE5)),
                ),
                child: Text(
                  _timeWindows[_tabs[_tabIndex]] ?? '08:00 - 09:00',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF145B93),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: _ChainModeStrip(
                  enabled: _chainMode,
                  selectedCount: _chainSelectedIds.length,
                  onToggle: _toggleChainMode,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Builder(
                  builder: (context) {
                    final activeTab = _tabs[_tabIndex];
                    final filtered = _medicationsForTab(activeTab);

                    if (widget.medications.isEmpty) {
                      return const Center(
                        child: Text(
                          'No active medication orders for this resident.',
                        ),
                      );
                    }

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          activeTab == 'PRN'
                              ? 'No PRN medications for this resident.'
                              : 'No medications scheduled for $activeTab.',
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final medication = filtered[index];
                        final expanded =
                            _expandedMedicationId == medication.orderId;
                        final selectedInChain = _chainSelectedIds.contains(
                          medication.orderId,
                        );
                        return _MedicationCard(
                          card: medication,
                          activeWindow:
                              _timeWindows[activeTab] ?? '08:00 - 09:00',
                          expanded: _chainMode ? false : expanded,
                          chainMode: _chainMode,
                          chainSelected: selectedInChain,
                          takenRecord: _takenByMedication[medication.orderId],
                          skippedRecord:
                              _skippedByMedication[medication.orderId],
                          onTap: () => _chainMode
                              ? _toggleChainSelection(medication)
                              : _toggleMedication(medication),
                          takePanel: (!_chainMode && expanded)
                              ? _TakeMedicationPanel(
                                  medication: medication,
                                  dosageController: _dosageController,
                                  noteController: _noteController,
                                  selectedDateTime: _selectedDateTime,
                                  onPickDate: _pickDate,
                                  onPickTime: _pickTime,
                                  onSkip: () => _handleSkip(medication),
                                  onTake: () => _handleTake(medication),
                                  onCollapse: () =>
                                      _toggleMedication(medication),
                                  formatDate: _formatDate,
                                  formatTime: _formatTime,
                                )
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _chainMode
          ? _ChainActionBar(
              noteController: _chainNoteController,
              selectedCount: _chainSelectedIds.length,
              onMarkTaken: () => _applyChainAction(_ChainAction.taken),
              onMarkRefused: () => _applyChainAction(_ChainAction.refused),
            )
          : null,
    );
  }
}

class _RoundHeader extends StatelessWidget {
  const _RoundHeader({
    required this.residentName,
    required this.roomLabel,
    required this.dateOfBirth,
    required this.addressLine1,
    required this.allergies,
    required this.specialPreferences,
  });

  final String residentName;
  final String roomLabel;
  final String? dateOfBirth;
  final String? addressLine1;
  final String? allergies;
  final List<String> specialPreferences;

  void _openResidentProfile(BuildContext context) {
    final allergyText = allergies?.trim().isNotEmpty == true
        ? allergies!.trim()
        : 'No known allergies';
    final preferences = specialPreferences.isEmpty
        ? const ['No special preferences recorded']
        : specialPreferences;

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '$residentName Profile',
            style: GoogleFonts.nunitoSans(fontWeight: FontWeight.w900),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Allergies',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF274457),
                  ),
                ),
                Text(
                  allergyText,
                  style: GoogleFonts.nunitoSans(
                    color: const Color(0xFF496171),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Medical conditions',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF274457),
                  ),
                ),
                Text(
                  'Not available in demo data',
                  style: GoogleFonts.nunitoSans(
                    color: const Color(0xFF496171),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Special preferences',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF274457),
                  ),
                ),
                const SizedBox(height: 4),
                ...preferences.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      '- $item',
                      style: GoogleFonts.nunitoSans(
                        color: const Color(0xFF496171),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const CircleAvatar(
            radius: 19,
            backgroundColor: Color(0xFFDDEAF4),
            child: Icon(Icons.person_rounded, color: Color(0xFF315269)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _openResidentProfile(context),
                  child: Text(
                    residentName,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A5EA0),
                      decoration: TextDecoration.underline,
                      decorationColor: const Color(0xFF1A5EA0),
                    ),
                  ),
                ),
                Text(
                  dateOfBirth?.trim().isNotEmpty == true
                      ? 'DOB: ${dateOfBirth!.trim()} | Default'
                      : 'DOB: Not recorded | Default',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    color: const Color(0xFF5B7282),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  addressLine1?.trim().isNotEmpty == true
                      ? 'Address: ${addressLine1!.trim()}'
                      : 'Address: Not recorded',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 14,
                    color: const Color(0xFF5B7282),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            roomLabel,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3A5567),
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
    );
  }
}

class _ShiftTabs extends StatelessWidget {
  const _ShiftTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final selected = index == selectedIndex;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected ? const Color(0xFF1B6DA5) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD3E1EC)),
                ),
                child: Text(
                  tabs[index],
                  style: GoogleFonts.nunitoSans(
                    color: selected ? Colors.white : const Color(0xFF294457),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

enum _ChainAction { taken, refused }

class _ChainModeStrip extends StatelessWidget {
  const _ChainModeStrip({
    required this.enabled,
    required this.selectedCount,
    required this.onToggle,
  });

  final bool enabled;
  final int selectedCount;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: enabled ? const Color(0xFFE6F2FF) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: enabled ? const Color(0xFF8FB8DE) : const Color(0xFFD6E3EC),
        ),
      ),
      child: Row(
        children: [
          Text(
            enabled
                ? 'Round chain enabled ($selectedCount selected)'
                : 'Round chain disabled',
            style: GoogleFonts.nunitoSans(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF27485D),
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: onToggle,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: enabled
                    ? const Color(0xFF1C6CA1)
                    : const Color(0xFFA9BFD0),
              ),
            ),
            child: Text(enabled ? 'Stop' : 'Start'),
          ),
        ],
      ),
    );
  }
}

class _ChainActionBar extends StatelessWidget {
  const _ChainActionBar({
    required this.noteController,
    required this.selectedCount,
    required this.onMarkTaken,
    required this.onMarkRefused,
  });

  final TextEditingController noteController;
  final int selectedCount;
  final Future<void> Function() onMarkTaken;
  final Future<void> Function() onMarkRefused;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFD5E1EA))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chain round: $selectedCount selected',
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF26485D),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: noteController,
              minLines: 1,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'General note (required)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                isDense: true,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      onMarkRefused();
                    },
                    child: const Text('Mark Refused'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      onMarkTaken();
                    },
                    child: const Text('Mark Taken'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _doseSummaryFor(DemoMedication medication) {
  final dose = medication.doseValue == null
      ? ''
      : medication.doseValue!.toStringAsFixed(
          medication.doseValue!.truncateToDouble() == medication.doseValue
              ? 0
              : 1,
        );
  final amount = [
    dose,
    medication.doseUnit ?? '',
  ].where((part) => part.isNotEmpty).join(' ');
  if (medication.doseText?.trim().isNotEmpty == true) {
    return medication.doseText!.trim();
  }
  return amount.isEmpty ? 'Dose not specified' : amount;
}

String _timingSummaryFor(DemoMedication medication) {
  if (medication.timingTimes.isNotEmpty) {
    return medication.timingTimes.join(', ');
  }
  if (medication.frequency?.trim().isNotEmpty == true) {
    return medication.frequency!.trim();
  }
  return 'No timing text';
}

String _lastTakenFor(DemoMedication medication) {
  final hash = medication.orderId.hashCode.abs();
  final hours = 1 + (hash % 23);
  final minutes = (hash ~/ 23) % 60;
  return 'Last Taken: ${hours}h ${minutes}m ago';
}

String _clockTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

enum _SkipReasonType { refused, outOfService, other }

class _SkipReasonResult {
  const _SkipReasonResult({required this.type, required this.reasonText});

  final _SkipReasonType type;
  final String reasonText;
}

class _TakenRecord {
  const _TakenRecord({
    required this.administeredAt,
    required this.administeredBy,
    required this.note,
  });

  final DateTime administeredAt;
  final String administeredBy;
  final String note;
}

class _SkippedRecord {
  const _SkippedRecord({
    required this.skippedAt,
    required this.skippedBy,
    required this.reasonType,
    required this.reasonText,
  });

  final DateTime skippedAt;
  final String skippedBy;
  final _SkipReasonType reasonType;
  final String reasonText;
}

class _SkipReasonOption extends StatelessWidget {
  const _SkipReasonOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final _SkipReasonType value;
  final _SkipReasonType groupValue;
  final ValueChanged<_SkipReasonType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<_SkipReasonType>(
      value: value,
      groupValue: groupValue,
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(
        label,
        style: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w800,
          color: const Color(0xFF2A4454),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({
    required this.card,
    required this.activeWindow,
    required this.expanded,
    required this.chainMode,
    required this.chainSelected,
    required this.takenRecord,
    required this.skippedRecord,
    required this.onTap,
    this.takePanel,
  });

  final DemoMedication card;
  final String activeWindow;
  final bool expanded;
  final bool chainMode;
  final bool chainSelected;
  final _TakenRecord? takenRecord;
  final _SkippedRecord? skippedRecord;
  final VoidCallback onTap;
  final Widget? takePanel;

  @override
  Widget build(BuildContext context) {
    final doseSummary = _doseSummaryFor(card);
    final timingSummary = _timingSummaryFor(card);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: expanded
                  ? const Color(0xFF79AAD3)
                  : const Color(0xFFD9E5EE),
            ),
            boxShadow: expanded
                ? const [
                    BoxShadow(
                      color: Color(0x1A1C6CA1),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (chainMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        chainSelected
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: chainSelected
                            ? const Color(0xFF1C6CA1)
                            : const Color(0xFF7B93A4),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFC7DDF1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 15,
                          color: Color(0xFF1C6CA1),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Scheduled $activeWindow',
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF255A84),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (!chainMode)
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF4D687A),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                card.medicationName,
                style: GoogleFonts.nunitoSans(
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF112B3A),
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      doseSummary,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        color: const Color(0xFF4E6675),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    'More Info',
                    style: GoogleFonts.nunitoSans(
                      color: const Color(0xFF546F80),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  Text(
                    'To be taken: 1',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14,
                      color: const Color(0xFF304A5A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D9AEB),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _lastTakenFor(card),
                      style: GoogleFonts.nunitoSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Timing: $timingSummary',
                style: GoogleFonts.nunitoSans(
                  fontSize: 13,
                  color: const Color(0xFF5A7281),
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (card.route?.isNotEmpty == true || card.isControlledDrug) ...[
                const SizedBox(height: 5),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (card.route?.isNotEmpty == true)
                      _PillLabel(
                        label: card.route!,
                        color: const Color(0xFFEFF5FA),
                        textColor: const Color(0xFF385566),
                      ),
                    if (card.isControlledDrug)
                      const _PillLabel(
                        label: 'Controlled Drug',
                        color: Color(0xFFFDF0E4),
                        textColor: Color(0xFF8C4B1E),
                      ),
                  ],
                ),
              ],
              if (takePanel != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFDCE6EE)),
                const SizedBox(height: 10),
                takePanel!,
              ],
              if (takenRecord != null || skippedRecord != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFDCE6EE)),
                const SizedBox(height: 8),
                if (takenRecord != null)
                  Text(
                    'Administered at ${_clockTime(takenRecord!.administeredAt)} by ${takenRecord!.administeredBy}',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13,
                      color: const Color(0xFF2E6A4D),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                if (takenRecord != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Note: ${takenRecord!.note}',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13,
                      color: const Color(0xFF3E5D4D),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                if (skippedRecord != null)
                  Text(
                    'Skipped at ${_clockTime(skippedRecord!.skippedAt)} by ${skippedRecord!.skippedBy} - ${skippedRecord!.reasonText}',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13,
                      color: const Color(0xFF7A592D),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TakeMedicationPanel extends StatelessWidget {
  const _TakeMedicationPanel({
    required this.medication,
    required this.dosageController,
    required this.noteController,
    required this.selectedDateTime,
    required this.onPickDate,
    required this.onPickTime,
    required this.onSkip,
    required this.onTake,
    required this.onCollapse,
    required this.formatDate,
    required this.formatTime,
  });

  final DemoMedication medication;
  final TextEditingController dosageController;
  final TextEditingController noteController;
  final DateTime selectedDateTime;
  final Future<void> Function() onPickDate;
  final Future<void> Function() onPickTime;
  final Future<void> Function() onSkip;
  final Future<void> Function() onTake;
  final VoidCallback onCollapse;
  final String Function(DateTime value) formatDate;
  final String Function(DateTime value) formatTime;

  @override
  Widget build(BuildContext context) {
    final helperText = medication.instructions?.trim().isNotEmpty == true
        ? medication.instructions!.trim()
        : 'Take ${_doseSummaryFor(medication).toLowerCase()}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Take Medication',
            style: GoogleFonts.nunitoSans(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1C3444),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Center(
          child: Text(
            '(All fields marked with * are mandatory)',
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFC2778A),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Dosage *',
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243B4B),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 170,
          child: TextField(
            controller: dosageController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD3DEE8)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Color(0xFFD3DEE8)),
              ),
            ),
            style: GoogleFonts.nunitoSans(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF263F50),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '($helperText)',
          style: GoogleFonts.nunitoSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6A7E8C),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFD3DEE8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Route of Administration',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF253E4D),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                medication.route?.trim().isNotEmpty == true
                    ? medication.route!.trim()
                    : 'Oral',
                style: GoogleFonts.nunitoSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2D4B5D),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Date and Time',
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF243B4B),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFD3DEE8)),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onPickDate,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 16,
                          color: Color(0xFF556C7A),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatDate(selectedDateTime),
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C4656),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(width: 1, height: 24, color: const Color(0xFFDCE6EE)),
              Expanded(
                child: InkWell(
                  onTap: onPickTime,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 11,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 17,
                          color: Color(0xFF556C7A),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          formatTime(selectedDateTime),
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2C4656),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: onPickTime,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Color(0xFF566D7C),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Note *',
              style: GoogleFonts.nunitoSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF243B4B),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: onCollapse,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBACAD6)),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF5B7383),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: noteController,
          minLines: 2,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add note',
            hintStyle: GoogleFonts.nunitoSans(
              color: const Color(0xFF92A4B1),
              fontWeight: FontWeight.w700,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD3DEE8)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD3DEE8)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  onSkip();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFFA8BBC9)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Skip',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF395260),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC4A7E9), Color(0xFFB58CE6)],
                  ),
                ),
                child: FilledButton(
                  onPressed: () {
                    onTake();
                  },
                  style: FilledButton.styleFrom(
                    shadowColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Take',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PillLabel extends StatelessWidget {
  const _PillLabel({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w800,
          color: textColor,
          fontSize: 12,
        ),
      ),
    );
  }
}
