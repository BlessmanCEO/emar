// ignore_for_file: invalid_use_of_internal_member

import 'frb_generated.dart';

class RustCoreBridge {
  RustCoreBridge._();

  static final RustCoreBridge instance = RustCoreBridge._();

  Future<void> init() async {
    await RustLib.init();
  }

  Future<String> normalizeMedicationName(String raw) {
    return RustLib.instance.api.crateApiNormalizeMedicationName(raw: raw);
  }
}
