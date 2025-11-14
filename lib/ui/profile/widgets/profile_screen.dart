// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mobileapp/api/user_api.dart';
// import 'package:mobileapp/routing/routes.dart';
// import 'package:mobileapp/state/user.dart';
// import 'package:mobileapp/ui/widgets/post_card.dart';

// class ProfileScreen extends ConsumerStatefulWidget {
//   ProfileScreen({super.key});

//   @override
//   ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends ConsumerState<ProfileScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final user = ref.watch(userProvider);
//     final userPostsAsync = ref.watch(userPosttreamProvider(user!.uid));
//     final likedPostsAsync = ref.watch(likedPostsStreamProvider);
//     final savedPostsAsync = ref.watch(bookmarkPostsStreamProvider);

//     final totalPosts = userPostsAsync.maybeWhen(
//       data: (posts) => posts.length,
//       orElse: () => 0,
//     );

//     return Scaffold(
//       body: DefaultTabController(
//         length: 3,
//         child: Column(
//           children: [
//             // 🔹 Header
//             Container(
//               padding: EdgeInsets.fromLTRB(16, 30, 16, 25),
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.primary,
//               ),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 30,
//                     child: Icon(Icons.person, size: 35, color: Colors.white),
//                   ),

//                   SizedBox(width: 16),
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         (user.nickname.isNotEmpty == true)
//                             ? user.nickname
//                             : "Anonymous",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Text(
//                         (user.username.isNotEmpty == true) ? user.username : "",
//                         style: TextStyle(fontSize: 12),
//                       ),
//                       SizedBox(height: 4),
//                       Text("Total posts : " + totalPosts.toString()),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             // 🔹 TabBar
//             TabBar(
//               indicatorColor: Colors.black,
//               labelColor: Colors.black,
//               unselectedLabelColor: Colors.grey,
//               tabs: [
//                 Tab(text: "Your posts", icon: Icon(Icons.post_add)),
//                 Tab(text: "Likes", icon: Icon(Icons.favorite)),
//                 Tab(text: "Saved post", icon: Icon(Icons.bookmark)),
//               ],
//             ),

//             // 🔹 TabBarView
//             Expanded(
//               child: TabBarView(
//                 children: [
//                   // 👉 Tab Postingan
//                   userPostsAsync.when(
//                     data: (posts) {
//                       if (posts.isEmpty) {
//                         return const Center(child: Text("Belum ada postingan"));
//                       }
//                       return ListView.builder(
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         itemCount: posts.length,
//                         itemBuilder: (context, index) {
//                           final post = posts[index];
//                           return PostCard(post: post);
//                         },
//                       );
//                     },
//                     loading: () =>
//                         const Center(child: CircularProgressIndicator()),
//                     error: (e, _) => Center(child: Text('Error: $e')),
//                   ),

//                   // 👉 Tab Likes
//                   likedPostsAsync.when(
//                     data: (posts) {
//                       if (posts.isEmpty) {
//                         return const Center(child: Text("Belum ada postingan"));
//                       }
//                       return ListView.builder(
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         itemCount: posts.length,
//                         itemBuilder: (context, index) {
//                           final post = posts[index];
//                           return PostCard(post: post);
//                         },
//                       );
//                     },
//                     loading: () =>
//                         const Center(child: CircularProgressIndicator()),
//                     error: (e, _) => Center(child: Text('Error: $e')),
//                   ),

//                   // 👉 Tab Saved Post
//                   savedPostsAsync.when(
//                     data: (posts) {
//                       if (posts.isEmpty) {
//                         return const Center(child: Text("Belum ada postingan"));
//                       }
//                       return ListView.builder(
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         itemCount: posts.length,
//                         itemBuilder: (context, index) {
//                           final post = posts[index];
//                           return PostCard(post: post);
//                         },
//                       );
//                     },
//                     loading: () =>
//                         const Center(child: CircularProgressIndicator()),
//                     error: (e, _) => Center(child: Text('Error: $e')),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           context.go(Routes.addPost);
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
