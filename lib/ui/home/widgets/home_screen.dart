import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/state/postNotifier.dart';
import 'package:mobileapp/ui/widgets/post_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // fetch hanya saat pertama kali masuk, tidak setiap navigasi
    if (ref.read(postsProvider).isEmpty) {
      ref.read(postsProvider.notifier).fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Timeline')),
      body: RefreshIndicator(
        onRefresh: () async {
          // 🌀 Pull to refresh -> fetch ulang
          await ref.read(postsProvider.notifier).fetch();
        },
        child: posts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(), // penting!
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostCard(post: post);
                },
              ),
      ),
    );
  }
}
