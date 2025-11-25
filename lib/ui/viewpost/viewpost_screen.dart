import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/api/user_api.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/action.dart';
import 'package:mobileapp/state/globalpost.dart';
import 'package:mobileapp/state/post.dart';
import 'package:mobileapp/state/postNotifier.dart';
import 'package:mobileapp/state/user.dart';
import 'package:mobileapp/ui/utils/FediverseImage.dart';
import 'package:mobileapp/ui/widgets/post_images.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mobileapp/domain/posts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobileapp/ui/utils/ActionButton.dart';

class ViewpostScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> post;
  final Map<String, dynamic> account;
  final String timeAgo;

  const ViewpostScreen({
    super.key,
    required this.post,
    required this.account,
    required this.timeAgo,
  });

  @override
  ConsumerState<ViewpostScreen> createState() => _ViewpostScreenState();
}

class _ViewpostScreenState extends ConsumerState<ViewpostScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Post from ${widget.account['username']}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromRGBO(255, 117, 31, 1),
      ),
      body: SingleChildScrollView(
        child: Card(
          color: Colors.white,
          margin: const EdgeInsets.all(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🧍 Header Post (Profile + Username + Waktu)
                InkWell(
                  onTap: () {
                    context.push(Routes.profile, extra: widget.account['id']);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          widget.account['avatar_static'],
                        ),
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
                                Text(
                                  mergedPost['display_name'] ??
                                      widget.account['username'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "@${widget.account['acct']}",
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
                                            children: buildPostMenu(true),
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
                              widget.timeAgo,
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

                const SizedBox(height: 8),

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

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
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
                            if (newValue) {
                              await ref.read(
                                favoritePostActionProvider(id).future,
                              );
                            } else {
                              await ref.read(
                                unfavoritePostActionProvider(id).future,
                              );
                            }
                            print("is favourited ? $newValue");
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
                              await ref.read(
                                bookmarkPostActionProvider(id).future,
                              );
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
                      ActionButton(icon: Icons.share_outlined, onTap: () {}),
                    ],
                  ),
                ),

                const Divider(
                  color: Colors.black45,
                  thickness: 1.5,
                  indent: 10,
                  endIndent: 10,
                ),

                // 🗨️ Contoh Komentar (bisa diganti ListView.builder)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: comments.map((c) => _buildCommentTree(c)).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommentTree(Comment comment, {int depth = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Komentar utama
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 15,
                child: Icon(Icons.person, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(comment.content),
                  ],
                ),
              ),
              const Divider(
                color: Colors.black45,
                thickness: 1.5,
                indent: 10,
                endIndent: 10,
              ),
            ],
          ),

          // 🧵 Balasan komentar (jika ada)
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Column(
                children: comment.replies
                    .map((reply) => _buildCommentTree(reply, depth: depth + 1))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class Comment {
  final String username;
  final String content;
  final List<Comment> replies;

  Comment({
    required this.username,
    required this.content,
    this.replies = const [],
  });
}

final comments = [
  Comment(
    username: "user1",
    content: "Komentar pertama",
    replies: [
      Comment(
        username: "user2",
        content: "Balasan ke user1",
        replies: [Comment(username: "user3", content: "Balasan ke user2")],
      ),
    ],
  ),
  Comment(username: "user4", content: "Komentar kedua tanpa reply"),
];
