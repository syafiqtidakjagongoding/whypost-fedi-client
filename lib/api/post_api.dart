import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';

Future<List<dynamic>> fetchHomeTimeline(
  String baseUrl,
  String accessToken,
  int limit,
  String? maxId,
  String? sinceId
) async {
  final uri = Uri.parse("$baseUrl/api/v1/timelines/public").replace(
    queryParameters: {
      'limit': limit.toString(), // misal limit = 20
      'max_id': maxId,
      'since_id': sinceId
    },
  );

  final res = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    },
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load home timeline: ${res.body}");
  }


  return jsonDecode(res.body);
}


Future<List<dynamic>> fetchStatusesUserById(
  String baseUrl,
  String accessToken,
  String? maxId,
  String? sinceId,
  String id,
) async {
  final uri = Uri.parse("$baseUrl/api/v1/accounts/$id/statuses").replace(
    queryParameters: {
      'max_id': maxId,
      'since_id': sinceId
    },
  );

  final res = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    },
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load home timeline: ${res.body}");
  }


  return jsonDecode(res.body);
}


Future<List<dynamic>> fetchFavouritedUser(
  String baseUrl,
  String accessToken,
  String? maxId,
  String? sinceId,
) async {
  final uri = Uri.parse("$baseUrl/api/v1/favourites").replace(
    queryParameters: {
      'max_id': maxId,
      'since_id': sinceId
    },
  );

  final res = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    },
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load home timeline: ${res.body}");
  }


  return jsonDecode(res.body);
}


Future<Map<String, dynamic>> favouritePost(
  String baseUrl,
  String accessToken,
  String id,
) async {
  final uri = Uri.parse("$baseUrl/api/v1/statuses/$id/favourite");

  final res = await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to favourite post: ${res.body}");
  }
  return jsonDecode(res.body);
}

Future<Map<String, dynamic>> unfavouritePost(
  String baseUrl,
  String accessToken,
  String id,
) async {
  final uri = Uri.parse("$baseUrl/api/v1/statuses/$id/unfavourite");

  final res = await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to unfavourite post: ${res.body}");
  }
  return jsonDecode(res.body);
}

Future<Map<String, dynamic>> bookmarkPost(
  String baseUrl,
  String accessToken,
  String id,
) async {
  final uri = Uri.parse("$baseUrl/api/v1/statuses/$id/bookmark");

  final res = await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to bookmark post: ${res.body}");
  }
  return jsonDecode(res.body);
}

Future<Map<String, dynamic>> unbookmarkPost(
  String baseUrl,
  String accessToken,
  String id,
) async {
  final uri = Uri.parse("$baseUrl/api/v1/statuses/$id/unbookmark");

  final res = await http.post(
    uri,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to unbookmark post: ${res.body}");
  }

  return jsonDecode(res.body);
}



Future<List<dynamic>> fetchBookmarkedUser(
  String baseUrl,
  String accessToken,
  String? maxId,
  String? sinceId,
) async {
  final uri = Uri.parse("$baseUrl/api/v1/bookmarks").replace(
    queryParameters: {
      'max_id': maxId,
      'since_id': sinceId
    },
  );

  final res = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    },
  );

  if (res.statusCode != 200) {
    throw Exception("Failed to load home timeline: ${res.body}");
  }


  return jsonDecode(res.body);
}


Future<void> createFediversePost({
  required String content,
  required String instanceUrl, // contoh: https://fedi.example.com
  required String accessToken, // token OAuth setelah login
  List<File>? images,
}) async {
  final List<String> mediaIds = [];

  // ========================================
  // 1. Upload gambar (jika ada)
  // ========================================
  if (images != null && images.isNotEmpty) {
    for (var img in images) {
      final uploadUrl = Uri.parse('$instanceUrl/api/v1/media');

      final req = http.MultipartRequest("POST", uploadUrl)
        ..headers['Authorization'] = 'Bearer $accessToken'
        ..files.add(await http.MultipartFile.fromPath('file', img.path));

      final resp = await req.send();

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final body = await resp.stream.bytesToString();
        final json = jsonDecode(body);

        mediaIds.add(json['id']);
      } else {
        throw Exception("Gagal upload media: ${resp.statusCode}");
      }
    }
  }

  // ========================================
  // 2. Kirim status
  // ========================================
  final postUrl = Uri.parse('$instanceUrl/api/v1/statuses');

  final response = await http.post(
    postUrl,
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: {'status': content, if (mediaIds.isNotEmpty) 'media_ids[]': mediaIds},
  );

  if (response.statusCode >= 200 && response.statusCode < 300) {
    print("Post berhasil: ${response.body}");
  } else {
    print("Gagal posting: ${response.statusCode} → ${response.body}");
    throw Exception("Gagal posting");
  }
}
