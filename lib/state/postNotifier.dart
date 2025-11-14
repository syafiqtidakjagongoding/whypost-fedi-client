// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_riverpod/legacy.dart';
// import 'package:mobileapp/domain/posts.dart';

// // 🔸 Ganti dengan Firestore
// final postsStreamProvider = StreamProvider.family<List<Posts>, String>((
//   ref,
//   userInThisDevice,
// ) async* {
//   final firestore = FirebaseFirestore.instance;

//   // 1️⃣ Stream data post realtime
//   final postsStream = firestore
//       .collection('posts')
//       .orderBy('created_at', descending: true)
//       .snapshots();

//   await for (final snapshot in postsStream) {
//     if (snapshot.docs.isEmpty) {
//       yield [];
//       continue;
//     }

//     // 2️⃣ Ambil semua userId unik dari post
//     final userIds = snapshot.docs
//         .map((doc) => doc['user_id'] as String)
//         .toSet()
//         .toList();

//     // 3️⃣ Ambil data user terkait (1x per snapshot)
//     final usersSnapshot = await firestore
//         .collection('users')
//         .where('uid', whereIn: userIds)
//         .get();

//     final userMap = {
//       for (var doc in usersSnapshot.docs) doc.data()['uid']: doc.data(),
//     };

//     // 4️⃣ Ambil semua postId
//     final postIds = snapshot.docs.map((doc) => doc.id).toList();

//     // 5️⃣ Ambil semua like milik user ini
//     final likesSnapshot = await firestore
//         .collection('like_post')
//         .where(
//           FieldPath.documentId,
//           whereIn: postIds.map((id) => '${userInThisDevice}_$id').toList(),
//         )
//         .get();

//     final likedPostIds = likesSnapshot.docs
//         .map((doc) => doc.id.split('_').last)
//         .toSet(); // ambil id post dari documentId

//     final bookmarksSnapshot = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(userInThisDevice)
//         .collection('bookmarks')
//         .where(FieldPath.documentId, whereIn: postIds)
//         .get();

//     final bookmarkedPostIds = bookmarksSnapshot.docs
//         .map((doc) => doc.id)
//         .toSet();

//     // 6️⃣ Gabungkan semua data ke model Posts
//     final posts = snapshot.docs.map((doc) {
//       final data = doc.data();
//       final userId = data['user_id'] as String;
//       final userData = userMap[userId];

//       final isLikedByMe = likedPostIds.contains(doc.id);
//       final isBookmarked = bookmarkedPostIds.contains(doc.id);

//       return Posts.fromFirestore(
//         doc.id,
//         data,
//         userData: userData,
//         isLikedByMe: isLikedByMe,
//         isBookmarked: isBookmarked,
//       );
//     }).toList();

//     print("Fetching");
//     // 7️⃣ Emit hasilnya ke stream
//     yield posts;
//   }
// });

// final postsNotifierProvider =
//     StateNotifierProvider.family<PostsNotifier, List<Posts>, String>((
//       ref,
//       userId,
//     ) {
//       final notifier = PostsNotifier(ref, userId);

//       // Dengarkan stream dari Firestore dan sinkronkan ke state
//       ref.listen(postsStreamProvider(userId), (prev, next) {
//         next.whenData((posts) {
//           notifier.updateFromStream(posts);
//         });
//       });

//       return notifier;
//     });

// class PostsNotifier extends StateNotifier<List<Posts>> {
//   final Ref ref;
//   final String userId;

//   PostsNotifier(this.ref, this.userId) : super([]);

//   /// Dipanggil otomatis setiap kali stream Firestore berubah
//   void updateFromStream(List<Posts> newPosts) {
//     // Gabungkan: kalau ada optimistic update lokal, jangan langsung ditiban
//     final Map<String, Posts> current = {for (var p in state) p.id: p};
//     final merged = newPosts.map((post) {
//       final local = current[post.id];
//       if (local == null) return post;

//       // Kalau ada perubahan lokal (optimistik) sebelum Firestore update masuk, pakai yang paling baru
//       final hasLocalLikeChange =
//           local.isLikedByMe != post.isLikedByMe ||
//           local.totalLiked != post.totalLiked;

//       final hasLocalBookmarkChange = local.isBookmarked != post.isBookmarked;

//       if (hasLocalLikeChange || hasLocalBookmarkChange) {
//         return local; // Prioritaskan data lokal yang masih lebih baru
//       }
//       return post;
//     }).toList();

//     state = merged;
//   }

//   /// Optimistic UI update
//   void optimisticToggle(String postId, bool newLiked) {
//     final index = state.indexWhere((p) => p.id == postId);
//     if (index == -1) return;
//     final old = state[index];

//     final updated = old.copyWith(
//       isLikedByMe: newLiked,
//       totalLiked: old.totalLiked + (newLiked ? 1 : -1),
//     );

//     state = [...state]..[index] = updated;
//   }

//   /// Optimistic UI update untuk bookmark
//   void optimisticToggleBookmark(String postId, bool newBookmarked) {
//     // Cari post berdasarkan ID
//     final index = state.indexWhere((p) => p.id == postId);
//     if (index == -1) return; // kalau tidak ditemukan, keluar

//     final old = state[index];

//     // Buat versi baru dari post dengan status bookmark yang diubah
//     final updated = old.copyWith(isBookmarked: newBookmarked);

//     // Update state secara immutable
//     state = [...state]..[index] = updated;
//   }

//   /// Update Firestore secara async
//   Future<void> toggleLike(String postId, bool isLiked) async {
//     optimisticToggle(postId, isLiked);

//     final firestore = FirebaseFirestore.instance;
//     final likeRef = firestore.collection('like_post').doc('${userId}_$postId');
//     final postRef = firestore.collection('posts').doc(postId);

//     try {
//       await firestore.runTransaction((tx) async {
//         final postSnap = await tx.get(postRef);
//         final data = postSnap.data() ?? {};
//         final currentTotal = data['total_liked'] is int
//             ? data['total_liked'] as int
//             : 0;
//         final total = currentTotal + (isLiked ? 1 : -1);

//         // 🔹 Pastikan tidak bisa negatif
//         final safeTotal = total < 0 ? 0 : total;

//         tx.update(postRef, {'total_liked': safeTotal});

//         if (isLiked) {
//           tx.set(likeRef, {'user_id': userId, 'post_id': postId});
//         } else {
//           tx.delete(likeRef);
//         }
//       });
//     } catch (e) {
//       print('❌ toggleLike error: $e');
//     }
//   }

//   /// Update Firestore secara async untuk bookmark
//   Future<void> toggleBookmark(String postId, bool isBookmarked) async {
//     // Optimistic UI update
//     optimisticToggleBookmark(postId, isBookmarked);

//     final firestore = FirebaseFirestore.instance;
//     final bookmarkRef = firestore
//         .collection('users')
//         .doc(userId)
//         .collection('bookmarks')
//         .doc(postId);

//     try {
//       if (isBookmarked) {
//         // Tambahkan bookmark
//         await bookmarkRef.set({
//           'user_id': userId,
//           'post_id': postId,
//           'created_at': FieldValue.serverTimestamp(),
//         });
//         print("Terbookmark");
//       } else {
//         // Hapus bookmark
//         await bookmarkRef.delete();
//         print("Terhapus bookmark");
//       }
//     } catch (e) {
//       print('❌ toggleBookmark error: $e');
//     }
//   }
// }
