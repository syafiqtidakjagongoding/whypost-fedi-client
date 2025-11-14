// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:mobileapp/api/bookmark_api.dart';
// import 'package:mobileapp/api/user_api.dart';
// import 'package:mobileapp/state/postNotifier.dart';
// import 'package:mobileapp/state/user.dart';
// import 'package:mobileapp/ui/viewpost/viewpost_screen.dart';
// import 'package:timeago/timeago.dart' as timeago;
// import 'package:flutter/material.dart';
// import 'package:mobileapp/domain/posts.dart';
// import 'package:mobileapp/ui/widgets/post_images.dart';

// class PostCard extends ConsumerStatefulWidget {
//   final Posts post; // ✅ terima data post lewat constructor

//   const PostCard({Key? key, required this.post}) : super(key: key);

//   @override
//   ConsumerState<PostCard> createState() => _PostCardState(); // ✅ buat State
// }

// class _PostCardState extends ConsumerState<PostCard> {
//   late Posts post;
//   late bool isLiked;
//   late bool isBookmarked;
//   late int totalLiked;
//   late bool isUserPost = false;

//   @override
//   void initState() {
//     super.initState();
//     post = widget.post; // ✅ akses dari widget
//     isLiked = post.isLikedByMe; // sekarang aman karena post sudah diisi
//     totalLiked = post.totalLiked;
//     isBookmarked = post.isBookmarked;
//     isUserPost = checkIsUserPost(post.userId);
//   }

//   bool checkIsUserPost(String userId) {
//     final user = ref.read(userProvider);
//     return userId == user!.uid;
//   }

//   void toggleLike() {
//     final user = ref.read(userProvider);
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

//   void toggleBookmark() {
//     final user = ref.read(userProvider);
//     final notifier = ref.read(postsNotifierProvider(user!.uid).notifier);

//     setState(() {
//       isBookmarked = !isBookmarked;
//       post = post.copyWith(isBookmarked: isBookmarked);
//     });

//     notifier.toggleBookmark(post.id, isBookmarked);
//     ref.invalidate(userPosttreamProvider);
//     ref.invalidate(bookmarkPostsStreamProvider);
//     ref.invalidate(likedPostsStreamProvider);

//     ref.invalidate(postsStreamProvider);
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

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ViewpostScreen(post: post), // ← kirim datanya
//           ),
//         );
//       },

//       child: Card(
//         margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const CircleAvatar(
//                     radius: 20,
//                     child: Icon(Icons.person, size: 30, color: Colors.white),
//                   ),
//                   SizedBox(width: 10),
//                   // Expanded supaya area nickname + time memenuhi sisa ruang
//                   Expanded(
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Nama user di kiri
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Baris atas: nickname, username, waktu, icon more
//                               Row(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   // Nama + username
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           post.nickname ?? "Anonymous",
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         const SizedBox(height: 2),
//                                         Text(
//                                           "@${post.username ?? ''}",
//                                           overflow: TextOverflow.ellipsis,
//                                           maxLines: 1,
//                                           style: const TextStyle(
//                                             fontSize: 12,
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Row(
//                                     crossAxisAlignment: CrossAxisAlignment
//                                         .center, // sejajarkan di tengah
//                                     children: [
//                                       Text(
//                                         timeago.format(
//                                           post.createdAt.toLocal(),
//                                         ),
//                                         style: const TextStyle(
//                                           fontSize: 12,
//                                           color: Colors.grey,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       GestureDetector(
//                                         onTap: () {
//                                           showModalBottomSheet(
//                                             context: context,
//                                             builder: (context) {
//                                               return SafeArea(
//                                                 child: Column(
//                                                   mainAxisSize:
//                                                       MainAxisSize.min,
//                                                   children: buildPostMenu(
//                                                     isUserPost,
//                                                   ),
//                                                 ),
//                                               );
//                                             },
//                                           );
//                                         },
//                                         child: const Padding(
//                                           padding: EdgeInsets.all(
//                                             4.0,
//                                           ), // kecilin area sentuh
//                                           child: Icon(
//                                             Icons.more_vert,
//                                             size:
//                                                 18, // kecilin biar proporsional dengan teks
//                                             color: Colors.grey,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               // Konten teks
//               const SizedBox(height: 8),
//               Text(post.content),
//               const SizedBox(height: 8),

//               PostImages(images: post.images),

//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   IconButton(
//                     icon: Icon(
//                       isLiked ? Icons.favorite : Icons.favorite_border,
//                     ), // ganti ke Icons.favorite kalau sudah like
//                     color: Colors.red,
//                     onPressed: () {
//                       toggleLike();
//                     },
//                   ),
//                   Text(
//                     totalLiked.toString(), // contoh jumlah like
//                     style: TextStyle(fontSize: 14),
//                   ),
//                   SizedBox(width: 16),

//                   // 💬 Comment Button
//                   IconButton(
//                     icon: Icon(Icons.comment_outlined),
//                     color: Colors.grey[700],
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) =>
//                               ViewpostScreen(post: post), // ← kirim datanya
//                         ),
//                       );
//                     },
//                   ),
//                   Text(
//                     post.totalComment.toString(),
//                     style: TextStyle(fontSize: 14),
//                   ),
//                   SizedBox(width: 16),

//                   // 📤 Share Button
//                   IconButton(
//                     icon: Icon(
//                       isBookmarked ? Icons.bookmark : Icons.bookmark_border,
//                     ),
//                     color: Colors.grey[700],
//                     onPressed: () {
//                       toggleBookmark();
//                     },
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
