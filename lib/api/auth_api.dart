import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

Future<String?> getAccessToken({
  required String instanceBaseUrl,
  required String clientId,
  required String clientSecret,
  required String code,
}) async {
  final url = Uri.parse(instanceBaseUrl).resolve("/oauth/token");

  String redirectUri = dotenv.get("REDIRECT_URI");

  final response = await http.post(
    url,
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
    debugPrint(data);
    return data['access_token'];
  } else {
    print("Gagal exchange token: ${response.body}");
    return null;
  }
}
