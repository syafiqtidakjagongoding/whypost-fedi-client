import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/misc.dart';
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
      10,
      null,
      null,
    );

    if (posts.isNotEmpty) {
      maxId = posts.last['id']; // cursor for pagination
      lastSinceId = posts.first['id'];
    }
    return posts;
  }

  Future<void> loadMore() async {
    try {
      final cred = await CredentialsRepository.loadCredentials();

      final morePosts = await fetchHomeTimeline(
        cred.instanceUrl!,
        cred.accToken!,
        10,
        maxId,
        null,
      );

      if (morePosts.isNotEmpty) {
        maxId = morePosts.last['id'];

        state = AsyncData([...state.value!, ...morePosts]);
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

final statusesOnlyMediaTimelineProvider =
    FutureProvider.family<List<dynamic>, String>((ref, userId) async {
      final cred = await CredentialsRepository.loadCredentials();

      // Cek kredensial
      if (cred.accToken == null || cred.instanceUrl == null) {
        return [];
      }

      // Fetch posts user
      final posts = await fetchStatusesUserByIdOnlyMedia(
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
  return posts;
});

class TagTimelineState {
  final List<dynamic> posts;
  final bool isLoading;
  final bool hasMore;
  final String? maxId;

  TagTimelineState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.maxId,
  });

  TagTimelineState copyWith({
    List<dynamic>? posts,
    bool? isLoading,
    bool? hasMore,
    String? maxId,
  }) {
    return TagTimelineState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      maxId: maxId ?? this.maxId,
    );
  }
}

final tagTimelineProvider =
    StateNotifierProvider.family<TagTimelineNotifier, TagTimelineState, String>(
      (ref, tag) {
        return TagTimelineNotifier(ref, tag);
      },
    );

class TagTimelineNotifier extends StateNotifier<TagTimelineState> {
  final Ref ref;
  final String tag;

  TagTimelineNotifier(this.ref, this.tag) : super(TagTimelineState()) {
    loadInitial();
  }

  Future<void> loadInitial() async {
    final cred = await CredentialsRepository.loadCredentials();
    if (cred.accToken == null || cred.instanceUrl == null) return;

    state = state.copyWith(isLoading: true);

    final posts = await fetchTagTimeline(
      cred.instanceUrl!,
      cred.accToken!,
      tag,
      10,
      null,
      null,
    );

    state = state.copyWith(
      posts: posts,
      isLoading: false,
      hasMore: posts.isNotEmpty,
      maxId: posts.isNotEmpty ? posts.last['id'] : null,
    );
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    final cred = await CredentialsRepository.loadCredentials();

    state = state.copyWith(isLoading: true);

    final more = await fetchTagTimeline(
      cred.instanceUrl!,
      cred.accToken!,
      tag,
      10,
      state.maxId,
      null,
    );

    state = state.copyWith(
      posts: [...state.posts, ...more],
      isLoading: false,
      hasMore: more.isNotEmpty,
      maxId: more.isNotEmpty ? more.last['id'] : state.maxId,
    );
  }
}

final trendingPostTimelineProvider =
    AsyncNotifierProvider<TrendingPostTimelineNotifier, List<dynamic>>(
      TrendingPostTimelineNotifier.new,
    );

class TrendingPostTimelineNotifier extends AsyncNotifier<List<dynamic>> {
  String? tag; // tag aktif
  String? maxId;
  bool hasMore = true;

  @override
  Future<List<dynamic>> build() async {
    // Tidak load apa-apa kalau tag belum ditentukan
    return _loadInitial();
  }

  /// Load data awal
  Future<List<dynamic>> _loadInitial() async {
    final cred = await CredentialsRepository.loadCredentials();
    if (cred.accToken == null || cred.instanceUrl == null) return [];

    final posts = await fetchTrendingPost(
      cred.instanceUrl!,
      cred.accToken!,
      null,
    );

    maxId = posts.isNotEmpty ? posts.last["id"] : null;
    hasMore = posts.isNotEmpty;

    return posts;
  }

  /// Load more untuk infinite scroll
  Future<void> loadMore() async {
    if (!hasMore || state.isLoading || tag == null) return;

    final current = state.value ?? [];

    state = AsyncValue.data(current); // tetap data saat loading

    final cred = await CredentialsRepository.loadCredentials();

    final more = await fetchTrendingPost(
      cred.instanceUrl!,
      cred.accToken!,
      maxId,
    );

    maxId = more.isNotEmpty ? more.last["id"] : maxId;
    hasMore = more.isNotEmpty;

    state = AsyncValue.data([...current, ...more]);
  }
}
