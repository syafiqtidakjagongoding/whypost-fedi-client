// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobileapp/api/user_api.dart';
// import 'package:mobileapp/state/postNotifier.dart';
// import 'package:mobileapp/state/user.dart';
// import 'package:mobileapp/ui/widgets/post_images.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:mobileapp/domain/posts.dart';

// class ViewpostScreen extends ConsumerStatefulWidget {
//   final Posts post;

//   const ViewpostScreen({super.key, required this.post});

//   @override
//   ConsumerState<ViewpostScreen> createState() => _ViewpostScreenState();
// }

// class _ViewpostScreenState extends ConsumerState<ViewpostScreen> {
//   late Posts post;
//   late bool isLiked = false;
//   late int totalLiked;
//   late bool isBookmarked;
//   late bool isUserPost = false;

//   void toggleLike() {
//     final user = ref.watch(userProvider);
//     final notifier = ref.read(postsNotifierProvider(user!.uid).notifier);

//     // Optimistic UI update
//     setState(() {
//       isLiked = !isLiked;
//       if (isLiked) {
//         totalLiked += 1;
//       } else {
//         totalLiked = totalLiked > 0 ? totalLiked - 1 : 0;
//       }

//       post = post.copyWith(totalLiked: totalLiked, isLikedByMe: isLiked);
//     });

//     // Update ke backend (Firestore/API)
//     notifier.toggleLike(post.id, isLiked);
//     ref.invalidate(userPosttreamProvider);
//     ref.invalidate(bookmarkPostsStreamProvider);
//     ref.invalidate(likedPostsStreamProvider);
//     ref.invalidate(postsStreamProvider);
//   }

//   bool checkIsUserPost(String userId) {
//     final user = ref.read(userProvider);
//     return userId == user!.uid;
//   }

//   List<Widget> buildPostMenu(bool isUserPost) {
//     final menu = <Widget>[];

//     if (isUserPost) {
//       menu.add(
//         ListTile(
//           leading: Icon(Icons.edit, color: Colors.blue),
//           title: Text('Edit Postingan'),
//           onTap: () {},
//         ),
//       );
//       menu.add(
//         ListTile(
//           leading: Icon(Icons.delete, color: Colors.red),
//           title: Text('Hapus Postingan'),
//           onTap: () {},
//         ),
//       );
//     } else {
//       menu.add(
//         ListTile(
//           leading: Icon(Icons.flag, color: Colors.orange),
//           title: Text('Laporkan Postingan'),
//           onTap: () {},
//         ),
//       );
//     }

//     return menu;
//   }

//   void toggleBookmark() {
//     final user = ref.watch(userProvider);
//     final notifier = ref.read(postsNotifierProvider(user!.uid).notifier);

//     setState(() {
//       isBookmarked = !isBookmarked;
//       post = post.copyWith(isBookmarked: isBookmarked);
//     });

//     notifier.toggleBookmark(post.id, isBookmarked);
//     ref.invalidate(userPosttreamProvider);
//     ref.invalidate(likedPostsStreamProvider);
//     ref.invalidate(bookmarkPostsStreamProvider);
//     ref.invalidate(postsStreamProvider);
//   }

