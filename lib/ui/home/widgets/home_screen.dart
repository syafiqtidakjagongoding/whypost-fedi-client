import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // final postsAsync = ref.watch(postsStreamProvider(user!.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('For you'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(255, 117, 31, 1),
        titleTextStyle: const TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
      ),
      // body: postsAsync.when(
      //   data: (posts) => RefreshIndicator(
      //     onRefresh: () async {
      //       ref.invalidate(postsStreamProvider(user.uid));
      //     },
      //     child: posts.isEmpty
      //         ? const Center(child: Text('Belum ada post'))
      //         : ListView.builder(
      //             physics: const AlwaysScrollableScrollPhysics(),
      //             itemCount: posts.length,
      //             itemBuilder: (context, index) {
      //               final post = posts[index];
      //               return PostCard(post: post);
      //             },
      //           ),
      //   ),
      //   loading: () =>
      //       const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      //   error: (e, st) => Center(child: Text('Error: $e')),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(Routes.addPost);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
