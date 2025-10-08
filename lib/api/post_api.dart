import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/domain/posts.dart';
import 'package:mobileapp/state/token.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

Future<void> createPost({
  required String content,
  required WidgetRef ref,
  required BuildContext context,
  List<File>? images,
}) async {
  final messenger = ScaffoldMessenger.of(context); // ✅ ambil sebelum await
  try {
    final user = FirebaseAuth.instance.currentUser;
    final fid = await FirebaseInstallations.instance.getId();

    // 🔹 Upload semua gambar ke Storage (jika ada)
    List<String> imageUrls = [];
    if (images != null && images.isNotEmpty) {
      for (var img in images) {
        final String fName = await uploadFileToR2(ref, messenger, img);
        imageUrls.add("https://bucket.syafiq-paradisam.my.id/$fName");
      }
    }

    // 🔹 Simpan ke Firestore
    await FirebaseFirestore.instance.collection('posts').add({
      'user_id':
          user?.uid ??
          fid, // pakai uid kalau login, fallback ke installation ID
      'content': content,
      'images': imageUrls, // bisa kosong []
      'created_at': FieldValue.serverTimestamp(),
    });

    messenger.showSnackBar(
      const SnackBar(
        content: Text('Postingan berhasil dibuat'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating, // biar melayang
        duration: Duration(seconds: 2),
      ),
    );
  } catch (e) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('❌ Postingan gagal dibuat'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating, // biar melayang
        duration: Duration(seconds: 2),
      ),
    );
    rethrow;
  }
}

Future<String> uploadFileToR2(
  WidgetRef ref,
  ScaffoldMessengerState messenger,
  File file,
) async {
  final fileName =
      '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
  final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
  final token = ref.watch(tokenProvider); // ambil token global`
  final response = await http.get(
    Uri.parse(
      "https://presign-worker.syafiq-paradisam.my.id/get-presigned?filename=$fileName",
    ),
    headers: {"Authorization": "Bearer $token"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final url = data['url'] as String;
    final bytes = await file.readAsBytes();
    final uploadResp = await http.put(
      Uri.parse(url),
      headers: {
        "Content-Type": mimeType, // atau sesuai type file
      },
      body: bytes,
    );

    if (uploadResp.statusCode != 200 || uploadResp.statusCode != 201) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('❌ Postingan gagal dibuat'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating, // biar melayang
          duration: Duration(seconds: 2),
        ),
      );
    }
  } else {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('❌ Postingan gagal dibuat'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating, // biar melayang
        duration: Duration(seconds: 2),
      ),
    );
  }

  return fileName;
}

Future<List<Posts>> fetchPostsOnce() async {
  try {
    // 1️⃣ Ambil semua post
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('created_at', descending: true)
        .get();

    // 2️⃣ Ambil semua userId unik dari post
    final userIds = snapshot.docs
        .map((doc) => doc['user_id'] as String)
        .toSet()
        .toList();

    // 3️⃣ Ambil data user untuk userId tersebut
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', whereIn: userIds)
        .get();

    // Map userId -> userData
    final userMap = {for (var doc in usersSnapshot.docs) doc.id: doc.data()};

    // 4️⃣ Gabungkan post + user info
    final posts = snapshot.docs.map((doc) {
      final data = doc.data();
      final userId = data['user_id'] as String;
      final userData = userMap[userId]; // bisa null kalau user dihapus
      return Posts.fromFirestore(doc.id, data, userData: userData);
    }).toList();

    return posts;
  } catch (e) {
    print('❌ Gagal fetch posts: $e');
    return [];
  }
}
