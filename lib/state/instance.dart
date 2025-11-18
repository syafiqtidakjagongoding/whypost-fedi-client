import 'package:flutter_riverpod/legacy.dart';


/// Model sederhana untuk menyimpan data instance
class Instance {
  final dynamic instanceData;     // data instance (misal info dari API)
  final String redirectUrl;

  const Instance({
    required this.instanceData,
   required this.redirectUrl
  });

  /// Copy with — mempertahankan nilai lama kalau tidak diubah
  Instance copyWith({
    dynamic instanceData,
    String? clientId,
    String? clientSecret,
    String? redirectUrl,
  }) {
    return Instance(
      instanceData: instanceData ?? this.instanceData,
      redirectUrl: redirectUrl ?? this.redirectUrl,
    );
  }
}

class InstanceNotifier extends StateNotifier<Instance?> {
  InstanceNotifier() : super(null);

  /// 1️⃣ Set instance awal dari instanceData
  void setInstanceFromData(dynamic instanceData, String redirectUrl) {
    state = Instance(
      redirectUrl: redirectUrl,
      instanceData: instanceData,
    );
  }

  /// 4️⃣ Hapus instance total
  void clear() {
    state = null;
  }
}


/// Provider utama untuk mengakses instance di seluruh app
final instanceProvider = StateNotifierProvider<InstanceNotifier, Instance?>((
  ref
) {
  return InstanceNotifier();
});
