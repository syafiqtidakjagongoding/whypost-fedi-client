import 'package:flutter/cupertino.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/action.dart';
import 'package:mobileapp/state/credentials.dart';
import 'package:mobileapp/state/globalpost.dart';
import 'package:mobileapp/ui/utils/ActionButton.dart';
import 'package:mobileapp/ui/utils/ContentParsing.dart';
import 'package:mobileapp/ui/utils/FediverseImage.dart';
import 'package:flutter/material.dart';
import 'package:mobileapp/ui/posts/post_media.dart';
import 'package:mobileapp/ui/utils/displayNameWithEmoji.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class PostCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> post;
  final Map<String, dynamic> account;
  final String timeAgo;
  final bool isReblog;
  final Map<String, dynamic>? rebloggedBy;

  const PostCard({
    Key? key,
    required this.post,
    required this.account,
    required this.timeAgo,
    required this.isReblog,
    required this.rebloggedBy,
  }) : super(key: key);

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  String? currentUserId;
  List<Widget> buildPostMenu(bool isUserPost, bool isBookmarked) {
    final menu = <Widget>[];

    if (isUserPost) {
      menu.add(
        ListTile(
          leading: const Icon(Icons.edit, color: Colors.blue),
          title: const Text('Edit Post'),
          onTap: () {},
        ),
      );
      menu.add(
        ListTile(
          leading: const Icon(Icons.delete, color: Colors.red),
          title: const Text('Delete Post'),
          onTap: () {},
        ),
      );

      menu.add(const Divider());
    }

    menu.add(
      ListTile(
        leading: Icon(
          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          color: Colors.deepPurple,
        ),
        title: Text(isBookmarked ? 'UnBookmark' : 'Bookmark Post'),
        onTap: () {
          if (isBookmarked) {
            ref.read(unbookmarkPostActionProvider(widget.post['id']));
          } else {
            ref.read(bookmarkPostActionProvider(widget.post['id']));
          }
        },
      ),
    );

    menu.add(
      ListTile(
        leading: const Icon(Icons.flag, color: Colors.orange),
        title: const Text('Report'),
        onTap: () {},
      ),
    );

    return menu;
  }

  @override
  void initState() {
    super.initState();
    loadCred();
  }

  Future<void> loadCred() async {
    final userId = await CredentialsRepository.getCurrentUserId();
    setState(() {
      currentUserId = userId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.post['media_attachments'] as List<dynamic>? ?? [];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

      decoration: BoxDecoration(
        color: Color.fromARGB(230, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isReblog && widget.rebloggedBy != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 0, 4),
                child: InkWell(
                  onTap: () {
                    context.push(
                      Routes.profile,
                      extra: widget.rebloggedBy!['id'],
                    );
                  },
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.repeat, // ikon reblog
                        size: 18,
                        color: Color.fromRGBO(
                          255,
                          117,
                          31,
                          1,
                        ), // sesuaikan warna
                      ),
                      const SizedBox(width: 6), // jarak antara ikon & text
                      Expanded(
                        child: Text(
                          "Repeated by @${widget.rebloggedBy!['acct']}", // akun yang me-reblog
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            InkWell(
              onTap: () {
                context.push(Routes.profile, extra: widget.account['id']);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Avatar with gradient ring
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(255, 117, 31, 1),
                            Color.fromRGBO(255, 117, 31, 0.6),
                          ],
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(
                            widget.account['avatar_static'],
                          ),
                          radius: 22,
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // User info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          displayNameWithEmoji(widget.account),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  "@${widget.account['acct']}",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (widget.timeAgo != "") ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Text(
                                    "•",
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                ),
                                Text(
                                  widget.timeAgo,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // More menu button
                    IconButton(
                      icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                          ),
                          builder: (context) => Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: buildPostMenu(
                                widget.account['id'].toString() ==
                                    currentUserId.toString(),
                                widget.post['bookmarked'],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Content Section
            InkWell(
              onTap: () {
                context.push(
                  Routes.viewPost,
                  extra: {
                    "post": widget.post,
                    "account": widget.account,
                    "timeAgo": widget.timeAgo,
                  },
                );
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Contentparsing(
                      content: widget.post['content'],
                      emojis: widget.post['emojis'],
                      mentions: widget.post['mentions'],
                    ),
                  ),

                  // Media attachments
                  if (media.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: PostMedia(
                        media: media,
                        sensitive: widget.post['sensitive'] ?? false,
                      ),
                    ),
                ],
              ),
            ),
            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ActionButton(icon: CupertinoIcons.reply, onTap: () {}),
                  ActionButton(
                    icon: widget.post['reblogged']
                        ? CupertinoIcons.repeat_1
                        : CupertinoIcons.repeat,
                    onTap: () {},
                  ),
                  ActionButton(
                    icon: widget.post['favourited']
                        ? CupertinoIcons.star_slash_fill
                        : CupertinoIcons.star_slash,
                    onTap: () async {
                      final id = widget.post['id'];
                      final newValue = !widget.post['favourited'];

                      // Optimistic update

                      try {
                        if (newValue) {
                          await ref.read(favoritePostActionProvider(id).future);
                        } else {
                          await ref.read(
                            unfavoritePostActionProvider(id).future,
                          );
                        }
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
                        ShareParams(text: widget.post['url']),
                      );
                    },
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


//  ActionButton(
//                     icon: mergedPost['bookmarked']
//                         ? Icons.bookmark_rounded
//                         : Icons.bookmark_border_rounded,
//                     onTap: () async {
//                       final id = mergedPost['id'];
//                       final newValue = !mergedPost['bookmarked'];

//                       // optimistic update
//                       ref.read(postStateProvider.notifier).patch(id, {
//                         'bookmarked': newValue,
//                       });

//                       try {
//                         if (newValue) {
//                           await ref.read(bookmarkPostActionProvider(id).future);
//                         } else {
//                           await ref.read(
//                             unbookmarkPostActionProvider(id).future,
//                           );
//                         }
//                       } catch (_) {
//                         // rollback
//                         ref.read(postStateProvider.notifier).patch(id, {
//                           'bookmarked': !newValue,
//                         });
//                       }
//                     },
//                     color: Colors.black,
//                   ),