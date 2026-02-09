import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmarScreen extends StatefulWidget {
  const EmarScreen({super.key});

  @override
  State<EmarScreen> createState() => _EmarScreenState();
}

class _EmarScreenState extends State<EmarScreen> {
  final _residents = const [
    ResidentSummary('Ada Lovelace', 'A-102', 'Stable', true),
    ResidentSummary('James Baldwin', 'B-214', 'Needs review', false),
    ResidentSummary('Toni Morrison', 'C-110', 'Stable', false),
    ResidentSummary('Alan Turing', 'A-119', 'Late dose', false),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F2EA), Color(0xFFE6F0F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 860;
              return Stack(
                children: [
                  _DecorLayer(isWide: isWide),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isWide
                        ? _buildWideLayout(theme)
                        : _buildNarrowLayout(theme),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
            width: 320,
            child: _ResidentPanel(
              residents: _residents,
              selectedIndex: _selectedIndex,
              onSelect: (index) => setState(() => _selectedIndex = index),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _MarPanel(
              resident: _residents[_selectedIndex],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _HeaderBar(
          resident: _residents[_selectedIndex],
        ),
        const SizedBox(height: 16),
        _ResidentPanel(
          residents: _residents,
          selectedIndex: _selectedIndex,
          onSelect: (index) => setState(() => _selectedIndex = index),
          dense: true,
        ),
        const SizedBox(height: 16),
        _MarPanel(resident: _residents[_selectedIndex]),
      ],
    );
  }
}

class _DecorLayer extends StatelessWidget {
  const _DecorLayer({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            right: isWide ? 60 : -40,
            top: -60,
            child: Container(
              width: isWide ? 220 : 160,
              height: isWide ? 220 : 160,
              decoration: BoxDecoration(
                color: const Color(0xFFB7D7D9).withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -40,
            bottom: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF1C9A9).withOpacity(0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.resident});

  final ResidentSummary resident;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF1F6B75),
            child: Text(
              resident.name.substring(0, 1),
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resident.name,
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Room ${resident.room}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: const Color(0xFF5F6B6D),
                ),
              ),
            ],
          ),
          const Spacer(),
          _StatusPill(text: resident.status, alert: resident.alert),
        ],
      ),
    );
  }
}

class _ResidentPanel extends StatelessWidget {
  const _ResidentPanel({
    required this.residents,
    required this.selectedIndex,
    required this.onSelect,
    this.dense = false,
  });

  final List<ResidentSummary> residents;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Residents',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search by name or room',
              filled: true,
              fillColor: const Color(0xFFF4F6F7),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _FilterChip('All'),
              _FilterChip('Due now'),
              _FilterChip('Late'),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
            residents.length,
            (index) => _ResidentTile(
              resident: residents[index],
              selected: index == selectedIndex,
              onTap: () => onSelect(index),
              dense: dense,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResidentTile extends StatelessWidget {
  const _ResidentTile({
    required this.resident,
    required this.selected,
    required this.onTap,
    required this.dense,
  });

  final ResidentSummary resident;
  final bool selected;
  final VoidCallback onTap;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF1F6B75) : const Color(0xFFEDF4F5);
    final textColor = selected ? Colors.white : const Color(0xFF2A3D40);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(dense ? 10 : 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: dense ? 16 : 18,
              backgroundColor: selected
                  ? Colors.white.withOpacity(0.2)
                  : const Color(0xFF1F6B75),
              child: Text(
                resident.name.substring(0, 1),
                style: GoogleFonts.dmSans(
                  color: selected ? Colors.white : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    resident.name,
                    style: GoogleFonts.dmSans(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Room ${resident.room}',
                    style: GoogleFonts.dmSans(
                      color: textColor.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _StatusDot(alert: resident.alert),
          ],
        ),
      ),
    );
  }
}

class _MarPanel extends StatelessWidget {
  const _MarPanel({required this.resident});

  final ResidentSummary resident;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8EA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MAR Today',
                    style: GoogleFonts.dmSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${resident.name} • Room ${resident.room}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: const Color(0xFF5F6B6D),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1F6B75),
                ),
                child: const Text('Start Round'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _MedicationCard(
            medication: 'Metformin 500 mg',
            schedule: '08:00, 20:00',
            status: 'Due now',
            statusColor: const Color(0xFFE76F51),
            details: const ['With food', 'Oral'],
          ),
          const SizedBox(height: 14),
          _MedicationCard(
            medication: 'Atorvastatin 20 mg',
            schedule: '21:00',
            status: 'Upcoming',
            statusColor: const Color(0xFF2A9D8F),
            details: const ['Bedtime', 'Oral'],
          ),
          const SizedBox(height: 14),
          _MedicationCard(
            medication: 'Lisinopril 10 mg',
            schedule: '07:30',
            status: 'Given',
            statusColor: const Color(0xFF457B9D),
            details: const ['BP check', 'Oral'],
          ),
        ],
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({
    required this.medication,
    required this.schedule,
    required this.status,
    required this.statusColor,
    required this.details,
  });

  final String medication;
  final String schedule;
  final String status;
  final Color statusColor;
  final List<String> details;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EBEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  medication,
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            schedule,
            style: GoogleFonts.dmSans(
              color: const Color(0xFF5F6B6D),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: details
                .map(
                  (detail) => Chip(
                    label: Text(detail),
                    backgroundColor: Colors.white,
                    shape: StadiumBorder(
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              OutlinedButton(
                onPressed: () {},
                child: const Text('Refused'),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1F6B75),
                ),
                child: const Text('Record Dose'),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
      backgroundColor: const Color(0xFFF3F6F7),
      side: const BorderSide(color: Color(0xFFE1E6E8)),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.alert});

  final bool alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: alert ? const Color(0xFFE76F51) : const Color(0xFF2A9D8F),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.alert});

  final String text;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final color = alert ? const Color(0xFFE76F51) : const Color(0xFF2A9D8F);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class ResidentSummary {
  const ResidentSummary(this.name, this.room, this.status, this.alert);

  final String name;
  final String room;
  final String status;
  final bool alert;
}
