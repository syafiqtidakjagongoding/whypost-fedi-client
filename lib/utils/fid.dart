import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> syncUserToFirestore() async {
  final fid = await FirebaseInstallations.instance.getId();
  final fcmToken = await FirebaseMessaging.instance.getToken();
  final usersRef = FirebaseFirestore.instance.collection('users');


  // cek apakah user dengan FID ini sudah ada
  final existing = await usersRef.where('installation_id', isEqualTo: fid).limit(1).get();

  if (existing.docs.isEmpty) {
    // kalau belum ada, buat baru
    await usersRef.add({
      'username': "",
      'email': "",
      'password': "",
      'installation_id': fid,
      'fcm_token': fcmToken,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  } else {
    // kalau sudah ada, update timestamp
    await usersRef.doc(existing.docs.first.id).update({
      'updated_at': FieldValue.serverTimestamp(),
    });
  }
}