//   @override
//   void initState() {
//     super.initState();
//     post = widget.post;
//     isLiked = post.isLikedByMe; // sekarang aman karena post sudah diisi
//     totalLiked = post.totalLiked;
//     isBookmarked = post.isBookmarked;
//     isUserPost = checkIsUserPost(post.userId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Post")),
//       body: SingleChildScrollView(
//         child: Card(
//           margin: const EdgeInsets.all(12),
//           child: Padding(
//             padding: const EdgeInsets.all(12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 🧍 Header Post (Profile + Username + Waktu)
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const CircleAvatar(
//                       radius: 20,
//                       child: Icon(Icons.person, size: 30, color: Colors.white),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 post.nickname ?? "Anonymous",
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Text(
//                                   "@${post.username ?? ''}",
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 1,
//                                   style: const TextStyle(fontSize: 12),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   showModalBottomSheet(
//                                     context: context,
//                                     builder: (context) {
//                                       return SafeArea(
//                                         child: Column(
//                                           mainAxisSize: MainAxisSize.min,
//                                           children: buildPostMenu(isUserPost),
//                                         ),
//                                       );
//                                     },
//                                   );
//                                 },
//                                 child: const Padding(
//                                   padding: EdgeInsets.all(
//                                     4.0,
//                                   ), // kecilin area sentuh
//                                   child: Icon(
//                                     Icons.more_vert,
//                                     size:
//                                         18, // kecilin biar proporsional dengan teks
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             timeago.format(post.createdAt.toLocal()),
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 8),

//                 // 📝 Konten Text
//                 Text(post.content),

//                 const SizedBox(height: 8),

//                 // 🖼️ Gambar Postingan
//                 PostImages(images: post.images),

//                 const SizedBox(height: 8),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   children: [
//                     IconButton(
//                       icon: Icon(
//                         isLiked ? Icons.favorite : Icons.favorite_border,
//                       ),
//                       color: Colors.red,
//                       onPressed: () {
//                         toggleLike();
//                       },
//                     ),
//                     Text(
//                       totalLiked.toString(),
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                     const SizedBox(width: 16),

//                     IconButton(
//                       icon: const Icon(Icons.comment_outlined),
//                       color: Colors.grey,
//                       onPressed: () {
//                         // Navigasi ke comment atau fokus ke bagian komentar
//                       },
//                     ),
//                     Text(
//                       post.totalComment.toString(),
//                       style: const TextStyle(fontSize: 14),
//                     ),
//                     const SizedBox(width: 16),

//                     IconButton(
//                       icon: Icon(
//                         isBookmarked ? Icons.bookmark : Icons.bookmark_border,
//                       ),
//                       color: Colors.grey,
//                       onPressed: () {
//                         toggleBookmark();
//                       },
//                     ),
//                   ],
//                 ),

//                 const Divider(
//                   color: Colors.black45,
//                   thickness: 1.5,
//                   indent: 10,
//                   endIndent: 10,
//                 ),

//                 // 🗨️ Contoh Komentar (bisa diganti ListView.builder)
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: comments.map((c) => _buildCommentTree(c)).toList(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCommentTree(Comment comment, {int depth = 0}) {
//     return Padding(
//       padding: EdgeInsets.only(left: depth * 16.0, top: 8, bottom: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Komentar utama
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const CircleAvatar(
//                 radius: 15,
//                 child: Icon(Icons.person, size: 20, color: Colors.white),
//               ),
//               const SizedBox(width: 10),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       comment.username,
//                       style: const TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Text(comment.content),
//                   ],
//                 ),
//               ),
//               const Divider(
//                 color: Colors.black45,
//                 thickness: 1.5,
//                 indent: 10,
//                 endIndent: 10,
//               ),
//             ],
//           ),

//           // 🧵 Balasan komentar (jika ada)
//           if (comment.replies.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.only(left: 20),
//               child: Column(
//                 children: comment.replies
//                     .map((reply) => _buildCommentTree(reply, depth: depth + 1))
//                     .toList(),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// class Comment {
//   final String username;
//   final String content;
//   final List<Comment> replies;

//   Comment({
//     required this.username,
//     required this.content,
//     this.replies = const [],
//   });
// }

// final comments = [
//   Comment(
//     username: "user1",
//     content: "Komentar pertama",
//     replies: [
//       Comment(
//         username: "user2",
//         content: "Balasan ke user1",
//         replies: [Comment(username: "user3", content: "Balasan ke user2")],
//       ),
//     ],
//   ),
//   Comment(username: "user4", content: "Komentar kedua tanpa reply"),
// ];
