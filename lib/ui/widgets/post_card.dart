import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/action.dart';
import 'package:mobileapp/state/globalpost.dart';
import 'package:mobileapp/ui/utils/ActionButton.dart';
import 'package:mobileapp/ui/utils/FediverseImage.dart';
import 'package:flutter/material.dart';
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
    required this.rebloggedBy
  }) : super(key: key);

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  List<Widget> buildPostMenu(bool isUserPost) {
    final menu = <Widget>[];

    if (isUserPost) {
      menu.add(
        ListTile(
          leading: Icon(Icons.edit, color: Colors.blue),
          title: Text('Edit Postingan'),
          onTap: () {},
        ),
      );
      menu.add(
        ListTile(
          leading: Icon(Icons.delete, color: Colors.red),
          title: Text('Hapus Postingan'),
          onTap: () {},
        ),
      );
    } else {
      menu.add(
        ListTile(
          leading: Icon(Icons.flag, color: Colors.orange),
          title: Text('Laporkan Postingan'),
          onTap: () {},
        ),
      );
    }

    return menu;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final globalPatch = ref.watch(
      postStateProvider.select((m) => m[widget.post['id']]),
    );

    final mergedPost = {
      ...widget.post,
      if (globalPatch != null) ...globalPatch,
    };
    final media = mergedPost['media_attachments'] as List<dynamic>? ?? [];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isReblog && widget.rebloggedBy != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 0, 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.repeat, // ikon reblog
                      size: 18,
                      color: Colors.grey[600], // sesuaikan warna
                    ),
                    const SizedBox(width: 6), // jarak antara ikon & text
                    Expanded(
                      child: Text(
                        "Reblogged by ${widget.rebloggedBy!['acct']}", // akun yang me-reblog
                        style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                      ),
                    ),
                  ],
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
                          Text(
                            mergedPost['display_name'] ??
                                widget.account['username'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) => Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: buildPostMenu(false),
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
                    "post": Map<String, dynamic>.from(mergedPost),
                    "account": widget.account,
                    "timeAgo": widget.timeAgo,
                  },
                );
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Html(
                      data: mergedPost['content'],
                      onLinkTap: (url, attributes, element) {
                        final uri = Uri.parse(
                          url!.startsWith('http') ? url : 'https://$url',
                        );
                        launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      style: {
                        "body": Style(
                          fontSize: FontSize(15),
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          lineHeight: LineHeight(1.5),
                        ),
                        "p": Style(
                          margin: Margins.only(bottom: 8),
                          color: Colors.black87,
                        ),
                        "b": Style(fontWeight: FontWeight.bold),
                        "i": Style(fontStyle: FontStyle.italic),
                        "span": Style(
                          fontSize: FontSize(15),
                          color: Colors.black87,
                        ),
                        "a": Style(
                          color: Color.fromRGBO(255, 117, 31, 1),
                          textDecoration: TextDecoration.none,
                          fontWeight: FontWeight.w600,
                        ),
                      },
                    ),
                  ),

                  // Media attachments
                  if (media.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        children: media.asMap().entries.map((entry) {
                          final m = entry.value;
                          final url = m['url'];
                          final preview = m['preview_url'];
                          final isLast = entry.key == media.length - 1;

                          return Padding(
                            padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                bottomLeft: isLast
                                    ? Radius.circular(16)
                                    : Radius.zero,
                                bottomRight: isLast
                                    ? Radius.circular(16)
                                    : Radius.zero,
                              ),
                              child: FediverseImage(
                                url: preview ?? url,
                                width: double.infinity,
                                height: 280,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }).toList(),
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
                  ActionButton(icon: Icons.reply, onTap: () {}),
                  ActionButton(
                    icon: mergedPost['reblogged']
                        ? Icons.repeat_one_rounded
                        : Icons.repeat_rounded,
                    onTap: () {},
                    color: Colors.green,
                  ),
                  ActionButton(
                    icon: mergedPost['favourited']
                        ? Icons.favorite
                        : Icons.favorite_border,
                    onTap: () async {
                      final id = mergedPost['id'];
                      final newValue = !mergedPost['favourited'];

                      // Optimistic update
                      ref.read(postStateProvider.notifier).patch(id, {
                        'favourited': newValue,
                      });

                      try {
                        print("is favourited ? $newValue");
                        if (newValue) {
                          await ref.read(favoritePostActionProvider(id).future);
                        } else {
                          await ref.read(
                            unfavoritePostActionProvider(id).future,
                          );
                        }
                      } catch (_) {
                        // rollback
                        ref.read(postStateProvider.notifier).patch(id, {
                          'favourited': !newValue,
                        });
                      }
                    },

                    color: Colors.red,
                  ),
                  ActionButton(
                    icon: mergedPost['bookmarked']
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    onTap: () async {
                      final id = mergedPost['id'];
                      final newValue = !mergedPost['bookmarked'];

                      // optimistic update
                      ref.read(postStateProvider.notifier).patch(id, {
                        'bookmarked': newValue,
                      });

                      try {
                        if (newValue) {
                          await ref.read(bookmarkPostActionProvider(id).future);
                        } else {
                          await ref.read(
                            unbookmarkPostActionProvider(id).future,
                          );
                        }
                      } catch (_) {
                        // rollback
                        ref.read(postStateProvider.notifier).patch(id, {
                          'bookmarked': !newValue,
                        });
                      }
                    },
                    color: Colors.black,
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
