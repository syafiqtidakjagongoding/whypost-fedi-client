import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/api/user_api.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/credentials.dart';
import 'package:mobileapp/state/relationship.dart';
import 'package:mobileapp/state/timeline.dart';
import 'package:mobileapp/ui/posts/post_card.dart';
import 'package:mobileapp/ui/profile/widgets/user_info.dart';
import 'package:mobileapp/ui/utils/ActionButton.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mobileapp/state/user.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? identifier;
  ProfileScreen({super.key, this.identifier});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? currentUserId;
  bool? isFollowing;
  bool? isRequested;
  @override
  void initState() {
    super.initState();
    loaded();
  }

  Future<void> loaded() async {
    final userId = await CredentialsRepository.getCurrentUserId();
    final rel = await ref.read(relationshipProvider(widget.identifier!).future);

    setState(() {
      currentUserId = userId;
      isFollowing = rel?['following'];
      isRequested = rel?['requested'];
    });
    print("current $currentUserId");
  }

  String formatNumber(int number) {
    if (number >= 1000000000) {
      return "${(number / 1000000000).toStringAsFixed(1)}B";
    } else if (number >= 1000000) {
      return "${(number / 1000000).toStringAsFixed(1)}M";
    } else if (number >= 1000) {
      return "${(number / 1000).toStringAsFixed(1)}k";
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(selectedUserProvider(widget.identifier!));

    return Scaffold(
      body: userAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (user) {
          final userId = user!['id'];
          // Watch timeline AFTER user successfully loaded
          final statusesAsync = ref.watch(statusesTimelineProvider(userId));
          final favouritedAsync = widget.identifier == currentUserId
              ? ref.watch(favouritedTimelineProvider)
              : AsyncValue.data([]);
          final bookmarkedAsync = widget.identifier == currentUserId
              ? ref.watch(bookmarkedTimelineProvider)
              : AsyncValue.data([]);
          final statusesOnlyMediaAsync = ref.watch(
            statusesOnlyMediaTimelineProvider(userId),
          );

          return DefaultTabController(
            length: widget.identifier == currentUserId ? 4 : 3,
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(selectedUserProvider(widget.identifier!));
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
                                if (widget.identifier != null)
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
                                            displayTitleWithEmoji(user),
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
                                                  "Followers ${formatNumber(user['followers_count'])}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Followings ${formatNumber(user['following_count'])}",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (widget.identifier !=
                                                currentUserId)
                                              ElevatedButton(
                                              onPressed: () async {
                                                  if (isFollowing == true) {
                                                    // Unfollow
                                                    try {
                                                      final res = await ref.read(
                                                        unfollowUserProvider(
                                                          widget.identifier!,
                                                        ).future,
                                                      );
                                                      print(res);
                                                      setState(() {
                                                       isFollowing =
                                                            res?['following'] ??
                                                            false;
                                                        isRequested =
                                                            res?['requested'] ??
                                                            false;
                                                      });
                                                    } catch (e) {
                                                      print(
                                                        "Failed to unfollow: $e",
                                                      );
                                                    }
                                                  } else {
                                                    // Follow
                                                    try {
                                                      final res = await ref
                                                          .read(
                                                            followUserProvider(
                                                              widget
                                                                  .identifier!,
                                                            ).future,
                                                          );
                                                      print(res);
                                                      setState(() {
                                                        isFollowing =
                                                            res?['following'] ??
                                                            false;
                                                        isRequested =
                                                            res?['requested'] ??
                                                            false;
                                                      });
                                                    } catch (e) {
                                                      print(
                                                        "Failed to follow: $e",
                                                      );
                                                    }
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      isFollowing == true
                                                      ? Colors.green
                                                      : isRequested == true
                                                      ? Colors.orange
                                                      : Colors.blue,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 5,
                                                      ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ), // tidak terlalu bulat
                                                  ),
                                                  elevation: 0, // biar clean
                                                ),
                                                child: Text(
                                                  isFollowing == true
                                                      ? "Followed"
                                                      : isRequested == true
                                                      ? "Requested"
                                                      : "Follow",
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
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
                            indicatorColor: Color.fromRGBO(255, 117, 31, 1),
                            labelColor: Color.fromRGBO(255, 117, 31, 1),
                            unselectedLabelColor: Colors.grey,
                            tabs: [
                              Tab(text: "Statuses"),
                              Tab(
                                text: widget.identifier == currentUserId
                                    ? "Favourites"
                                    : "Media",
                              ),
                              Tab(
                                text: widget.identifier == currentUserId
                                    ? "Saved"
                                    : "About",
                              ),
                              if (widget.identifier == currentUserId)
                                Tab(text: "About"),
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
                    if (widget.identifier == currentUserId)
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

                    if (widget.identifier != currentUserId)
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
                    if (widget.identifier == currentUserId)
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

                    if (widget.identifier != currentUserId)
                      userAsync.when(
                        data: (user) {
                          if (user!.isEmpty) {
                            return Text("User error");
                          }
                          return UserInfoTextCard(account: user);
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text("Error: $e")),
                      ),

                    if (widget.identifier == currentUserId)
                      userAsync.when(
                        data: (user) {
                          if (user!.isEmpty) {
                            return Text("User error");
                          }
                          return UserInfoTextCard(account: user);
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
        backgroundColor: Color.fromRGBO(255, 117, 31, 1),
        onPressed: () => context.go(Routes.addPost),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

Widget displayTitleWithEmoji(Map<String, dynamic> account) {
  final displayName = account['display_name'] == ""
      ? account['username']
      : account['display_name'];
  final emojis = account['emojis'] as List<dynamic>? ?? [];

  final regex = RegExp(r':([a-zA-Z0-9_]+):');

  List<InlineSpan> children = [];

  displayName.splitMapJoin(
    regex,
    onMatch: (m) {
      final shortcode = m.group(1);

      final emoji = emojis.firstWhere(
        (e) => e['shortcode'] == shortcode,
        orElse: () => null,
      );

      if (emoji != null) {
        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Image.network(emoji['url'], width: 20, height: 20),
          ),
        );
      } else {
        children.add(
          TextSpan(text: m.group(0)),
        ); // kalau nggak ketemu shortcode
      }

      return ''; // return value tidak dipakai
    },
    onNonMatch: (text) {
      children.add(TextSpan(text: text));
      return '';
    },
  );

  return RichText(
    maxLines: 1,
    text: TextSpan(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      children: children,
    ),
  );
}
