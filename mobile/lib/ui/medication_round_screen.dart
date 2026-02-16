import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../db/app_database.dart';
import '../sync/api_client.dart';

enum RoundActionStatus { taken, refused, withheld }

enum ResidentMedicationTab { scheduled, prn }

class RoundExecutionResult {
  const RoundExecutionResult({
    required this.totalDue,
    required this.completed,
    required this.pending,
    required this.taken,
    required this.refused,
    required this.withheld,
    required this.prnFollowUpsScheduled,
    required this.roundComplete,
    required this.autoAdvance,
  });

  final int totalDue;
  final int completed;
  final int pending;
  final int taken;
  final int refused;
  final int withheld;
  final int prnFollowUpsScheduled;
  final bool roundComplete;
  final bool autoAdvance;
}

class RoundActorIdentity {
  const RoundActorIdentity({
    required this.orgId,
    required this.actorUserId,
    required this.deviceId,
    this.staffName,
    this.siteId,
  });

  final String orgId;
  final String actorUserId;
  final String deviceId;
  final String? staffName;
  final String? siteId;
}

class MedicationRoundInitialAction {
  const MedicationRoundInitialAction({
    required this.status,
    required this.timestamp,
    this.reason,
    this.note,
  });

  final RoundActionStatus status;
  final DateTime timestamp;
  final String? reason;
  final String? note;
}

class MedicationRoundScreen extends StatefulWidget {
  const MedicationRoundScreen({
    super.key,
    required this.residentId,
    required this.residentName,
    required this.siteName,
    required this.dateOfBirth,
    required this.allergies,
    required this.medications,
    required this.roundLabel,
    required this.roundWindow,
    required this.roundIndex,
    required this.db,
    required this.actorIdentity,
    required this.roundKey,
    this.prnOnlyMode = false,
    this.showAllMedications = false,
    this.autoAdvanceOnComplete = true,
    this.initialActions = const {},
  });

  final String residentId;
  final String residentName;
  final String siteName;
  final String? dateOfBirth;
  final String? allergies;
  final List<DemoMedication> medications;
  final String roundLabel;
  final String roundWindow;
  final int roundIndex;
  final AppDatabase db;
  final RoundActorIdentity actorIdentity;
  final String roundKey;
  final bool prnOnlyMode;
  final bool showAllMedications;
  final bool autoAdvanceOnComplete;
  final Map<String, MedicationRoundInitialAction> initialActions;

  @override
  State<MedicationRoundScreen> createState() => _MedicationRoundScreenState();
}

class _MedicationRoundScreenState extends State<MedicationRoundScreen> {
  static const _roundLabels = ['Morning', 'Noon', 'Evening', 'Night'];

  final Map<String, _MedicationResult> _results = {};
  final Map<String, DateTime> _prnFollowUpDue = {};
  final Set<String> _selectedMedicationIds = {};
  final Map<String, String> _doseInputByOrder = {};
  final Map<String, String> _noteInputByOrder = {};
  final Map<String, TimeOfDay> _timeInputByOrder = {};
  final Map<String, String> _stockCountByOrder = {};
  final ScrollController _listController = ScrollController();
  Timer? _nextFocusTimer;
  bool _bulkSelectionEnabled = false;
  bool _autoAdvanceTriggered = false;
  String? _nextBestOrderId;
  String? _expandedMedicationId;
  ResidentMedicationTab _residentTab = ResidentMedicationTab.scheduled;

