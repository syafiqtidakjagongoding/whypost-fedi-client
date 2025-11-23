import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/api/post_api.dart';
import 'package:mobileapp/state/credentials.dart';
import 'package:mobileapp/state/globalpost.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTimelineNotifier extends AsyncNotifier<List<dynamic>> {
  String? maxId;
  String? lastSinceId;
  bool hasMore = true;

  @override
  Future<List<dynamic>> build() async {
    maxId = null; // reset
    lastSinceId = null; // reset
    hasMore = true; // reset
    final cred = await CredentialsRepository.loadCredentials();

    if (cred.accToken == null || cred.instanceUrl == null) {
      return [];
    }

    return await _loadInitial();
  }

  Future<List<dynamic>> _loadInitial() async {
    final cred = await CredentialsRepository.loadCredentials();
    if (cred.accToken == null || cred.instanceUrl == null) {
      return []; // atau state = AsyncData([]) → aman
    }

    final posts = await fetchHomeTimeline(
      cred.instanceUrl!,
      cred.accToken!,
      30,
      null,
      null,
    );

    if (posts.isNotEmpty) {
      maxId = posts.last['id']; // cursor for pagination
      lastSinceId = posts.first['id'];
    }
    ref.read(postStateProvider.notifier).mergePosts(posts);
    return posts;
  }

  Future<void> loadMore() async {
    try {
      final cred = await CredentialsRepository.loadCredentials();

      final morePosts = await fetchHomeTimeline(
        cred.instanceUrl!,
        cred.accToken!,
        30,
        maxId,
        null,
      );

      if (morePosts.isNotEmpty) {
        maxId = morePosts.last['id'];

        state = AsyncData([...state.value!, ...morePosts]);
      }
      ref.read(postStateProvider.notifier).mergePosts(morePosts);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

}

final homeTimelineProvider =
    AsyncNotifierProvider<HomeTimelineNotifier, List<dynamic>>(
      () => HomeTimelineNotifier(),
    );
