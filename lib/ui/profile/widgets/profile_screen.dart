import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/api/user_api.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/ui/widgets/post_card.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mobileapp/state/post.dart';
import 'package:mobileapp/state/user.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? id;
  ProfileScreen({super.key, this.id});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      body: userAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (user) {
          final userId = user!['id'];

          // Watch timeline AFTER user successfully loaded
          final statusesAsync = ref.watch(statusesTimelineProvider(userId));
          final favouritedAsync = ref.watch(favouritedTimelineProvider);
          final bookmarkedAsync = ref.watch(bookmarkedTimelineProvider);
          return DefaultTabController(
            length: 3,
            child: RefreshIndicator(
              onRefresh: () async {
                // invalidate semua provider timeline
                ref.invalidate(statusesTimelineProvider);
                ref.invalidate(favouritedTimelineProvider);
                ref.invalidate(bookmarkedTimelineProvider);
              },

              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          // ===== HEADER =====
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 200,
                                  child: Image.network(
                                    user['header'],
                                    fit: BoxFit.cover,
                                  ),
                                ),

                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.black.withOpacity(0.25),
                                ),

                                Positioned(
                                  bottom: 10,
                                  left: 16,
                                  right: 16,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 38,
                                          backgroundImage: NetworkImage(
                                            user['avatar_static'] ?? "",
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              user['username'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w800,
                                              ),
                                              maxLines: 1,
                                            ),
                                            const SizedBox(height: 4),
                                            GestureDetector(
                                              onTap: () async {
                                                await launchUrl(
                                                  Uri.parse(user['url']),
                                                  mode: LaunchMode
                                                      .externalApplication,
                                                );
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      "@${user['acct']}",
                                                      style: TextStyle(
                                                        color: Colors.grey[200],
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(
                                                    Icons.open_in_new,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ===== TAB BAR =====
                          TabBar(
                            indicatorColor: Colors.black,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey,
                            tabs: const [
                              Tab(text: "Your posts"),
                              Tab(text: "Likes"),
                              Tab(text: "Saved post"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ];
                },

                // ===== TAB VIEW =====
                body: TabBarView(
                  children: [
                    // ==== TAB 1: STATUS ====
                    statusesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text("Error: $e")),
                      data: (posts) {
                        if (posts.isEmpty) {
                          return const Center(child: Text("No posts yet"));
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: posts.length,
                          itemBuilder: (context, i) {
                            final post = posts[i];
                            final account = post['account'];
                            final createdAt = post['created_at'];
                            final timeAgo = createdAt != null
                                ? timeago.format(DateTime.parse(createdAt))
                                : '';
                            return PostCard(
                              post: post,
                              account: account,
                              timeAgo: timeAgo,
                            );
                          },
                        );
                      },
                    ),

                    // ==== TAB 2: FAVOURITES ====
                    favouritedAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text("Error: $e")),
                      data: (posts) {
                        if (posts.isEmpty) {
                          return const Center(
                            child: Text("No liked posts yet"),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: posts.length,
                          itemBuilder: (context, i) {
                            final post = posts[i];
                            final account = post['account'];
                            final createdAt = post['created_at'];
                            final timeAgo = createdAt != null
                                ? timeago.format(DateTime.parse(createdAt))
                                : '';
                            return PostCard(
                              post: post,
                              account: account,
                              timeAgo: timeAgo,
                            );
                          },
                        );
                      },
                    ),

                    // ==== TAB 3: BOOKMARKS ====
                    bookmarkedAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text("Error: $e")),
                      data: (posts) {
                        if (posts.isEmpty) {
                          return const Center(
                            child: Text("No bookmarked posts yet"),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: posts.length,
                          itemBuilder: (context, i) {
                            final post = posts[i];
                            final account = post['account'];
                            final createdAt = post['created_at'];
                            final timeAgo = createdAt != null
                                ? timeago.format(DateTime.parse(createdAt))
                                : '';
                            return PostCard(
                              post: post,
                              account: account,
                              timeAgo: timeAgo,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(Routes.addPost),
        child: Icon(Icons.add),
      ),
    );
  }
}
