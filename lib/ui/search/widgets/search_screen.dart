import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/explore.dart';
import 'package:mobileapp/state/timeline.dart';
import 'package:mobileapp/state/trends.dart';
import 'package:mobileapp/state/user.dart';
import 'package:mobileapp/ui/profile/widgets/profile_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = ref.watch(trendingTagsProvider);
    final links = ref.watch(trendingLinksProvider);
    final people = ref.watch(suggestedPeopleProvider);
    final results = ref.watch(searchResultsProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Search Input Paling Atas
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                onChanged: (value) {
                  ref.read(searchQueryProvider.notifier).state = value;
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

            // 🔽 Tabs Di Bawah Input
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.orange,
              labelColor: Colors.orange,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: "Search"),
                Tab(text: "Hashtags"),
                Tab(text: "Link"),
                Tab(text: "People"),
              ],
            ),

            // Konten Untuk Setiap Tab
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  results.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text("Error: $e")),
                    data: (data) {
                      final accounts = (data["accounts"] is List)
                          ? data["accounts"]
                          : <dynamic>[];
                      final statuses = (data["statuses"] is List)
                          ? data["statuses"]
                          : <dynamic>[];
                      final tags = (data["hashtags"] is List)
                          ? data["hashtags"]
                          : <dynamic>[];

                      if (accounts.isEmpty &&
                          statuses.isEmpty &&
                          tags.isEmpty) {
                        return const Center(child: Text("No results"));
                      }

                      return ListView(
                        children: [
                          if (accounts.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "People",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ...accounts.map(
                            (u) => ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(
                                  u["avatar_static"],
                                ),
                              ),
                              title: Text(u["display_name"] ?? u["username"]),
                              subtitle: Text("@${u["acct"]}"),
                            ),
                          ),

                          if (tags.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "Hashtags",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ...tags.map(
                            (t) => ListTile(
                              title: Text("#${t["name"]}"),
                              subtitle: Text(
                                "${t["history"][0]["uses"]} posts",
                              ),
                            ),
                          ),

                          if (statuses.isNotEmpty)
                            const Padding(
                              padding: EdgeInsets.all(12),
                              child: Text(
                                "Posts",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ...statuses.map(
                            (s) => ListTile(
                              title: Text(s["content"]),
                              subtitle: Text("@${s["account"]["acct"]}"),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  tags.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text("Error: $e")),
                    data: (list) => ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final hashtag = list[i];
                        return ListTile(
                          title: Text("#${hashtag['name']}"),
                          subtitle: Text(
                            "${hashtag['history']?.length ?? 0} days trending",
                          ),
                          onTap: () {
                            final tag = hashtag['name'];

                            context.push(
                              "/tags/$tag", // kalau pakai GoRouter
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // ==============
                  // 3. TRENDING LINKS
                  // ==============
                  links.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text("Error: $e")),
                    data: (list) => ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final link = list[i];
                        final url = link["url"];

                        return ListTile(
                          title: Text(link["title"] ?? "Untitled"),
                          subtitle: Text(url),
                          leading: const Icon(Icons.link),

                          onTap: () async {
                            final uri = Uri.parse(url);

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

                  // ==============
                  // 4. SUGGESTED PEOPLE
                  // ==============
                  people.when(
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
                            ref.invalidate(currentUserProvider);
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
                                                fontSize: 15,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              "@$username",
                                              style: const TextStyle(
                                                fontSize: 10,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
