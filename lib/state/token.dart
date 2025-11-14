import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenRepository {
  static const _key = "access_token";

  // simpan token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  // ambil token
  Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  // hapus token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
final tokenRepoProvider = Provider<TokenRepository>((ref) {
  return TokenRepository();
});


class TokenState extends StateNotifier<String?> {
  final TokenRepository repo;

  TokenState(this.repo) : super(null) {
    _load();
  }

  Future<void> _load() async {
    state = await repo.loadToken();
  }

  Future<void> setToken(String token) async {
    state = token;
    await repo.saveToken(token);
  }

  Future<void> clear() async {
    state = null;
    await repo.clearToken();
  }
}

final tokenProvider = StateNotifierProvider<TokenState, String?>((ref) {
  final repo = ref.read(tokenRepoProvider);
  return TokenState(repo);
});
