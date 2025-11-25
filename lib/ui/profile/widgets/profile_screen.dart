import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/api/user_api.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/credentials.dart';
import 'package:mobileapp/state/timeline.dart';
import 'package:mobileapp/ui/widgets/post_card.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mobileapp/state/user.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? id;
  ProfileScreen({super.key, this.id});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    loadCred();
  }

  Future<void> loadCred() async {
    setState(() {}); // supaya build dipanggil ulang
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = widget.id == null
        ? ref.watch(currentUserProvider)
        : ref.watch(selectedUserProvider(widget.id!));

    return Scaffold(
      body: userAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (user) {
          final userId = user!['id'];
          // Watch timeline AFTER user successfully loaded
          final statusesAsync = ref.watch(statusesTimelineProvider(userId));
          final favouritedAsync = widget.id == null
              ? ref.watch(favouritedTimelineProvider)
              : AsyncValue.data([]);
          final bookmarkedAsync = widget.id == null
              ? ref.watch(bookmarkedTimelineProvider)
              : AsyncValue.data([]);
          final statusesOnlyMediaAsync = ref.watch(
            statusesOnlyMediaTimelineProvider(userId),
          );
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
                                    errorBuilder: (_, __, ___) {
                                      return Container(color: Colors.grey[900]);
                                    },
                                  ),
                                ),

                                // FULL BLACK GRADIENT OVERLAY
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(1),
                                      ],
                                    ),
                                  ),
                                ),
                                if (widget.id != null)
                                  Positioned(
                                    top: 16,
                                    left: 16,
                                    child: Container(
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                        ),
                                        onPressed: () => context.pop(),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 10,
                                  left: 16,
                                  right: 16,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                              user['display_name'] == ""
                                                  ? user['username']
                                                  : user['display_name'],
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
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              children: [
                                                Text(
                                                  "Followers ${user['followers_count']}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Followings ${user['following_count']}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
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

                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(1),
                                  Colors.black.withOpacity(0.9),
                                ],
                              ),
                            ),
                            child: Column(
                              children: [
                                Html(
                                  data: user['note'],
                                  onLinkTap: (url, attributes, element) {
                                    final uri = Uri.parse(
                                      url!.startsWith('http')
                                          ? url
                                          : 'https://$url',
                                    );
                                    launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                  style: {
                                    "body": Style(
                                      color: Colors.white,
                                      fontSize: FontSize(15),
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                      lineHeight: LineHeight(1.5),
                                    ),
                                    "p": Style(
                                      margin: Margins.only(bottom: 8),
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    "b": Style(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    "i": Style(fontStyle: FontStyle.italic),
                                    "span": Style(
                                      fontSize: FontSize(15),
                                      color: Colors.white,
                                    ),
                                    "a": Style(
                                      color: Color.fromRGBO(255, 117, 31, 1),
                                      textDecoration: TextDecoration.none,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  },
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final isFollowing =
                                        user['following'] as bool;

                                    final credential =
                                        await CredentialsRepository.loadCredentials();
                                    if (credential.accToken == null ||
                                        credential.instanceUrl == null) {
                                      context.go(Routes.instance);
                                      return;
                                    }
                                    if (isFollowing) {
                                      // Unfollow API call
                                      await unfollowUser(
                                        instanceUrl: credential.instanceUrl!,
                                        token: credential.accToken!,
                                        userId: user['id'],
                                      );
                                    } else {
                                      // Follow API call
                                      await followUser(
                                        instanceUrl: credential.instanceUrl!,
                                        token: credential.accToken!,
                                        userId: user['id'],
                                      );
                                    }

                                    // Update local state / provider agar button rebuild
                                    setState(() {
                                      user['following'] = !isFollowing;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: user['following'] == true
                                        ? Colors.grey
                                        : Colors.blue,
                                  ),
                                  child: Text(
                                    user['following'] == true
                                        ? "Following"
                                        : "Follow",
                                    style: TextStyle(color: Colors.white),
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
                            tabs: [
                              Tab(
                                text: widget.id == null
                                    ? "Your posts"
                                    : "Posts",
                              ),
                              Tab(text: widget.id == null ? "Likes" : "Media"),
                              Tab(
                                text: widget.id == null
                                    ? "Saved post"
                                    : "About",
                              ),
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
                              account:
                                  displayAccount, // user yang me-reblog / posting asli
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

                    // ==== TAB 2: FAVOURITES ====
                    if (widget.id == null)
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
                                account:
                                    displayAccount, // user yang me-reblog / posting asli
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

                    if (widget.id != null)
                      statusesOnlyMediaAsync.when(
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
                                account:
                                    displayAccount, // user yang me-reblog / posting asli
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

                    // ==== TAB 3: BOOKMARKS ====
                    if (widget.id == null)
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

                              // Check apakah post ini reblog
                              final isReblog = post['reblog'] != null;

                              // Jika reblog, ambil konten post asli
                              final displayPost = isReblog
                                  ? post['reblog'] as Map<String, dynamic>
                                  : post;

                              // Akun yang menampilkan post ini
                              final displayAccount = isReblog
                                  ? post['account']
                                  : post['account'];

                              final createdAt = displayPost['created_at'];
                              final timeAgo = createdAt != null
                                  ? timeago.format(DateTime.parse(createdAt))
                                  : '';

                              return PostCard(
                                post: displayPost, // konten asli jika reblog
                                account:
                                    displayAccount, // user yang me-reblog / posting asli
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

                    if (widget.id != null)
                      userAsync.when(
                        data: (user) {
                          if (user!.isEmpty) {
                            return Text("User error");
                          }
                          return Text(user['acct']);
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text("Error: $e")),
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
