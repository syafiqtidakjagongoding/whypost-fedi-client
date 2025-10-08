import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/api/utils_api.dart';
import 'package:mobileapp/state/token.dart';

Future<void> initGuestUser(WidgetRef ref) async {
  // Cek apakah user sudah login
  final auth = FirebaseAuth.instance;
  print("AKU ANONY,M");

  if (auth.currentUser == null) {
    // Login anonim kalau belum
    await auth.signInAnonymously();
    final String token = await getToken(null);
    ref.read(tokenProvider.notifier).state = token;
  }

  final user = auth.currentUser!;
  final usersRef = FirebaseFirestore.instance.collection('users');

  // Buat / update data di Firestore
  final doc = usersRef.doc(user.uid);
  final snapshot = await doc.get();

  if (!snapshot.exists) {
    final token = await getToken(user.uid);
    ref.read(tokenProvider.notifier).state = token;
    print(token);
    await doc.set({
      'uid': user.uid,
      'is_guest': true,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  } else {
    final token = await getToken(user.uid);
    ref.read(tokenProvider.notifier).state = token;
    print(token);
    await doc.update({'updated_at': FieldValue.serverTimestamp()});
  }
}

Future<void> upgradeGuest(String email, String password) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw Exception("Tidak ada guest user yang sedang login.");
  }

  final credential = EmailAuthProvider.credential(
    email: email,
    password: password,
  );

  // 🔑 Link akun anonymous dengan email/password
  final result = await user.linkWithCredential(credential);

  // UID tetap sama dengan guest sebelumnya 👌
  final uid = result.user!.uid;
  final fid = await FirebaseInstallations.instance.getId();

  final usersRef = FirebaseFirestore.instance.collection('users');
  final existing = await usersRef
      .where('installation_id', isEqualTo: fid)
      .limit(1)
      .get();

  if (existing.docs.isNotEmpty) {
    await usersRef.doc(existing.docs.first.id).update({
      'email': email,
      'is_guest': false,
      'updated_at': FieldValue.serverTimestamp(),
    });
  } else {
    // fallback: kalau somehow gak ada guest doc
    await usersRef.doc(uid).set({
      'email': email,
      'nickname': "Anonymous",
      'username': "anon_" + existing.docs.first.id,
      'is_guest': false,
      'installation_id': fid,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
