import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'emar_screen.dart';

class SiteSelectionScreen extends StatefulWidget {
  const SiteSelectionScreen({super.key});

  @override
  State<SiteSelectionScreen> createState() => _SiteSelectionScreenState();
}

class _SiteSelectionScreenState extends State<SiteSelectionScreen> {
  static const _sites = <String>['Mobay', 'Goldthorn Home'];

  String? _selectedSite;

  void _continueToMar() {
    if (_selectedSite == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => EmarScreen(siteFilter: _selectedSite)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 440;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF2F7F4), Color(0xFFE9F1EE), Color(0xFFDCE7E0)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              const _BackdropShapes(),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Container(
                      padding: EdgeInsets.all(isNarrow ? 18 : 24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCFFFD),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: const Color(0xFFD8E6DE)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A1E2B24),
                            blurRadius: 28,
                            offset: Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Your Site',
                            style: GoogleFonts.nunitoSans(
                              fontSize: isNarrow ? 28 : 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                              color: const Color(0xFF1D3A2F),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pick the location you are working from to continue to eMAR.',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14,
                              color: const Color(0xFF49665A),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const _DeviceStatusRow(),
                          const SizedBox(height: 22),
                          Text(
                            'Site',
                            style: GoogleFonts.nunitoSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2D4A3E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedSite,
                            items: _sites
                                .map(
                                  (site) => DropdownMenuItem(
                                    value: site,
                                    child: Text(
                                      site,
                                      style: GoogleFonts.nunitoSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedSite = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Choose a site',
                              hintStyle: GoogleFonts.nunitoSans(
                                color: const Color(0xFF6C857B),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF3F8F4),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFFCBDBD2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2E6D55),
                                  width: 1.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _selectedSite == null
                                  ? null
                                  : _continueToMar,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF2E6D55),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(
                                  0xFFB2C2BA,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: Text(
                                'Continue',
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeviceStatusRow extends StatelessWidget {
  const _DeviceStatusRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: const [
        _StatusChip(
          icon: Icons.wifi_rounded,
          label: 'Network',
          value: 'Online',
          color: Color(0xFF177D52),
        ),
        _StatusChip(
          icon: Icons.battery_5_bar_rounded,
          label: 'Battery',
          value: '66%',
          color: Color(0xFF1C4A7D),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD6E4DC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            '$label ',
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF365447),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunitoSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackdropShapes extends StatelessWidget {
  const _BackdropShapes();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -70,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x332E6D55),
              ),
            ),
          ),
          Positioned(
            left: -50,
            bottom: -70,
            child: Container(
              width: 180,
              height: 180,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x1F1C4A7D),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
