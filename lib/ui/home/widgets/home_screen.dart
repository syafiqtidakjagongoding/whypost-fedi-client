import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/explore.dart';
import 'package:mobileapp/state/globalpost.dart';
import 'package:mobileapp/state/timeline.dart';
import 'package:mobileapp/sharedpreferences/credentials.dart';
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
  final ScrollController _homeScrollListener = ScrollController();
  final ScrollController _trendScrollListener = ScrollController();
  final ScrollController _localScrollListener = ScrollController();
  final ScrollController _publicScrollListener = ScrollController();

  String? instanceUrl;
  @override
  void initState() {
    super.initState();

    _homeScrollListener.addListener(() {
      final notifier = ref.read(homeTimelineProvider.notifier);

      if (_homeScrollListener.position.pixels >=
          _homeScrollListener.position.maxScrollExtent - 200) {
        notifier.loadMore(); // INFINITE SCROLL TRIGGER
      }
    });
    _trendScrollListener.addListener(() {
      final notifier = ref.read(trendProvider.notifier);

      if (_trendScrollListener.position.pixels >=
          _trendScrollListener.position.maxScrollExtent - 200) {
        notifier.loadMore(); // INFINITE SCROLL TRIGGER
      }
    });
    _localScrollListener.addListener(() {
      final notifier = ref.read(publicLocalProvider.notifier);

      if (_localScrollListener.position.pixels >=
          _localScrollListener.position.maxScrollExtent - 200) {
        notifier.loadMore(); // INFINITE SCROLL TRIGGER
      }
    });
    _publicScrollListener.addListener(() {
      final notifier = ref.read(publicFederatedProvider.notifier);

      if (_publicScrollListener.position.pixels >=
          _publicScrollListener.position.maxScrollExtent - 200) {
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
    final homeTimeline = ref.watch(homeTimelineProvider);
    final localTimeline = ref.watch(publicLocalProvider);
    final trendTimeline = ref.watch(trendProvider);
    final publicTimeline = ref.watch(publicFederatedProvider);


    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [const Text('For you')],
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Color.fromRGBO(255, 117, 31, 1),
          elevation: 0.5,
          titleTextStyle: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(255, 117, 31, 1),
          ),
          iconTheme: const IconThemeData(
            color: Color.fromRGBO(255, 117, 31, 1),
          ),
          bottom: const TabBar(
            indicatorColor: Color.fromRGBO(255, 117, 31, 1),
            labelColor: Color.fromRGBO(255, 117, 31, 1),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Trends'),
              Tab(text: 'Local'),
              Tab(text: 'Public'),
            ],
          ),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 117, 31, 1),
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Menu',
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (instanceUrl != null)
                        Text(
                          instanceUrl!,
                          style: TextStyle(color: Colors.white),
                        ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                onTap: () {
                  context.push(Routes.settings);
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Konfirmasi Logout"),
                          content: const Text(
                            "Apakah kamu yakin ingin logout?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm == true) {
                      print("logout");
                      await CredentialsRepository.clearAll();
                      if (!context.mounted) return;
                      context.go(Routes.instance);
                      Future.microtask(() {
                        ref.invalidate(homeTimelineProvider);
                        ref.invalidate(currentUserProvider);
                        ref.invalidate(favouritedTimelineProvider);
                        ref.invalidate(bookmarkedTimelineProvider);
                        ref.invalidate(trendingLinksProvider);
                        ref.invalidate(trendingTagsProvider);
                        ref.invalidate(suggestedPeopleProvider);
                        ref.invalidate(publicFederatedProvider);
                        ref.invalidate(publicLocalProvider);
                        ref.invalidate(trendProvider);
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Home Tab
            _buildTimelineTab(homeTimeline),
            // Trends Tab
            _buildTrendsTab(trendTimeline),
            // Local Tab
            _buildLocalTab(localTimeline),
            // Public Tab
            _buildPublicTab(publicTimeline),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromRGBO(255, 117, 31, 1),
          onPressed: () => context.go(Routes.addPost),
          child: Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // Helper method untuk Home timeline
  Widget _buildTimelineTab(AsyncValue timeline) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(homeTimelineProvider);
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
                controller: _homeScrollListener,
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
    );
  }
@override
  void dispose() {
    _homeScrollListener.dispose();
    _localScrollListener.dispose();
    _trendScrollListener.dispose();
    _publicScrollListener.dispose();
    super.dispose();
  }

  // Placeholder untuk Trends Tab
  Widget _buildTrendsTab(AsyncValue timeline) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(trendProvider);
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
                controller: _trendScrollListener,
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
    );
  }

  // Placeholder untuk Local Tab
  Widget _buildLocalTab(AsyncValue timeline) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(publicLocalProvider);
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
                controller: _localScrollListener,
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
    );
  }

  // Placeholder untuk Public Tab
  Widget _buildPublicTab(AsyncValue timeline) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(publicFederatedProvider);
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
                controller: _publicScrollListener,
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
    );
  }
}
