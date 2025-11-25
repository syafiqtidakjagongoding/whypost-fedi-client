import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final postStateProvider =
    StateNotifierProvider<PostStateNotifier, Map<String, dynamic>>(
      (ref) => PostStateNotifier(),
    );

class PostStateNotifier extends StateNotifier<Map<String, dynamic>> {
  PostStateNotifier() : super({});

  void mergePosts(List<dynamic> posts) {
    for (var p in posts) {
      state = {
        ...state,
        p['id']: p, // simpan seluruh objek post lengkap
      };
    }
  }

  void patch(String id, Map<String, dynamic> updates) {
    if (!state.containsKey(id)) return;
    state = {
      ...state,
      id: {
        ...Map<String, dynamic>.from(state[id]!), // pastikan copy
        ...updates,
      },
    };
  }
}
