import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String?> getAccessToken({
  required String instanceBaseUrl,
  required String clientId,
  required String clientSecret,
  required String code,
}) async {
  try {
    final url = Uri.parse(instanceBaseUrl).resolve("/oauth/token");

    String redirectUri = dotenv.get("REDIRECT_URI");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
        'code': code,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    } else {
      print("Gagal exchange token: ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error saat exchange code: $e");
    throw e;
  }
}

Future<String?> refreshAccessToken({
  required String baseUrl,
  required String clientId,
  required String clientSecret,
  required String refreshToken,
}) async {
  final res = await http.post(
    Uri.parse("$baseUrl/oauth/token"),
    headers: {"Content-Type": "application/x-www-form-urlencoded"},
    body: {
      "client_id": clientId,
      "client_secret": clientSecret,
      "grant_type": "refresh_token",
      "refresh_token": refreshToken,
    },
  );

  if (res.statusCode == 200) {
    final json = jsonDecode(res.body);
    return json["access_token"];
  } else {
    print("Refresh gagal: ${res.body}");
    return null;
  }
}
