import 'package:flutter/cupertino.dart';
import 'package:mobileapp/state/comment.dart';
import 'package:mobileapp/state/credentials.dart';
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
  String? currentUserId;
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
    final cred = await CredentialsRepository.loadAllCredentials();
    setState(() {
      currentUserId = cred.currentUserId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.post['media_attachments'] as List<dynamic>? ?? [];

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
        padding: EdgeInsets.all(12),
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
                              displayNameWithEmoji(widget.account),
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
                                          children: buildPostMenu(
                                            widget.account['id'].toString() ==
                                                currentUserId.toString(),
                                            widget.post['bookmarked'],
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
                child: Contentparsing(
                  mentions: widget.post['mentions'],
                  content: widget.post['content'],
                  emojis: widget.post['emojis'],
                ),
              ),

              const SizedBox(height: 8),

              if (media.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: PostMedia(
                    media: media,
                    sensitive: widget.post['sensitive'] ?? false,
                  ),
                ),

              const SizedBox(height: 8),

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
                      color: Colors.grey,
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
                            await ref.read(
                              favoritePostActionProvider(id).future,
                            );
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

              const Divider(
                color: Colors.black45,
                thickness: 1.5,
                indent: 10,
                endIndent: 10,
              ),

              // 🗨️ Contoh Komentar (bisa diganti ListView.builder)
              CommentListWidget(statusId: widget.post['id']),
            ],
          ),
        ),
      ),
    );
  }
}
