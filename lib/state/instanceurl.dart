import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InstanceRepository {
  static const _keyToken = "instance_url";

  /// simpan access token
  Future<void> saveToken(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, url);
  }

  /// ambil access token
  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    return token;
  }

  /// hapus access token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }

  /// clear semua auth
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }
}

final instanceRepoProvider = Provider((ref) => InstanceRepository());

/// provider hanya untuk token
final instanceUrlProvider = FutureProvider<String?>((ref) async {

  return ref.read(instanceRepoProvider).loadToken();
});
