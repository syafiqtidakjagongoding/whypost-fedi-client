import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/ui/utils/FediverseImage.dart';
import 'package:mobileapp/ui/utils/InstanceLink.dart';
import 'package:mobileapp/ui/viewpost/viewpost_screen.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PostCard extends ConsumerStatefulWidget {
  final List<dynamic> posts;
  final ScrollController scrollCtrl;

  const PostCard({Key? key, required this.posts, required this.scrollCtrl})
    : super(key: key);

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  late List<dynamic> posts;

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
    posts = widget.posts;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: posts.length,
      itemBuilder: (context, i) {
        final post = posts[i];
        final account = post['account'];
        final media = post['media_attachments'] as List<dynamic>? ?? [];
        final avatar = account['avatar_static'] ?? '';
        final displayName = account['display_name'] ?? account['username'];
        final acct = account['acct'];
        final content = post['content'] ?? '';
        final createdAt = post['created_at'];
        final timeAgo = createdAt != null
            ? timeago.format(DateTime.parse(createdAt))
            : '';

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
                // Header Section
                Padding(
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
                            backgroundImage: NetworkImage(avatar),
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
                              displayName,
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
                                    "@$acct",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (timeAgo.isNotEmpty) ...[
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
                                    timeAgo,
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

                // Content Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Html(
                    data: content,
                    onLinkTap: (url, attributes, element) {
                      final uri = Uri.parse(
                        url!.startsWith('http') ? url : 'https://$url',
                      );
                      if (uri != null)
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

                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: post['replies_count']?.toString() ?? '0',
                        onTap: () {},
                      ),
                      _ActionButton(
                        icon: Icons.repeat,
                        label: post['reblogs_count']?.toString() ?? '0',
                        onTap: () {},
                        color: Colors.green,
                      ),
                      _ActionButton(
                        icon: Icons.favorite_border,
                        label: post['favourites_count']?.toString() ?? '0',
                        onTap: () {},
                        color: Colors.red,
                      ),
                      _ActionButton(
                        icon: Icons.share_outlined,
                        label: '',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Colors.grey[700];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: buttonColor),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: buttonColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
