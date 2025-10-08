import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapp/domain/posts.dart';
import '../domain/users.dart';

/// Fungsi untuk mengambil data user saat ini dari Firestore
Future<AppUser?> fetchCurrentUserData() async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser == null) {
    // Belum login
    return null;
  }

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser.uid)
      .get();

  if (!doc.exists) {
    return null;
  }

  final data = doc.data()!;
  return AppUser.fromFirestore(doc.id, data);
}


Future<List<Posts>> fetchPostsByUserId(String userid) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where('userid', isEqualTo: userid)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Posts.fromFirestore(doc.id, doc.data()))
        .toList();
  } catch (e) {
    print('❌ Gagal fetch posts: $e');
    return [];
  }
}
