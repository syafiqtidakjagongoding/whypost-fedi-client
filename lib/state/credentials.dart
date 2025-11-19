import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Credentials {
  final String? accToken;
  final String? instanceUrl;
  final String? clientId;
  final String? clientSecret;

  const Credentials({
    required this.accToken,
    required this.instanceUrl,
    required this.clientId,
    required this.clientSecret,
  });
}

class CredentialsRepository {
  static const _keyToken = "access_token";
  static const _instanceurl = "instance_url";
  static const _clientId = "client_id";
  static const _clientSecret = "client_secret";

  /// simpan access token
  Future<void> saveCredentials(
    String token,
    String url,
    String clientId,
    String clientSecret,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_instanceurl);
    await prefs.remove(_clientId);
    await prefs.remove(_clientSecret);
    await prefs.setString(_keyToken, token);
    await prefs.setString(_instanceurl, url);
    await prefs.setString(_clientId, clientId);
    await prefs.setString(_clientSecret, clientSecret);
  }

  /// ambil access token
  Future<Credentials> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final instanceUrl = prefs.getString(_instanceurl);
    final clientId = prefs.getString(_clientId);
    final clientSecret = prefs.getString(_clientSecret);
    debugPrint("instanceurl + $instanceUrl");
    return Credentials(
      accToken: token,
      instanceUrl: instanceUrl,
      clientId: clientId,
      clientSecret: clientSecret,
    );
  }

  /// clear semua auth
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final instanceUrl = prefs.getString(_instanceurl);
    final clientId = prefs.getString(_clientId);
    final clientSecret = prefs.getString(_clientSecret);
    final token = prefs.getString(_keyToken);

    if (instanceUrl != null &&
        token != null &&
        clientId != null &&
        clientSecret != null) {
      await http.post(
        Uri.parse('$instanceUrl/oauth/revoke'),
        body: {
          'token': token,
          'client_id': clientId,
          'client_secret': clientSecret,
        },
      );
    }

    await prefs.remove(_keyToken);
    await prefs.remove(_instanceurl);
    await prefs.remove(_clientId);
    await prefs.remove(_clientSecret);
    await prefs.clear();
  }
}

final credentialRepoProvider = Provider((ref) => CredentialsRepository());

/// provider hanya untuk token
final credentialProvider = FutureProvider<Credentials>((ref) async {
  return ref.read(credentialRepoProvider).loadCredentials();
});
