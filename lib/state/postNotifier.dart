import 'package:flutter_riverpod/legacy.dart';
import 'package:mobileapp/api/post_api.dart';
import 'package:mobileapp/domain/posts.dart';

final postsProvider = StateNotifierProvider<PostsNotifier, List<Posts>>((ref) {
  return PostsNotifier();
});

class PostsNotifier extends StateNotifier<List<Posts>> {
  PostsNotifier() : super([]);

  Future<void> fetch() async {
    // 🔸 Ganti dengan Firestore
    final posts = await fetchPostsOnce(); 
    state = posts;
  }
}