  @override
  void initState() {
    super.initState();
    _hydrateInitialActions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _jumpToNextBestMedication();
    });
  }

  @override
  void dispose() {
    _nextFocusTimer?.cancel();
    _listController.dispose();
    super.dispose();
  }

  void _hydrateInitialActions() {
    if (widget.initialActions.isEmpty) return;

    for (final entry in widget.initialActions.entries) {
      final action = entry.value;
      _results[entry.key] = _MedicationResult(
        status: action.status,
        timestamp: action.timestamp,
        note: action.note,
        reason: action.reason,
      );

      DemoMedication? medication;
      for (final med in widget.medications) {
        if (med.orderId == entry.key) {
          medication = med;
          break;
        }
      }
      if (medication != null &&
          medication.prn &&
          action.status == RoundActionStatus.taken) {
        _prnFollowUpDue[entry.key] = action.timestamp.add(
          const Duration(minutes: 45),
        );
      }
    }
  }

  void _jumpToNextBestMedication() {
    DemoMedication? next;
    for (final medication in _sortedMedications) {
      if (!_results.containsKey(medication.orderId)) {
        next = medication;
        break;
      }
    }

    if (next == null) {
      setState(() {
        _nextBestOrderId = null;
      });
      return;
    }
    final target = next;

    final targetIndex = _sortedMedications.indexWhere(
      (med) => med.orderId == target.orderId,
    );
    if (targetIndex < 0) return;

    if (mounted) {
      setState(() {
        _nextBestOrderId = target.orderId;
      });
    }

    _nextFocusTimer?.cancel();
    _nextFocusTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        if (_nextBestOrderId == target.orderId) {
          _nextBestOrderId = null;
        }
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_listController.hasClients) return;
      final offset = (targetIndex * 96.0).clamp(
        0.0,
        _listController.position.maxScrollExtent,
      );
      _listController.animateTo(
        offset,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _persistRoundAction(
    DemoMedication medication,
    _MedicationResult result,
  ) async {
    final status = switch (result.status) {
      RoundActionStatus.taken => 'given',
      RoundActionStatus.refused => 'refused',
      RoundActionStatus.withheld => 'withheld',
    };

    String? reasonCode;
    if ((result.reason ?? '').trim().isNotEmpty) {
      reasonCode = result.reason!
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'_+'), '_')
          .replaceAll(RegExp(r'^_|_$'), '');
      if (reasonCode.isEmpty) {
        reasonCode = null;
      }
    }

    await widget.db.recordRoundAction(
      orgId: widget.actorIdentity.orgId,
      actorUserId: widget.actorIdentity.actorUserId,
      deviceId: widget.actorIdentity.deviceId,
      residentId: widget.residentId,
      orderId: medication.orderId,
      roundKey: widget.roundKey,
      status: status,
      reasonCode: reasonCode,
      notes: result.note,
      occurredAt: result.timestamp,
      siteId: widget.actorIdentity.siteId,
    );
  }

  String get _staffName {
    final fromIdentity = widget.actorIdentity.staffName?.trim();
    if (fromIdentity != null && fromIdentity.isNotEmpty) {
      return fromIdentity;
    }
    return widget.actorIdentity.actorUserId;
  }

  String _autoTakenNoteForSingle(DemoMedication medication) {
    return 'Staff $_staffName administered ${medication.medicationName}.';
  }

  String _autoTakenNoteForMany(List<DemoMedication> medications) {
    final names = medications.map((med) => med.medicationName).toList();
    if (names.isEmpty) return '';
    return 'Staff $_staffName administered ${names.join(', ')}.';
  }

  List<DemoMedication> _pendingSelectableMedications() {
    return _sortedMedications
        .where((medication) => !_results.containsKey(medication.orderId))
        .toList();
  }

  void _selectAllPending() {
    final pending = _pendingSelectableMedications();
    setState(() {
      _selectedMedicationIds
        ..clear()
        ..addAll(pending.map((medication) => medication.orderId));
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedMedicationIds.clear();
    });
  }

  RoundExecutionResult _buildResult({required bool autoAdvance}) {
    final due = _dueMedications;
    final completed = due.where((med) => _results.containsKey(med.orderId));
    var taken = 0;
    var refused = 0;
    var withheld = 0;
    for (final med in completed) {
      final result = _results[med.orderId];
      if (result == null) continue;
      switch (result.status) {
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
    return RoundExecutionResult(
      totalDue: due.length,
      completed: completed.length,
      pending: due.length - completed.length,
      taken: taken,
      refused: refused,
      withheld: withheld,
      prnFollowUpsScheduled: _prnFollowUpDue.length,
      roundComplete: due.isNotEmpty && completed.length == due.length,
      autoAdvance: autoAdvance,
    );
  }

  List<DemoMedication> get _visibleMedications {
    return widget.medications.where((med) {
      if (widget.prnOnlyMode) {
        return med.prn;
      }

      if (_residentTab == ResidentMedicationTab.prn) {
        return med.prn;
      }

      if (widget.showAllMedications) {
        return !med.prn;
      }

      return !med.prn &&
          _roundIndicesForMedication(med).contains(widget.roundIndex);
    }).toList();
  }

  List<DemoMedication> get _allScheduledMedications {
    return widget.medications.where((med) => !med.prn).toList();
  }

  List<DemoMedication> get _allPrnMedications {
    return widget.medications.where((med) => med.prn).toList();
  }

  int get _scheduledTabCount {
    if (widget.showAllMedications) {
      return _allScheduledMedications.length;
    }
    if (widget.prnOnlyMode) {
      return 0;
    }
    return _allScheduledMedications
        .where(
          (med) => _roundIndicesForMedication(med).contains(widget.roundIndex),
        )
        .length;
  }

  List<DemoMedication> get _dueMedications {
    if (!widget.showAllMedications && !widget.prnOnlyMode) {
      return _allScheduledMedications
          .where(
            (med) =>
                _roundIndicesForMedication(med).contains(widget.roundIndex),
          )
          .toList();
    }
    if (widget.showAllMedications) {
      return _allScheduledMedications;
    }
    if (widget.prnOnlyMode) {
      return _visibleMedications;
    }
    return _visibleMedications.where((med) => !med.prn).toList();
  }

  List<DemoMedication> get _sortedMedications {
    final meds = [..._visibleMedications];
    meds.sort((a, b) {
      final aPriority = _priorityScore(a);
      final bPriority = _priorityScore(b);
      if (aPriority != bPriority) {
        return aPriority.compareTo(bPriority);
      }
      return a.medicationName.toLowerCase().compareTo(
        b.medicationName.toLowerCase(),
      );
    });
    return meds;
  }

  int _priorityScore(DemoMedication medication) {
    if (_results.containsKey(medication.orderId)) return 4;
    if (_isOverdue(medication)) return 0;
    if (_isHighRisk(medication)) return 1;
    if (medication.prn) return 3;
    return 2;
  }

  bool _isHighRisk(DemoMedication medication) {
    if (medication.isControlledDrug) return true;
    final name = medication.medicationName.toLowerCase();
    return name.contains('warfarin') ||
        name.contains('insulin') ||
        name.contains('morphine');
  }

  bool _isOverdue(DemoMedication medication) {
    if (medication.prn) return false;
    if (_results.containsKey(medication.orderId)) return false;
    if (widget.showAllMedications || widget.prnOnlyMode) return false;
    final earliest = _earliestRoundIndex(medication);
    if (earliest == null) return false;
    return earliest < widget.roundIndex &&
        !_roundIndicesForMedication(medication).contains(widget.roundIndex);
  }

  bool _isOutsideCurrentWindow(DemoMedication medication) {
    if (medication.prn) return false;
    if (widget.showAllMedications || widget.prnOnlyMode) return false;
    return !_roundIndicesForMedication(medication).contains(widget.roundIndex);
  }

  bool _requiresExceptionForTaken(DemoMedication medication) {
    if (medication.prn) return true;
    if (medication.isControlledDrug) return true;
    if (_isOutsideCurrentWindow(medication)) return true;
    return false;
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
      final idx = _roundLabels.indexOf(slot);
      if (idx != -1) output.add(idx);
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

  Future<void> _handleTapMedication(DemoMedication medication) async {
    if (_bulkSelectionEnabled) {
      _toggleMedicationSelection(medication.orderId);
      return;
    }

    if (_results.containsKey(medication.orderId)) {
      return;
    }

    setState(() {
      if (_expandedMedicationId == medication.orderId) {
        _expandedMedicationId = null;
      } else {
        _expandedMedicationId = medication.orderId;
        _doseInputByOrder.putIfAbsent(
          medication.orderId,
          () => _doseSummaryFor(medication),
        );
        _noteInputByOrder.putIfAbsent(medication.orderId, () => '');
        _timeInputByOrder.putIfAbsent(medication.orderId, TimeOfDay.now);
      }
    });
  }

  Future<void> _confirmFromExpanded(
    DemoMedication medication,
    RoundActionStatus action,
  ) async {
    if (_results.containsKey(medication.orderId)) {
      return;
    }

    final doseInput = (_doseInputByOrder[medication.orderId] ?? '').trim();
    final noteInput = (_noteInputByOrder[medication.orderId] ?? '').trim();
    final selectedTime =
        _timeInputByOrder[medication.orderId] ?? TimeOfDay.now();
    final occurredAt = _dateTimeForTimeOfDay(selectedTime);

    if (action == RoundActionStatus.taken) {
      if (medication.prn && noteInput.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PRN administration requires a note/reason.'),
          ),
        );
        return;
      }

      final composed = _composeTakenNote(
        medication,
        doseInput: doseInput,
        extraNote: noteInput,
      );

      if (_requiresExceptionForTaken(medication)) {
        final decision = await _showExceptionSheet(
          medications: [medication],
          initialAction: _ExceptionAction.taken,
          initialNote: medication.prn ? noteInput : composed,
          requireTakenNote: medication.prn,
        );
        if (decision == null || !mounted) return;
        _applyDecision(
          [medication],
          decision,
          showUndo: false,
          occurredAt: occurredAt,
        );
      } else {
        _recordResult(
          medication,
          status: RoundActionStatus.taken,
          note: composed,
          reason: null,
          occurredAt: occurredAt,
        );
      }
    } else {
      _recordResult(
        medication,
        status: action,
        note: noteInput.isEmpty ? null : noteInput,
        reason: null,
        occurredAt: occurredAt,
      );
    }

    if (!mounted) return;
    setState(() {
      _expandedMedicationId = null;
      _selectedMedicationIds.remove(medication.orderId);
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${medication.medicationName} updated.')),
      );

    _jumpToNextBestMedication();
    _maybeAutoAdvance();
  }

  String _composeTakenNote(
    DemoMedication medication, {
    required String doseInput,
    required String extraNote,
  }) {
    if (medication.prn) {
      return extraNote;
    }

    final buffer = StringBuffer();
    buffer.write(_autoTakenNoteForSingle(medication));
    if (doseInput.isNotEmpty) {
      buffer.write(' Dose verified: $doseInput.');
    }
    if (extraNote.isNotEmpty) {
      buffer.write(' $extraNote');
    }
    return buffer.toString();
  }

  DateTime _dateTimeForTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, time.hour, time.minute);
  }

  Future<TimeOfDay?> _pickAdministrationTime({TimeOfDay? initialTime}) async {
    final now = TimeOfDay.now();
    return showTimePicker(
      context: context,
      initialTime: initialTime ?? now,
      helpText: 'Set administration time',
    );
  }

  String _formatTimeOfDay(TimeOfDay value) {
    final hh = value.hour.toString().padLeft(2, '0');
    final mm = value.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _openStockCountSheet() async {
    final medications = _sortedMedications;
    if (medications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No medications available for stock count.'),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final draft = Map<String, String>.from(_stockCountByOrder);
        return StatefulBuilder(
          builder: (context, setModalState) {
            var mismatchCount = 0;
            for (final medication in medications) {
              final expected = (_stockCountByOrder[medication.orderId] ?? '')
                  .trim();
              final counted = (draft[medication.orderId] ?? '').trim();
              if (expected.isNotEmpty &&
                  counted.isNotEmpty &&
                  expected != counted) {
                mismatchCount += 1;
              }
            }

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Stock Count',
                        style: GoogleFonts.nunitoSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF163447),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Expected vs counted table for this resident.',
                        style: GoogleFonts.nunitoSans(
                          color: const Color(0xFF5D7683),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF3F8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFCFDFE9)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 6,
                            child: Text(
                              'Medication',
                              style: GoogleFonts.nunitoSans(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF274757),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Expected',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunitoSans(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF274757),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Counted',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunitoSans(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF274757),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: medications.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final med = medications[index];
                          final expected =
                              (_stockCountByOrder[med.orderId] ?? '').trim();
                          final counted = (draft[med.orderId] ?? '').trim();
                          final mismatch =
                              expected.isNotEmpty &&
                              counted.isNotEmpty &&
                              expected != counted;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: mismatch
                                  ? const Color(0xFFFFF4E9)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: mismatch
                                    ? const Color(0xFFE8B77E)
                                    : const Color(0xFFD7E3EB),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 6,
                                  child: Text(
                                    med.medicationName,
                                    style: GoogleFonts.nunitoSans(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF274757),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    expected.isEmpty ? '--' : expected,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.nunitoSans(
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF355563),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextFormField(
                                    initialValue: draft[med.orderId] ?? '',
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: InputDecoration(
                                      hintText: 'Count',
                                      isDense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 10,
                                          ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setModalState(() {
                                        draft[med.orderId] = value;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (mismatchCount > 0)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '$mismatchCount mismatch(es) against expected count.',
                          style: GoogleFonts.nunitoSans(
                            color: const Color(0xFF9A5A1F),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    if (mismatchCount > 0) const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            _stockCountByOrder
                              ..clear()
                              ..addAll(draft);
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Stock count captured for this resident.',
                              ),
                            ),
                          );
                        },
                        child: const Text('Save stock count'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _handleSwipeMedication(
    DemoMedication medication,
    DismissDirection direction,
  ) async {
    if (_results.containsKey(medication.orderId)) {
      return false;
    }

    final initialAction = direction == DismissDirection.startToEnd
        ? _ExceptionAction.taken
        : _ExceptionAction.refused;

    final decision = await _showExceptionSheet(
      medications: [medication],
      initialAction: initialAction,
      initialNote: initialAction == _ExceptionAction.taken
          ? (medication.prn ? null : _autoTakenNoteForSingle(medication))
          : null,
      requireTakenNote:
          initialAction == _ExceptionAction.taken && medication.prn,
    );
    if (decision == null || !mounted) {
      return false;
    }
    _applyDecision([medication], decision, showUndo: false);
    return false;
  }

  void _recordResult(
    DemoMedication medication, {
    required RoundActionStatus status,
    required String? note,
    required String? reason,
    DateTime? occurredAt,
  }) {
    final now = occurredAt ?? DateTime.now();
    setState(() {
      _results[medication.orderId] = _MedicationResult(
        status: status,
        timestamp: now,
        note: note,
        reason: reason,
      );
      if (status == RoundActionStatus.taken && medication.prn) {
        _prnFollowUpDue[medication.orderId] = now.add(
          const Duration(minutes: 45),
        );
      }
      if (status != RoundActionStatus.taken) {
        _prnFollowUpDue.remove(medication.orderId);
      }
      _selectedMedicationIds.remove(medication.orderId);
    });

    final saved = _results[medication.orderId];
    if (saved != null) {
      unawaited(
        _persistRoundAction(medication, saved).catchError((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Saved locally, sync queue write failed.'),
            ),
          );
        }),
      );
    }
  }

  void _applyDecision(
    List<DemoMedication> medications,
    _ExceptionDecision decision, {
    required bool showUndo,
    DateTime? occurredAt,
  }) {
    final extraNote = decision.note?.trim() ?? '';
    if (decision.action == _ExceptionAction.taken &&
        medications.any((med) => med.prn) &&
        extraNote.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PRN administration requires a note/reason.'),
        ),
      );
      return;
    }

    final autoTakenNote = decision.action == _ExceptionAction.taken
        ? _autoTakenNoteForMany(medications.where((med) => !med.prn).toList())
        : null;
    final combinedTakenNote = extraNote.isEmpty
        ? autoTakenNote
        : (autoTakenNote == null || autoTakenNote.isEmpty)
        ? extraNote
        : '$autoTakenNote $extraNote';

    for (final medication in medications) {
      final noteForMedication = decision.action == _ExceptionAction.taken
          ? (medication.prn ? extraNote : combinedTakenNote)
          : decision.note;

      _recordResult(
        medication,
        status: _mapExceptionAction(decision.action),
        note: noteForMedication,
        reason: decision.reason,
        occurredAt: occurredAt,
      );
    }

    if (showUndo && medications.length == 1) {
      final target = medications.first;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text('${_actionLabel(decision.action)} - Undo (5s)'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _results.remove(target.orderId);
                  _prnFollowUpDue.remove(target.orderId);
                });
              },
            ),
          ),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${medications.length} item(s) updated.')),
        );
    }

    _jumpToNextBestMedication();
    _maybeAutoAdvance();
  }

  RoundActionStatus _mapExceptionAction(_ExceptionAction action) {
    switch (action) {
      case _ExceptionAction.taken:
        return RoundActionStatus.taken;
      case _ExceptionAction.refused:
        return RoundActionStatus.refused;
      case _ExceptionAction.withheld:
        return RoundActionStatus.withheld;
    }
  }

  String _actionLabel(_ExceptionAction action) {
    switch (action) {
      case _ExceptionAction.taken:
        return 'Taken';
      case _ExceptionAction.refused:
        return 'Refused';
      case _ExceptionAction.withheld:
        return 'Withheld';
    }
  }

  void _maybeAutoAdvance() {
    if (!widget.autoAdvanceOnComplete) return;
    if (_autoAdvanceTriggered) return;
    final due = _dueMedications;
    if (due.isEmpty) return;
    final done = due.where((med) => _results.containsKey(med.orderId)).length;
    if (done != due.length) return;

    _autoAdvanceTriggered = true;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          duration: Duration(milliseconds: 900),
          content: Text('Resident complete. Opening next resident...'),
        ),
      );
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      Navigator.of(context).pop(_buildResult(autoAdvance: true));
    });
  }

  Future<void> _openMedicationInfo(DemoMedication medication) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final tags = _aiSignals(medication);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medication.medicationName,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF163447),
                  ),
                ),
                const SizedBox(height: 8),
                _infoRow('Dose', _doseSummaryFor(medication)),
                _infoRow(
                  'Route',
                  medication.route?.trim().isNotEmpty == true
                      ? medication.route!.trim()
                      : 'Not specified',
                ),
                _infoRow(
                  'Frequency',
                  medication.frequency?.trim().isNotEmpty == true
                      ? medication.frequency!.trim()
                      : 'Not specified',
                ),
                _infoRow(
                  'Instructions',
                  medication.instructions?.trim().isNotEmpty == true
                      ? medication.instructions!.trim()
                      : 'No additional instruction',
                ),
                const SizedBox(height: 10),
                Text(
                  'MedAI signals',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2B4C5E),
                  ),
                ),
                const SizedBox(height: 6),
                if (tags.isEmpty)
                  Text(
                    'No active clinical flags for this medication.',
                    style: GoogleFonts.nunitoSans(
                      color: const Color(0xFF5C7482),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (tags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags
                        .map(
                          (tag) => _SignalBadge(
                            icon: tag.icon,
                            label: tag.label,
                            tone: tag.tone,
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.nunitoSans(
            fontSize: 14,
            color: const Color(0xFF375666),
            fontWeight: FontWeight.w700,
          ),
          children: [
            TextSpan(
              text: '$title: ',
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E3F52),
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  void _toggleMedicationSelection(String orderId) {
    setState(() {
      if (_selectedMedicationIds.contains(orderId)) {
        _selectedMedicationIds.remove(orderId);
      } else {
        _selectedMedicationIds.add(orderId);
      }
    });
  }

  Future<void> _applyBulkAction(_ExceptionAction action) async {
    final selected = _sortedMedications
        .where((med) => _selectedMedicationIds.contains(med.orderId))
        .where((med) => !_results.containsKey(med.orderId))
        .toList();
    if (selected.isEmpty) {
      return;
    }

    _ExceptionDecision? decision;
    DateTime? bulkOccurredAt;

    if (action == _ExceptionAction.taken) {
      final pickedTime = await _pickAdministrationTime();
      if (pickedTime == null) return;
      bulkOccurredAt = _dateTimeForTimeOfDay(pickedTime);

      final requiresException = selected.any(_requiresExceptionForTaken);
      if (!requiresException) {
        final autoNote = _autoTakenNoteForMany(selected);
        for (final med in selected) {
          _recordResult(
            med,
            status: RoundActionStatus.taken,
            note: autoNote,
            reason: null,
            occurredAt: bulkOccurredAt,
          );
        }
      } else {
        decision = await _showExceptionSheet(
          medications: selected,
          initialAction: _ExceptionAction.taken,
          initialNote: selected.any((med) => med.prn)
              ? null
              : _autoTakenNoteForMany(selected),
          requireTakenNote: selected.any((med) => med.prn),
        );
      }
    } else {
      decision = await _showExceptionSheet(
        medications: selected,
        initialAction: action,
      );
    }

    if (!mounted) return;

    if (decision != null) {
      _applyDecision(
        selected,
        decision,
        showUndo: false,
        occurredAt: bulkOccurredAt,
      );
    }

    if (decision == null && action == _ExceptionAction.taken) {
      setState(() {
        _selectedMedicationIds.clear();
        _bulkSelectionEnabled = false;
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('${selected.length} item(s) marked taken.')),
        );
      _jumpToNextBestMedication();
      _maybeAutoAdvance();
    }

    if (decision != null) {
      setState(() {
        _selectedMedicationIds.clear();
        _bulkSelectionEnabled = false;
      });
    }
  }

  Future<_ExceptionDecision?> _showExceptionSheet({
    required List<DemoMedication> medications,
    required _ExceptionAction initialAction,
    String? initialNote,
    bool requireTakenNote = false,
  }) {
    return showModalBottomSheet<_ExceptionDecision>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        var selectedAction = initialAction;
        final noteController = TextEditingController(text: initialNote ?? '');

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 6,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medications.length == 1
                        ? 'Exception Flow'
                        : 'Bulk Exception Flow (${medications.length})',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF163447),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _actionChip(
                        label: 'Taken',
                        selected: selectedAction == _ExceptionAction.taken,
                        onTap: () {
                          setModalState(() {
                            selectedAction = _ExceptionAction.taken;
                          });
                        },
                      ),
                      _actionChip(
                        label: 'Refused',
                        selected: selectedAction == _ExceptionAction.refused,
                        onTap: () {
                          setModalState(() {
                            selectedAction = _ExceptionAction.refused;
                          });
                        },
                      ),
                      _actionChip(
                        label: 'Withheld',
                        selected: selectedAction == _ExceptionAction.withheld,
                        onTap: () {
                          setModalState(() {
                            selectedAction = _ExceptionAction.withheld;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Optional note',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        if (selectedAction == _ExceptionAction.taken &&
                            requireTakenNote &&
                            noteController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'PRN administration requires a note/reason.',
                              ),
                            ),
                          );
                          return;
                        }

                        Navigator.of(context).pop(
                          _ExceptionDecision(
                            action: selectedAction,
                            reason: null,
                            note: noteController.text.trim().isEmpty
                                ? null
                                : noteController.text.trim(),
                          ),
                        );
                      },
                      child: const Text('Confirm'),
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

  Widget _actionChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: const Color(0xFF1C6CA1),
      labelStyle: GoogleFonts.nunitoSans(
        color: selected ? Colors.white : const Color(0xFF30505F),
        fontWeight: FontWeight.w800,
      ),
      side: BorderSide(
        color: selected ? const Color(0xFF1C6CA1) : const Color(0xFFD2E0E9),
      ),
    );
  }

  List<_AiSignal> _aiSignals(DemoMedication medication) {
    final signals = <_AiSignal>[];
    final result = _results[medication.orderId];
    final followUp = _prnFollowUpDue[medication.orderId];

    if (medication.prn) {
      signals.add(
        const _AiSignal(
          icon: Icons.trending_up_rounded,
          label: 'PRN trend rising',
          tone: _SignalTone.warn,
        ),
      );
    }
    if (followUp != null) {
      final now = DateTime.now();
      final minutes = followUp.difference(now).inMinutes;
      if (minutes <= 0) {
        signals.add(
          const _AiSignal(
            icon: Icons.schedule_rounded,
            label: 'Follow-up due',
            tone: _SignalTone.info,
          ),
        );
      } else {
        signals.add(
          _AiSignal(
            icon: Icons.schedule_rounded,
            label: 'Follow-up in ${minutes}m',
            tone: _SignalTone.info,
          ),
        );
      }
    }
    if (medication.isControlledDrug ||
        result?.status == RoundActionStatus.refused ||
        result?.status == RoundActionStatus.withheld) {
      signals.add(
        const _AiSignal(
          icon: Icons.warning_amber_rounded,
          label: 'Review required',
          tone: _SignalTone.danger,
        ),
      );
    }
    return signals;
  }

  @override
  Widget build(BuildContext context) {
    final due = _dueMedications;
    final done = due.where((med) => _results.containsKey(med.orderId)).length;
    final progress = due.isEmpty ? 1.0 : (done / due.length).clamp(0.0, 1.0);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop(_buildResult(autoAdvance: false));
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F8FB),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: _ResidentHeader(
                  residentName: widget.residentName,
                  siteName: widget.siteName,
                  dateOfBirth: widget.dateOfBirth,
                  allergies: widget.allergies,
                  roundLabel: widget.roundLabel,
                  roundWindow: widget.roundWindow,
                  progress: progress,
                  bulkSelectionEnabled: _bulkSelectionEnabled,
                  selectedCount: _selectedMedicationIds.length,
                  totalSelectable: _pendingSelectableMedications().length,
                  onToggleBulk: () {
                    setState(() {
                      _bulkSelectionEnabled = !_bulkSelectionEnabled;
                      _selectedMedicationIds.clear();
                    });
                  },
                  onStockCount: _openStockCountSheet,
                  onSelectAll: _selectAllPending,
                  onClearSelection: _clearSelection,
                  onBack: () {
                    Navigator.of(context).pop(_buildResult(autoAdvance: false));
                  },
                ),
              ),
              if (!widget.prnOnlyMode)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<ResidentMedicationTab>(
                          segments: [
                            ButtonSegment<ResidentMedicationTab>(
                              value: ResidentMedicationTab.scheduled,
                              label: Text('Scheduled ($_scheduledTabCount)'),
                            ),
                            ButtonSegment<ResidentMedicationTab>(
                              value: ResidentMedicationTab.prn,
                              label: Text('PRN (${_allPrnMedications.length})'),
                            ),
                          ],
                          selected: {_residentTab},
                          onSelectionChanged: (selected) {
                            setState(() {
                              _residentTab = selected.first;
                              _expandedMedicationId = null;
                              _selectedMedicationIds.clear();
                              _bulkSelectionEnabled = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: _sortedMedications.isEmpty
                    ? Center(
                        child: Text(
                          'No medications due for this round.',
                          style: GoogleFonts.nunitoSans(
                            color: const Color(0xFF486371),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: _listController,
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 16),
                        itemCount: _sortedMedications.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final medication = _sortedMedications[index];
                          final result = _results[medication.orderId];
                          final signals = _aiSignals(medication);
                          return Dismissible(
                            key: ValueKey('swipe-${medication.orderId}'),
                            direction: result == null
                                ? DismissDirection.horizontal
                                : DismissDirection.none,
                            confirmDismiss: (direction) =>
                                _handleSwipeMedication(medication, direction),
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE5F6EF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.swipe_right_rounded,
                                color: Color(0xFF236C54),
                              ),
                            ),
                            secondaryBackground: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE7D8),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.swipe_left_rounded,
                                color: Color(0xFF8D4B1D),
                              ),
                            ),
                            child: _MedicationExecutionCard(
                              medication: medication,
                              result: result,
                              selected: _selectedMedicationIds.contains(
                                medication.orderId,
                              ),
                              selectionMode: _bulkSelectionEnabled,
                              overdue: _isOverdue(medication),
                              highRisk: _isHighRisk(medication),
                              expanded:
                                  _expandedMedicationId == medication.orderId &&
                                  result == null,
                              doseInput:
                                  _doseInputByOrder[medication.orderId] ??
                                  _doseSummaryFor(medication),
                              noteInput:
                                  _noteInputByOrder[medication.orderId] ?? '',
                              onDoseChanged: (value) {
                                _doseInputByOrder[medication.orderId] = value;
                              },
                              onNoteChanged: (value) {
                                _noteInputByOrder[medication.orderId] = value;
                              },
                              administrationTimeLabel: _formatTimeOfDay(
                                _timeInputByOrder[medication.orderId] ??
                                    TimeOfDay.now(),
                              ),
                              onPickAdministrationTime: () async {
                                final picked = await _pickAdministrationTime(
                                  initialTime:
                                      _timeInputByOrder[medication.orderId] ??
                                      TimeOfDay.now(),
                                );
                                if (picked == null || !mounted) return;
                                setState(() {
                                  _timeInputByOrder[medication.orderId] =
                                      picked;
                                });
                              },
                              onConfirmTaken: () => _confirmFromExpanded(
                                medication,
                                RoundActionStatus.taken,
                              ),
                              onConfirmRefused: () => _confirmFromExpanded(
                                medication,
                                RoundActionStatus.refused,
                              ),
                              onConfirmWithheld: () => _confirmFromExpanded(
                                medication,
                                RoundActionStatus.withheld,
                              ),
                              nextBest:
                                  _nextBestOrderId == medication.orderId &&
                                  result == null,
                              aiSignals: signals,
                              followUpDue: _prnFollowUpDue[medication.orderId],
                              onTap: () => _handleTapMedication(medication),
                              onLongPress: () =>
                                  _openMedicationInfo(medication),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _selectedMedicationIds.isNotEmpty
            ? _StickyActionBar(
                selectedCount: _selectedMedicationIds.length,
                onTaken: () => _applyBulkAction(_ExceptionAction.taken),
                onRefused: () => _applyBulkAction(_ExceptionAction.refused),
                onWithheld: () => _applyBulkAction(_ExceptionAction.withheld),
              )
            : null,
      ),
    );
  }
}

class _ResidentHeader extends StatelessWidget {
  const _ResidentHeader({
    required this.residentName,
    required this.siteName,
    required this.dateOfBirth,
    required this.allergies,
    required this.roundLabel,
    required this.roundWindow,
    required this.progress,
    required this.bulkSelectionEnabled,
    required this.selectedCount,
    required this.totalSelectable,
    required this.onToggleBulk,
    required this.onStockCount,
    required this.onSelectAll,
    required this.onClearSelection,
    required this.onBack,
  });

  final String residentName;
  final String siteName;
  final String? dateOfBirth;
  final String? allergies;
  final String roundLabel;
  final String roundWindow;
  final double progress;
  final bool bulkSelectionEnabled;
  final int selectedCount;
  final int totalSelectable;
  final VoidCallback onToggleBulk;
  final VoidCallback onStockCount;
  final VoidCallback onSelectAll;
  final VoidCallback onClearSelection;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final hasAllergy = allergies?.trim().isNotEmpty == true;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD5E3EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      residentName,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF163447),
                      ),
                    ),
                    Text(
                      '${dateOfBirth?.trim().isNotEmpty == true ? dateOfBirth!.trim() : 'DOB not recorded'} · $siteName',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF5A7382),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onToggleBulk,
                icon: Icon(
                  bulkSelectionEnabled
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                ),
                label: Text(bulkSelectionEnabled ? 'Selecting' : 'Select'),
              ),
            ],
          ),
          if (bulkSelectionEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                children: [
                  Text(
                    '$selectedCount selected',
                    style: GoogleFonts.nunitoSans(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF3F5D6C),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: totalSelectable == 0 ? null : onSelectAll,
                    child: Text('Select all ($totalSelectable)'),
                  ),
                  TextButton(
                    onPressed: onClearSelection,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
          if (hasAllergy)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEE7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEFA77F)),
              ),
              child: Text(
                'Allergy alert: ${allergies!.trim()}',
                style: GoogleFonts.nunitoSans(
                  color: const Color(0xFF8A3C1A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          if (!hasAllergy)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF7F4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA5D4C2)),
              ),
              child: Text(
                'No known allergies',
                style: GoogleFonts.nunitoSans(
                  color: const Color(0xFF245A43),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              _headerBadge(
                icon: Icons.schedule_rounded,
                label: '$roundLabel Round · $roundWindow',
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onStockCount,
                icon: const Icon(Icons.inventory_2_outlined, size: 16),
                label: const Text('Stock count'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE4EEF4),
              color: const Color(0xFF2F8E71),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerBadge({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3F8),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFCFE0EA)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF315365)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF315365),
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicationExecutionCard extends StatelessWidget {
  const _MedicationExecutionCard({
    required this.medication,
    required this.result,
    required this.selected,
    required this.selectionMode,
    required this.overdue,
    required this.highRisk,
    required this.expanded,
    required this.doseInput,
    required this.noteInput,
    required this.onDoseChanged,
    required this.onNoteChanged,
    required this.administrationTimeLabel,
    required this.onPickAdministrationTime,
    required this.onConfirmTaken,
    required this.onConfirmRefused,
    required this.onConfirmWithheld,
    required this.nextBest,
    required this.aiSignals,
    required this.followUpDue,
    required this.onTap,
    required this.onLongPress,
  });

  final DemoMedication medication;
  final _MedicationResult? result;
  final bool selected;
  final bool selectionMode;
  final bool overdue;
  final bool highRisk;
  final bool expanded;
  final String doseInput;
  final String noteInput;
  final ValueChanged<String> onDoseChanged;
  final ValueChanged<String> onNoteChanged;
  final String administrationTimeLabel;
  final VoidCallback onPickAdministrationTime;
  final VoidCallback onConfirmTaken;
  final VoidCallback onConfirmRefused;
  final VoidCallback onConfirmWithheld;
  final bool nextBest;
  final List<_AiSignal> aiSignals;
  final DateTime? followUpDue;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final state = _statusMeta(result?.status);
    final borderColor = selected
        ? const Color(0xFF1B6DA5)
        : (nextBest ? const Color(0xFF2D7DAE) : state.borderColor);
    final strength = medication.rawStrength?.trim();
    final instructions = medication.instructions?.trim();
    final instructionText = (instructions == null || instructions.isEmpty)
        ? 'Instructions: none provided'
        : 'Instructions: $instructions';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 94),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0B1A2B33),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (selectionMode)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        selected
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: selected
                            ? const Color(0xFF1B6DA5)
                            : const Color(0xFF8AA0AE),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              medication.medicationName,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF173546),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(width: 8),
                            _StatusPill(
                              label: state.label,
                              color: state.pillColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_doseSummaryFor(medication)} · ${medication.route?.trim().isNotEmpty == true ? medication.route!.trim() : 'Route n/a'}',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4E6978),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (strength != null && strength.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Strength: $strength',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF5D7683),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            instructionText,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF5D7683),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            if (medication.prn)
                              const _TinyBadge(
                                label: 'PRN',
                                background: Color(0xFFEFF4FD),
                                foreground: Color(0xFF2E5E8E),
                              ),
                            if (nextBest)
                              const _TinyBadge(
                                label: 'Next',
                                background: Color(0xFFE9F4FF),
                                foreground: Color(0xFF2D7DAE),
                              ),
                            if (medication.isControlledDrug)
                              const _TinyBadge(
                                label: 'Controlled',
                                background: Color(0xFFFFEFE5),
                                foreground: Color(0xFF8D4B1D),
                              ),
                            if (highRisk)
                              const _TinyBadge(
                                label: 'High risk',
                                background: Color(0xFFFFF2DA),
                                foreground: Color(0xFF825600),
                              ),
                            if (overdue)
                              const _TinyBadge(
                                label: 'Overdue',
                                background: Color(0xFFFFE8E8),
                                foreground: Color(0xFF973838),
                              ),
                            if (followUpDue != null)
                              _TinyBadge(
                                label: _followUpLabel(followUpDue!),
                                background: const Color(0xFFE9F4FF),
                                foreground: const Color(0xFF2D5D8E),
                              ),
                          ],
                        ),
                        if (result?.note != null &&
                            result!.note!.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Note: ${result!.note!.trim()}',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF436374),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    aiSignals.any((s) => s.tone == _SignalTone.danger)
                        ? Icons.priority_high_rounded
                        : Icons.more_horiz_rounded,
                    color: aiSignals.any((s) => s.tone == _SignalTone.danger)
                        ? const Color(0xFFB44343)
                        : const Color(0xFF6C8695),
                  ),
                ],
              ),
              if (expanded) ...[
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFD7E3EB)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Administration time: $administrationTimeLabel',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF365563),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onPickAdministrationTime,
                      child: const Text('Set time'),
                    ),
                  ],
                ),
                TextFormField(
                  initialValue: doseInput,
                  onChanged: onDoseChanged,
                  decoration: InputDecoration(
                    labelText: 'Dose to administer',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: noteInput,
                  onChanged: onNoteChanged,
                  minLines: 2,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Optional note (appended to auto note)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Auto note is generated on administer and saved to MAR.',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF5D7683),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: onConfirmTaken,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2F8E71),
                        ),
                        child: const Text('Administer'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onConfirmRefused,
                        child: const Text('Refused'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onConfirmWithheld,
                        child: const Text('Withheld'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  _CardStatusMeta _statusMeta(RoundActionStatus? status) {
    switch (status) {
      case RoundActionStatus.taken:
        return const _CardStatusMeta(
          label: 'Taken',
          borderColor: Color(0xFFB9E0D2),
          pillColor: Color(0xFF2F8E71),
        );
      case RoundActionStatus.refused:
        return const _CardStatusMeta(
          label: 'Refused',
          borderColor: Color(0xFFF0C9B0),
          pillColor: Color(0xFFC2743D),
        );
      case RoundActionStatus.withheld:
        return const _CardStatusMeta(
          label: 'Withheld',
          borderColor: Color(0xFFE7CBD0),
          pillColor: Color(0xFFAA4F62),
        );
      case null:
        return const _CardStatusMeta(
          label: 'Pending',
          borderColor: Color(0xFFD5E3EC),
          pillColor: Color(0xFF4F6D7D),
        );
    }
  }

  String _followUpLabel(DateTime followUpDue) {
    final mins = followUpDue.difference(DateTime.now()).inMinutes;
    if (mins <= 0) return 'Follow-up due';
    return 'Follow-up ${mins}m';
  }
}

class _StickyActionBar extends StatelessWidget {
  const _StickyActionBar({
    required this.selectedCount,
    required this.onTaken,
    required this.onRefused,
    required this.onWithheld,
  });

  final int selectedCount;
  final VoidCallback onTaken;
  final VoidCallback onRefused;
  final VoidCallback onWithheld;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFD3E0E9))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected: $selectedCount meds',
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF234456),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: onTaken,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2F8E71),
                    ),
                    child: const Text('Taken'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onRefused,
                    child: const Text('Refused'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onWithheld,
                    child: const Text('Withheld'),
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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunitoSans(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.nunitoSans(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: foreground,
        ),
      ),
    );
  }
}

