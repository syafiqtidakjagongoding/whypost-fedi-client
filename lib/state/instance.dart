import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Model sederhana untuk menyimpan data instance
class Instance {
  final String url;
  final bool isApproval;
  final String clientId;
  final String clientSecret;
  final String redirectUrl;

  const Instance({
    required this.url,
    this.isApproval = false,
    required this.clientId,
    required this.clientSecret,
    this.redirectUrl = "myapp://callback"
  });

  /// Copy dengan perubahan tertentu (pattern immutable)
  Instance copyWith({
    String? url,
    bool? isApproval,
    String? clientId,
    String? clientSecret,
  }) {
    return Instance(
      url: url ?? this.url,
      isApproval: isApproval ?? this.isApproval,
      clientId: clientId ?? this.clientId,
      clientSecret: clientSecret ?? this.clientSecret,
    );
  }
}

/// StateNotifier untuk mengatur state instance
class InstanceNotifier extends StateNotifier<Instance?> {
  InstanceNotifier() : super(null);

  /// Set / update URL instance
  void setInstance(String url, bool isApproval, String cId, String cSecret) {
    state = Instance(
      url: url,
      isApproval: isApproval,
      clientId: cId,
      clientSecret: cSecret,
    );
  }

  /// Hapus data instance (misalnya saat logout)
  void clear() {
    state = null;
  }

  /// Getter cepat untuk ambil URL
  String? get currentUrl => state?.url;
}

/// Provider utama untuk mengakses instance di seluruh app
final instanceProvider = StateNotifierProvider<InstanceNotifier, Instance?>((
  ref,
) {
  return InstanceNotifier();
});
