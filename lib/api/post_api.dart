import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/domain/posts.dart';
import 'package:mobileapp/state/token.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

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
