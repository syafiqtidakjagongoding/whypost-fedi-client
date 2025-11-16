import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model sederhana untuk menyimpan data instance
class Instance {
  final dynamic instanceData;     // data instance (misal info dari API)
  final String clientId;
  final String clientSecret;
  final String redirectUrl;

  const Instance({
    required this.instanceData,
    required this.clientId,
    required this.clientSecret,
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
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
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
      clientId: "",
      clientSecret: "",
    );
  }

  /// 2️⃣ Update credentials clientId dan clientSecret
  void updateCredentials(String clientId, String clientSecret) {
    if (state == null) return;

    state = state!.copyWith(
      clientId: clientId,
      clientSecret: clientSecret,
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
