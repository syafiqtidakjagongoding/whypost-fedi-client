import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AllCredentials {
  final String? accToken;
  final String? instanceUrl;
  final String? clientId;
  final String? clientSecret;

  const AllCredentials({
    required this.accToken,
    required this.instanceUrl,
    required this.clientId,
    required this.clientSecret,
  });
}

class Credentials {
  final String? accToken;
  final String? instanceUrl;

  const Credentials({required this.accToken, required this.instanceUrl});
}

class CredentialsRepository {
  static const _keyToken = "access_token";
  static const _instanceurl = "instance_url";
  static const _clientId = "client_id";
  static const _clientSecret = "client_secret";

  /// simpan access token
  static Future<void> saveCredentials(
    String? token,
    String url,
    String clientId,
    String clientSecret,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(_keyToken, token);
    }
    await prefs.setString(_instanceurl, url);
    await prefs.setString(_clientId, clientId);
    await prefs.setString(_clientSecret, clientSecret);
  }

  /// ambil access token
  static Future<AllCredentials> loadAllCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final instanceUrl = prefs.getString(_instanceurl);
    final clientId = prefs.getString(_clientId);
    final clientSecret = prefs.getString(_clientSecret);

    return AllCredentials(
      accToken: token,
      instanceUrl: instanceUrl,
      clientId: clientId,
      clientSecret: clientSecret,
    );
  }

  static Future<Credentials> loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    final instanceUrl = prefs.getString(_instanceurl);

    return Credentials(accToken: token, instanceUrl: instanceUrl);
  }

  /// clear semua auth
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final instanceUrl = prefs.getString(_instanceurl);
    final clientId = prefs.getString(_clientId);
    final clientSecret = prefs.getString(_clientSecret);
    final token = prefs.getString(_keyToken);

    await http.post(
      Uri.parse('$instanceUrl/oauth/revoke'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'client_id': clientId,
        'client_secret': clientSecret,
      }),
    );

    await prefs.remove(_keyToken);
    await prefs.remove(_instanceurl);
    await prefs.remove(_clientId);
    await prefs.remove(_clientSecret);
    await prefs.clear();
  }
}