class _SignalBadge extends StatelessWidget {
  const _SignalBadge({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final _SignalTone tone;

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;
    switch (tone) {
      case _SignalTone.info:
        background = const Color(0xFFE8F3FF);
        foreground = const Color(0xFF2D5D8E);
        break;
      case _SignalTone.warn:
        background = const Color(0xFFFFF2DA);
        foreground = const Color(0xFF825600);
        break;
      case _SignalTone.danger:
        background = const Color(0xFFFFE8E8);
        foreground = const Color(0xFF973838);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              color: foreground,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardStatusMeta {
  const _CardStatusMeta({
    required this.label,
    required this.borderColor,
    required this.pillColor,
  });

  final String label;
  final Color borderColor;
  final Color pillColor;
}

class _MedicationResult {
  const _MedicationResult({
    required this.status,
    required this.timestamp,
    required this.note,
    required this.reason,
  });

  final RoundActionStatus status;
  final DateTime timestamp;
  final String? note;
  final String? reason;
}

enum _ExceptionAction { taken, refused, withheld }

class _ExceptionDecision {
  const _ExceptionDecision({
    required this.action,
    required this.reason,
    required this.note,
  });

  final _ExceptionAction action;
  final String? reason;
  final String? note;
}

enum _SignalTone { info, warn, danger }

class _AiSignal {
  const _AiSignal({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final _SignalTone tone;
}

String _doseSummaryFor(DemoMedication medication) {
  if (medication.doseText?.trim().isNotEmpty == true) {
    return medication.doseText!.trim();
  }
  final dose = medication.doseValue;
  if (dose == null) return 'Dose not specified';
  final formatted = dose.toStringAsFixed(
    dose.truncateToDouble() == dose ? 0 : 1,
  );
  final unit = medication.doseUnit?.trim() ?? '';
  if (unit.isEmpty) return formatted;
  return '$formatted $unit';
}
