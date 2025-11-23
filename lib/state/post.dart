import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mobileapp/api/post_api.dart';
import 'package:mobileapp/state/credentials.dart';
import 'package:mobileapp/state/globalpost.dart';

final statusesTimelineProvider = FutureProvider.family<List<dynamic>, String>((
  ref,
  userId,
) async {
  final cred = await CredentialsRepository.loadCredentials();

  // Cek kredensial
  if (cred.accToken == null || cred.instanceUrl == null) {
    return [];
  }

  // Fetch posts user
  final posts = await fetchStatusesUserById(
    cred.instanceUrl!,
    cred.accToken!,
    null, // max_id
    null, // since_id
    userId,
  );
  return posts;
});



final favouritedTimelineProvider = FutureProvider<List<dynamic>>((ref) async {
  final cred = await CredentialsRepository.loadCredentials();

  // Cek kredensial
  if (cred.accToken == null || cred.instanceUrl == null) {
    return [];
  }

  // Fetch posts user
  final posts = await fetchFavouritedUser(
    cred.instanceUrl!,
    cred.accToken!,
    null, // max_id
    null, // since_id
  );
  ref.read(postStateProvider.notifier).mergePosts(posts);
  return posts;
});

final bookmarkedTimelineProvider = FutureProvider<List<dynamic>>((ref) async {
  final cred = await CredentialsRepository.loadCredentials();

  // Cek kredensial
  if (cred.accToken == null || cred.instanceUrl == null) {
    return [];
  }

  // Fetch posts user
  final posts = await fetchBookmarkedUser(
    cred.instanceUrl!,
    cred.accToken!,
    null, // max_id
    null, // since_id
  );
  // Masukkan ke postState agar lengkap
  ref.read(postStateProvider.notifier).mergePosts(posts);
  return posts;
});
