class BootstrapResponse {
  BootstrapResponse({
    required this.residents,
    required this.medicationOrders,
    required this.marEntries,
    required this.administrations,
    required this.cursor,
  });

  final List<Map<String, dynamic>> residents;
  final List<Map<String, dynamic>> medicationOrders;
  final List<Map<String, dynamic>> marEntries;
  final List<Map<String, dynamic>> administrations;
  final int cursor;

  static BootstrapResponse fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> asList(String key) {
      final raw = json[key] as List? ?? [];
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    return BootstrapResponse(
      residents: asList('residents'),
      medicationOrders: asList('medication_orders'),
      marEntries: asList('mar_entries'),
      administrations: asList('administrations'),
      cursor: json['cursor'] as int,
    );
  }
}
