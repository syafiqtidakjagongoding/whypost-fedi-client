import 'package:flutter/cupertino.dart';
import 'package:mobileapp/api/post_api.dart';
import 'package:mobileapp/state/comment.dart';
import 'package:mobileapp/sharedpreferences/credentials.dart';
import 'package:mobileapp/state/timeline.dart';
import 'package:mobileapp/ui/posts/post_media.dart';
import 'package:mobileapp/ui/utils/ContentParsing.dart';
import 'package:mobileapp/ui/utils/commentList.dart';
import 'package:mobileapp/ui/utils/displayNameWithEmoji.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/action.dart';
import 'package:mobileapp/state/globalpost.dart';
import 'package:mobileapp/ui/utils/FediverseImage.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:mobileapp/ui/utils/ActionButton.dart';

class ViewpostScreen extends ConsumerStatefulWidget {
  final String postId;

  const ViewpostScreen({super.key, required this.postId});

  @override
  ConsumerState<ViewpostScreen> createState() => _ViewpostScreenState();
}

class _ViewpostScreenState extends ConsumerState<ViewpostScreen> {
  String? currentUserId;
  Map<String, dynamic>? post;
  Map<String, dynamic>? account;
  List<Widget> buildPostMenu(bool isUserPost, bool isBookmarked) {
    final menu = <Widget>[];

    if (isUserPost) {
      menu.add(
        ListTile(
          leading: const Icon(Icons.edit, color: Colors.blue),
          title: const Text('Edit Postingan'),
          onTap: () {},
        ),
      );
      menu.add(
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text('Hapus Postingan'),
          onTap: () {},
        ),
      );

      menu.add(const Divider());
    }

    menu.add(
      ListTile(
        leading: Icon(
          isBookmarked ? CupertinoIcons.bookmark_fill : CupertinoIcons.bookmark,
          color: Colors.deepPurple,
        ),
        title: Text(isBookmarked ? 'UnBookmark' : 'Bookmark Post'),
        onTap: () async {
          Map<String, dynamic> result;
          if (isBookmarked) {
            result = await ref.read(
              unbookmarkPostActionProvider(widget.postId).future,
            );
          } else {
            result = await ref.read(
              bookmarkPostActionProvider(widget.postId).future,
            );
          }
          ref.read(bookmarkProvider.notifier).update((state) {
            return {...state, widget.postId: result['bookmarked']};
          });
          ref.invalidate(bookmarkedTimelineProvider);
        },
      ),
    );
    return menu;
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final cred = await CredentialsRepository.loadAllCredentials();
    if (cred.accToken != null && cred.instanceUrl != null) {
      final result = await fetchStatusDetail(
        cred.instanceUrl!,
        cred.accToken!,
        widget.postId,
      );
      setState(() {
        currentUserId = cred.currentUserId;
        post = result;
        account = result['account'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (post == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final media = post!['media_attachments'] as List<dynamic>? ?? [];
    final bookmarks = ref.watch(bookmarkProvider);
    final favourite = ref.watch(favouriteProvider);
    final isFavourite = favourite[widget.postId] ?? false;
    final isBookmarked = bookmarks[widget.postId] ?? false;
    final isReblog = post!['reblog'] != null;
    final displayPost = isReblog ? post!['reblog'] : post;
    final createdAt = displayPost['created_at'];
    final timeAgo = createdAt != null
        ? timeago.format(DateTime.parse(createdAt))
        : '';
    // Initialize favouriteProvider jika belum ada
    if (!favourite.containsKey(widget.postId)) {
      Future.microtask(() {
        ref
            .read(favouriteProvider.notifier)
            .update(
              (state) => {
                ...state,
                widget.postId: post!['favourited'] ?? false,
              },
            );
      });
    }
    if (!bookmarks.containsKey(widget.postId)) {
      Future.microtask(() {
        ref
            .read(bookmarkProvider.notifier)
            .update(
              (state) => {
                ...state,
                widget.postId: post!['bookmarked'] ?? false,
              },
            );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Post from ${account!['username']}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromRGBO(255, 117, 31, 1),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧍 Header Post (Profile + Username + Waktu)
              InkWell(
                onTap: () {
                  context.push(Routes.profile, extra: account!['id']);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(account!['avatar_static']),
                      radius: 22,
                      backgroundColor: Colors.grey[200],
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              displayNameWithEmoji(account!),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "@${account!['acct']}",
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: buildPostMenu(
                                            account!['id'].toString() ==
                                                currentUserId.toString(),
                                            isBookmarked,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(
                                    4.0,
                                  ), // kecilin area sentuh
                                  child: Icon(
                                    Icons.more_vert,
                                    size:
                                        18, // kecilin biar proporsional dengan teks
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            timeAgo,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Contentparsing(
                  mentions: post!['mentions'],
                  content: post!['content'],
                  emojis: post!['emojis'],
                ),
              ),

              const SizedBox(height: 8),

              if (media.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: PostMedia(
                    media: media,
                    sensitive: post!['sensitive'] ?? false,
                  ),
                ),

              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ActionButton(icon: CupertinoIcons.reply, onTap: () {}),
                  ActionButton(
                    icon: post!['reblogged']
                        ? CupertinoIcons.repeat_1
                        : CupertinoIcons.repeat,
                    onTap: () {},
                    color: Colors.grey,
                  ),
                  ActionButton(
                    icon: isFavourite
                        ? CupertinoIcons.star_slash_fill
                        : CupertinoIcons.star_slash,
                    onTap: () async {
                      // Optimistic update

                      try {
                        final postId = widget.postId;

                        Map<String, dynamic> result;

                        if (isFavourite) {
                          // UNFAV
                          result = await ref.read(
                            unfavoritePostActionProvider(postId).future,
                          );
                        } else {
                          // FAV
                          result = await ref.read(
                            favoritePostActionProvider(postId).future,
                          );
                        }

                        // Update favouriteProvider dari hasil API
                        ref.read(favouriteProvider.notifier).update((state) {
                          return {
                            ...state,
                            postId:
                                result['favourited'], // <- TRUE / FALSE dari server
                          };
                        });
                        ref.invalidate(favouritedTimelineProvider);
                      } catch (e) {
                        // rollback
                        print(e);
                      }
                    },
                  ),
                  ActionButton(
                    icon: Icons.share,
                    onTap: () async {
                      // ignore: deprecated_member_use
                      await SharePlus.instance.share(
                        ShareParams(text: post!['url']),
                      );
                    },
                  ),
                ],
              ),

              const Divider(
                color: Colors.black45,
                thickness: 1.5,
                indent: 10,
                endIndent: 10,
              ),

              // 🗨️ Contoh Komentar (bisa diganti ListView.builder)
              CommentListWidget(statusId: widget.postId),
            ],
          ),
        ),
      ),
    );
  }
}
