import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/api/post_api.dart';
import 'package:mobileapp/state/credentials.dart';

class HomeTimelineNotifier extends AsyncNotifier<List<dynamic>> {
  String? maxId;
  String? lastSinceId;
  bool hasMore = true;

  @override
  Future<List<dynamic>> build() async {
    return await _loadInitial();
  }

  Future<List<dynamic>> _loadInitial() async {
    final credential = await ref.watch(credentialProvider.future);

    final posts = await fetchHomeTimeline(
      credential.instanceUrl!,
      credential.accToken!,
      30,
     null,
      null
    );

    if (posts.isNotEmpty) {
      maxId = posts.last['id']; // cursor for pagination
      lastSinceId = posts.first['id'];
    }

    return posts;
  }
 Future<void> loadMore() async {

    try {
      final credential = await ref.watch(credentialProvider.future);

      final morePosts = await fetchHomeTimeline(
        credential.instanceUrl!,
        credential.accToken!,
        30,
        maxId,
        null
      );

      if (morePosts.isNotEmpty) {
        maxId = morePosts.last['id'];

        state = AsyncData([
          ...state.value!,
          ...morePosts,
        ]);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    try {
      final credential = await ref.watch(credentialProvider.future);

      final newPosts = await fetchHomeTimeline(
        credential.instanceUrl!,
        credential.accToken!,
        30,
        null,
        null, // Only newer posts
      );

      if (newPosts.isNotEmpty) {
        lastSinceId = newPosts.first['id'];

        // prepend posts terbaru
        state = AsyncData(newPosts);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final homeTimelineProvider =
    AsyncNotifierProvider<HomeTimelineNotifier, List<dynamic>>(
      () => HomeTimelineNotifier(),
    );
