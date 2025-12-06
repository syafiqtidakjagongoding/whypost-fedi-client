import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobileapp/api/post_api.dart';
import 'package:mobileapp/sharedpreferences/credentials.dart';


final favoritePostActionProvider = FutureProvider.family((ref, String id) async {
  final cred = await CredentialsRepository.loadCredentials();

  // Cek kredensial
  if (cred.accToken == null || cred.instanceUrl == null) {
    throw Exception("No credentials");
  }

  // Panggil fungsi favourite
  final result = await favouritePost(
    cred.instanceUrl!,
    cred.accToken!,
    id, // ← parameter sekarang aman digunakan
  );

  return result;
});


final unfavoritePostActionProvider = FutureProvider.family((ref, String id) async {
  final cred = await CredentialsRepository.loadCredentials();

  // Cek kredensial
  if (cred.accToken == null || cred.instanceUrl == null) {
    throw Exception("No credentials");
  }

  // Panggil fungsi favourite
  final result = await unfavouritePost(
    cred.instanceUrl!,
    cred.accToken!,
    id, // ← parameter sekarang aman digunakan
  );

  return result;
});



final bookmarkPostActionProvider = FutureProvider.family((ref, String id) async {
  final cred = await CredentialsRepository.loadCredentials();

  // Cek kredensial
  if (cred.accToken == null || cred.instanceUrl == null) {
    throw Exception("No credentials");
  }

  // Panggil fungsi favourite
  final result = await bookmarkPost(
    cred.instanceUrl!,
    cred.accToken!,
    id, // ← parameter sekarang aman digunakan
  );

  return result;
});

final unbookmarkPostActionProvider = FutureProvider.family((ref, String id) async {
  final cred = await CredentialsRepository.loadCredentials();

  // Cek kredensial
  if (cred.accToken == null || cred.instanceUrl == null) {
    throw Exception("No credentials");
  }

  // Panggil fungsi favourite
  final result = await unbookmarkPost(
    cred.instanceUrl!,
    cred.accToken!,
    id, // ← parameter sekarang aman digunakan
  );

  return result;
});

final bookmarkProvider = StateProvider<Map<String, bool>>((ref) => {});
final favouriteProvider = StateProvider<Map<String, bool>>((ref) => {});
