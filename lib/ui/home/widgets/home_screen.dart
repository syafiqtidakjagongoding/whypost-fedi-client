import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/explore.dart';
import 'package:mobileapp/state/globalpost.dart';
import 'package:mobileapp/state/timeline.dart';
import 'package:mobileapp/state/credentials.dart';
import 'package:mobileapp/state/trends.dart';
import 'package:mobileapp/state/user.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mobileapp/ui/posts/post_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String? instanceUrl;
  const HomeScreen({super.key, this.instanceUrl});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  String? instanceUrl;
  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      final notifier = ref.read(homeTimelineProvider.notifier);

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        notifier.loadMore(); // INFINITE SCROLL TRIGGER
      }
    });
    _loadInstance();
  }

  Future<void> _loadInstance() async {
    final url = await CredentialsRepository.getInstanceUrl();
    setState(() => instanceUrl = url);
  }

  @override
  Widget build(BuildContext context) {
    final timeline = ref.watch(homeTimelineProvider);

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
      drawer: Drawer(
        child: Column(
          children: [
            // Header
            DrawerHeader(
              decoration: BoxDecoration(color: Color.fromRGBO(255, 117, 31, 1)),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.end, // supaya berada di bawah
                  children: [
                    Text(
                      'Menu',
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8), // jarak antar teks
                    if (instanceUrl != null)
                      Text(instanceUrl!, style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

            // ==== Menu list ====
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Timeline"),
              onTap: () {
                context.push(Routes.timeline);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                context.push(Routes.settings);
              },
            ),

            // ===== Spacer mendorong logout ke bawah =====
            const Spacer(),

            // ==== LOGOUT BUTTON ====
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Konfirmasi Logout"),
                        content: const Text("Apakah kamu yakin ingin logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => context.pop(),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    // TAMBAHKAN INI - Invalidate semua provider terkait

                    CredentialsRepository.clearAll();
                    ref.invalidate(homeTimelineProvider);
                    ref.invalidate(currentUserProvider);
                    ref.invalidate(favouritedTimelineProvider);
                    ref.invalidate(bookmarkedTimelineProvider);
                    ref.invalidate(trendingLinksProvider);
                    ref.invalidate(trendingTagsProvider);
                    ref.invalidate(suggestedPeopleProvider);
                    ref.invalidate(trendingPostTimelineProvider);
                    if (context.mounted) {
                      context.go(Routes.instance);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          // Background image
          // Positioned.fill(
          // child: Image.network(
          //   'https://m.media-amazon.com/images/I/8176qiSGiqL._AC_UF1000,1000_QL80_.jpg',
          //   fit: BoxFit.cover,
          //   loadingBuilder: (context, child, loadingProgress) {
          //     if (loadingProgress == null) return child;
          //     return const Center(child: CircularProgressIndicator());
          //   },
          //   errorBuilder: (context, error, stackTrace) {
          //     return Container(
          //       color: Colors.grey,
          //       child: const Center(child: Icon(Icons.error)),
          //     );
          //   },
          // ),
          // ),

          // Konten utama dengan RefreshIndicator
          RefreshIndicator(
            onRefresh: () async {
              final user = await ref.read(currentUserProvider).value;
              ref.invalidate(homeTimelineProvider);
              ref.invalidate(favouritedTimelineProvider);
              ref.invalidate(bookmarkedTimelineProvider);
              if (user != null) {
                ref.invalidate(statusesTimelineProvider(user['id']));
              }
              ref.invalidate(postStateProvider);
            },
            child: timeline.when(
              loading: () => const Center(child: CircularProgressIndicator()),

              error: (e, _) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text("Error $e"),
                    ],
                  ),
                );
              },
              data: (posts) {
                if (posts.isEmpty) {
                  return const Center(child: Text('No posts available'));
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: posts.length,
                  itemBuilder: (context, i) {
                    final post = posts[i];
                    final isReblog = post['reblog'] != null;
                    final displayPost = isReblog ? post['reblog'] : post;
                    final displayAccount = isReblog
                        ? post['reblog']['account']
                        : post['account'];
                    final createdAt = displayPost['created_at'];
                    final timeAgo = createdAt != null
                        ? timeago.format(DateTime.parse(createdAt))
                        : '';
                    return PostCard(
                      post: displayPost,
                      account: displayAccount,
                      timeAgo: timeAgo,
                      isReblog: isReblog,
                      rebloggedBy: isReblog ? post['account'] : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(255, 117, 31, 1),
        onPressed: () => context.go(Routes.addPost),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
