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

    ref.listen(currentUserProvider, (previous, next) {
      next.whenData((user) async {
        if (user != null) {
          await CredentialsRepository.setCurrentUserId(user['id']);
        }
      });
    });
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
              title: const Text("Profile"),
              onTap: () {
                context.push(Routes.profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Algorithm"),
              onTap: () {
                context.push(Routes.algorithm);
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
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    // TAMBAHKAN INI - Invalidate semua provider terkait
                    final cred =
                        await CredentialsRepository.loadAllCredentials();
                    await CredentialsRepository.clearAll();
                    ref.invalidate(homeTimelineProvider);
                    ref.invalidate(currentUserProvider);
                    ref.invalidate(selectedUserProvider(cred.currentUserId!));
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

      body: RefreshIndicator(
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
            // Return widget untuk ditampilkan sementara
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

                // Check apakah post ini reblog
                final isReblog = post['reblog'] != null;

                // Jika reblog, ambil konten post asli
                final displayPost = isReblog
                    ? post['reblog'] as Map<String, dynamic>
                    : post;

                // Akun yang menampilkan post ini
                final displayAccount = isReblog
                    ? post['reblog']['account']
                    : post['account'];

                final createdAt = displayPost['created_at'];
                final timeAgo = createdAt != null
                    ? timeago.format(DateTime.parse(createdAt))
                    : '';

                return PostCard(
                  post: displayPost, // konten asli jika reblog
                  account: displayAccount, // user yang me-reblog / posting asli
                  timeAgo: timeAgo,
                  isReblog: isReblog, // optional flag
                  rebloggedBy: isReblog
                      ? post['account']
                      : null, // user yang me-reblog
                );
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(Routes.addPost);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
