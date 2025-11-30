import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> searchAny(
  String baseUrl,
  String accessToken,
  String query,
) async {
  final uri = Uri.parse(
    "$baseUrl/api/v2/search",
  ).replace(queryParameters: {"q": query, "limit": "10", "resolve": 'true'});

  final res = await http.get(
    uri,
    headers: {
      "Authorization": "Bearer $accessToken",
      "Accept": "application/json",
    },
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to search: ${res.body}");
  }
  return jsonDecode(res.body);
}


Future<Map<String, dynamic>?> searchOneAccount(
  String baseUrl,
  String accessToken,
  String query,
) async {
  final uri = Uri.parse("$baseUrl/api/v2/search").replace(
    queryParameters: {
      "q": query,
      "limit": "1",
      "resolve": "true",
      "type": "accounts",
    },
  );

  final res = await http.get(
    uri,
    headers: {
      "Authorization": "Bearer $accessToken",
      "Accept": "application/json",
    },
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to search: ${res.body}");
  }

  final data = jsonDecode(res.body);

  if (data["accounts"] is List && data["accounts"].isNotEmpty) {
    // return akun pertama
    return data["accounts"][0];
  }

  return null; // tidak ditemukan
}

Future<List<dynamic>> fetchTrendingTags(String baseUrl, String token) async {
  final uri = Uri.parse("$baseUrl/api/v1/trends/tags");

  final res = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load trending tags: ${res.body}");
  }

  return jsonDecode(res.body);
}

Future<List<dynamic>> fetchTrendingLinks(String baseUrl, String token) async {
  final uri = Uri.parse("$baseUrl/api/v1/trends/links");

  final res = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load trending links: ${res.body}");
  }
  return jsonDecode(res.body);
}

Future<List<dynamic>> fetchSuggestedPeople(String baseUrl, String token) async {
  final uri = Uri.parse("$baseUrl/api/v1/suggestions");

  final res = await http.get(
    uri,
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load suggested people: ${res.body}");
  }

  return jsonDecode(res.body);
}

