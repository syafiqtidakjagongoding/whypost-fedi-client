import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mobileapp/state/credentials.dart';
import 'package:mobileapp/state/explore.dart';
import 'package:mobileapp/state/timeline.dart';
import 'package:mobileapp/state/trends.dart';
import 'package:mobileapp/state/user.dart';
import 'package:mobileapp/ui/posts/post_card.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scroll = ScrollController();

  // Infinite scroll state
  List<dynamic> infiniteStatuses = [];
  String? nextMaxId;
  bool isLoadingMore = false;
  bool hasNextPage = true;

  String lastQuery = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Scroll listener untuk infinite scroll
    _scroll.addListener(() {
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        loadMoreStatuses();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Fetch more statuses (API pagination)
  Future<void> loadMoreStatuses() async {
    if (isLoadingMore || !hasNextPage || lastQuery.isEmpty) return;

    setState(() => isLoadingMore = true);

    final cred = await CredentialsRepository.loadCredentials();

    final url = Uri.parse(
      "${cred.instanceUrl}/api/v2/search"
      "?q=$lastQuery&type=statuses&limit=10"
      "${nextMaxId != null ? "&max_id=$nextMaxId" : ""}",
    );

    final res = await http.get(
      url,
      headers: {"Authorization": "Bearer ${cred.accToken}"},
    );

    final data = jsonDecode(res.body);
    final List list = data["statuses"] ?? [];

    if (list.isEmpty) {
      hasNextPage = false;
    } else {
      nextMaxId = list.last["id"];
      infiniteStatuses.addAll(list);
    }

    setState(() => isLoadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final trendingTags = ref.watch(trendingTagsProvider);
    final trendingLinks = ref.watch(trendingLinksProvider);
    final suggested = ref.watch(suggestedPeopleProvider);
    final trendingPost = ref.watch(trendingPostTimelineProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                onChanged: (value) {
                  final timer = ref.read(searchDebounceProvider);
                  timer?.cancel();

                  ref.read(searchDebounceProvider.notifier).state = Timer(
                    const Duration(milliseconds: 500),
                    () {
                      ref.read(searchQueryProvider.notifier).state = value;
                    },
                  );
                },
                decoration: InputDecoration(
                  hintText: "Search instance / users / tags...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // TAB
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.orange,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "All"),
                Tab(text: "Posts"),
                Tab(text: "Tags"),
                Tab(text: "People"),
                Tab(text: "Link"),
              ],
            ),

            // CONTENT
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // =======================
                  // 1) SEARCH TAB
                  // =======================
                  results.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text("Error: $e")),
                    data: (data) {
                      final accounts = (data["accounts"] is List)
                          ? data["accounts"]
                          : <dynamic>[];

                      final firstStatuses = (data["statuses"] is List)
                          ? data["statuses"]
                          : <dynamic>[];

                      final tags = (data["hashtags"] is List)
                          ? data["hashtags"]
                          : <dynamic>[];

                      final query = ref.watch(searchQueryProvider).trim();

                      if (query != lastQuery) {
                        // RESET pagination
                        lastQuery = query;
                        infiniteStatuses = List.of(firstStatuses);
                        nextMaxId = firstStatuses.isNotEmpty
                            ? firstStatuses.last["id"]
                            : null;
                        hasNextPage = true;
                      }

                      return SingleChildScrollView(
                        controller: _scroll,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (tags.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  "Tags",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ...tags.map((t) {
                              final history =
                                  t['history'] as List<dynamic>? ?? [];
                              final totalUses = history.fold<int>(
                                0,
                                (sum, item) =>
                                    sum +
                                    int.tryParse(
                                      item['uses']?.toString() ?? '0',
                                    )!,
                              );
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                title: Text("#${t['name']}"),
                                subtitle: Text("$totalUses posts"),
                                onTap: () {
                                  context.push(
                                    "/tags/${t['name']}",
                                  ); // GoRouter
                                },
                              );
                            }),

                            // PEOPLE
                            if (accounts.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  "People",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ...accounts.map((u) {
                              final avatar = u["avatar_static"] ?? "";
                              final displayName =
                                  u["display_name"] ?? "Unknown";
                              final username = u["acct"] ?? "";
                              final id = u['id'];

                              return InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  ref.invalidate(currentUserProvider);
                                  ref.invalidate(selectedUserProvider(id));
                                  context.push(Routes.profile, extra: id);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: avatar.isNotEmpty
                                            ? NetworkImage(avatar)
                                            : null,
                                        child: avatar.isEmpty
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),

                                      const SizedBox(width: 12),

                                      // INFO
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    displayName,
                                                    style: const TextStyle(
                                                      fontSize: 17,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Flexible(
                                                  child: Text(
                                                    "@$username",
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Colors.grey,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    softWrap: false,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 4),

                                            // Search API tidak selalu mengirim followers_count
                                            if (u["followers_count"] != null)
                                              Text(
                                                "${u["followers_count"]} followers",
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(width: 12),

                                      SizedBox(
                                        height: 32,
                                        child: OutlinedButton(
                                          onPressed: () {},
                                          child: const Text(
                                            "Follow",
                                            style: TextStyle(fontSize: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),

                            // TAGS

                            // POSTS (INFINITE)
                            if (infiniteStatuses.isNotEmpty)
                              const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  "Posts",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),

                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: infiniteStatuses.length + 1,
                              itemBuilder: (context, i) {
                                if (i == infiniteStatuses.length) {
                                  return SizedBox.shrink();
                                }

                                final post = infiniteStatuses[i];
                                final isReblog = post['reblog'] != null;
                                final displayPost = isReblog
                                    ? post['reblog']
                                    : post;
                                final account = post['account'];
                                final createdAt =
                                    displayPost['created_at'] ?? "";
                                final timeAgo = createdAt.isNotEmpty
                                    ? timeago.format(DateTime.parse(createdAt))
                                    : "";

                                return PostCard(
                                  post: displayPost,
                                  account: account,
                                  timeAgo: timeAgo,
                                  isReblog: isReblog,
                                  rebloggedBy: isReblog
                                      ? post['account']
                                      : null,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  ListView(
                    children: [
                      if (lastQuery.isNotEmpty)
                        results.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, st) => Center(child: Text("Error: $e")),
                          data: (data) {
                            final firstStatuses = (data["statuses"] is List)
                                ? data["statuses"]
                                : <dynamic>[];

                            final query = ref.watch(searchQueryProvider).trim();

                            if (query != lastQuery) {
                              lastQuery = query;
                              infiniteStatuses = List.of(firstStatuses);
                              nextMaxId = firstStatuses.isNotEmpty
                                  ? firstStatuses.last["id"]
                                  : null;
                              hasNextPage = true;
                            }

                            if (infiniteStatuses.isEmpty) {
                              return const Center(child: Text("No results"));
                            }

                            return Column(
                              children: [
                                ...infiniteStatuses.map((post) {
                                  final isReblog = post['reblog'] != null;
                                  final displayPost = isReblog
                                      ? post['reblog']
                                      : post;

                                  final createdAt =
                                      displayPost['created_at'] ?? "";
                                  final timeAgo = createdAt.isNotEmpty
                                      ? timeago.format(
                                          DateTime.parse(createdAt),
                                        )
                                      : "";

                                  return PostCard(
                                    post: displayPost,
                                    account: post['account'],
                                    timeAgo: timeAgo,
                                    isReblog: isReblog,
                                    rebloggedBy: isReblog
                                        ? post['account']
                                        : null,
                                  );
                                }),
                              ],
                            );
                          },
                        ),

                      if (lastQuery.isEmpty)
                        trendingPost.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, st) => Center(child: Text("Error: $e")),
                          data: (posts) {
                            return Column(
                              children: [
                                ...posts.map((post) {
                                  final isReblog = post['reblog'] != null;
                                  final displayPost = isReblog
                                      ? post['reblog']
                                      : post;

                                  final createdAt =
                                      displayPost['created_at'] ?? "";
                                  final timeAgo = createdAt.isNotEmpty
                                      ? timeago.format(
                                          DateTime.parse(createdAt),
                                        )
                                      : "";

                                  return PostCard(
                                    post: displayPost,
                                    account: post['account'],
                                    timeAgo: timeAgo,
                                    isReblog: isReblog,
                                    rebloggedBy: isReblog
                                        ? post['account']
                                        : null,
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                    ],
                  ),

                  if (lastQuery.isEmpty)
                    trendingTags.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),

                      error: (e, st) => Center(child: Text("Error: $e")),

                      data: (list) {
                        return ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, i) {
                            final tag = list[i];
                            final name = tag['name'] ?? '';
                            final history = tag['history'] as List? ?? [];

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              title: Text("#$name"),
                              subtitle: Text("${history.length} days trending"),
                              onTap: () {
                                context.push("/tags/$name"); // GoRouter
                              },
                            );
                          },
                        );
                      },
                    ),

                  if (lastQuery.isNotEmpty)
                    results.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text("Error: $e")),
                      data: (data) {
                        final tags = (data["hashtags"] is List)
                            ? data["hashtags"]
                            : <dynamic>[];

                        if (tags.isEmpty) {
                          return const Center(child: Text("No hashtags found"));
                        }

                        return ListView.builder(
                          itemCount: tags.length,
                          itemBuilder: (_, i) {
                            final t = tags[i];
                            final history =
                                t['history'] as List<dynamic>? ?? [];
                            final totalUses = history.fold<int>(
                              0,
                              (sum, item) =>
                                  sum +
                                  int.tryParse(
                                    item['uses']?.toString() ?? '0',
                                  )!,
                            );
                            return ListTile(
                              title: Text("#${t['name']}"),
                              subtitle: Text("$totalUses uses"),
                              onTap: () {
                                context.push("/tags/${t['name']}");
                              },
                            );
                          },
                        );
                      },
                    ),

                  if (lastQuery.isEmpty)
                    suggested.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text("Error: $e")),
                      data: (list) => ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final item = list[i];

                          final avatar = item["avatar_static"] ?? "";
                          final displayName = item["display_name"] ?? "Unknown";
                          final username = item["acct"] ?? "";
                          final followers = item["followers_count"] ?? 0;
                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              ref.invalidate(selectedUserProvider(item['id']));

                              final id = item['id'];
                              context.push(Routes.profile, extra: id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundImage: avatar.isNotEmpty
                                        ? NetworkImage(avatar)
                                        : null,
                                    child: avatar.isEmpty
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),

                                  const SizedBox(width: 12),

                                  // INFO
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                displayName,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Flexible(
                                              child: Text(
                                                "@$username",
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.grey,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                softWrap: false,
                                              ),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          "$followers followers",
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 12),

                                  // FOLLOW BUTTON
                                  SizedBox(
                                    height: 32,
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      child: const Text(
                                        "Follow",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  if (lastQuery.isNotEmpty)
                    results.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text("Error: $e")),
                      data: (data) {
                        final accounts = (data["accounts"] is List)
                            ? data["accounts"]
                            : <dynamic>[];

                        return ListView.builder(
                          itemCount: accounts.length,
                          itemBuilder: (_, i) {
                            final u = accounts[i];
                            final avatar = u["avatar_static"] ?? "";
                            final displayName = u["display_name"] ?? "Unknown";
                            final username = u["acct"] ?? "";
                            final id = u['id'];

                            return InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                ref.invalidate(selectedUserProvider(id));
                                context.push(Routes.profile, extra: id);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: avatar.isNotEmpty
                                          ? NetworkImage(avatar)
                                          : null,
                                      child: avatar.isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  displayName,
                                                  style: const TextStyle(
                                                    fontSize: 17,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Flexible(
                                                child: Text(
                                                  "@$username",
                                                  style: const TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  softWrap: false,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),

                                          if (u["followers_count"] != null)
                                            Text(
                                              "${u["followers_count"]} followers",
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      height: 32,
                                      child: OutlinedButton(
                                        onPressed: () {},
                                        child: const Text(
                                          "Follow",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                  trendingLinks.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text("Error: $e")),
                    data: (list) => ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final link = list[i];
                        return ListTile(
                          title: Text(link["title"] ?? "Untitled"),
                          subtitle: Text(link["url"]),
                          leading: const Icon(Icons.link),
                          onTap: () async {
                            final uri = Uri.parse(link["url"]);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
