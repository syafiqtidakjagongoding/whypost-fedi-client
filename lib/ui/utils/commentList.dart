import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/comment.dart';
import 'package:mobileapp/ui/utils/ContentParsing.dart';
import 'package:mobileapp/ui/utils/displayNameWithEmoji.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentListWidget extends ConsumerWidget {
  final String statusId;
  final Map<String, dynamic>? originalPost;

  const CommentListWidget({
    super.key,
    required this.statusId,
    this.originalPost,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentAsync = ref.watch(commentProvider(statusId));

    return Column(
      children: [
        // Comment List
        commentAsync.when(
          data: (comments) {
            if (comments == null || comments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No comments yet",
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Be the first to comment!",
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final c = comments[index];
                final content = c['content'] ?? '';
                final account = c['account'] ?? {};
                final mentions = c['mentions'];
                final emojis = c['emojis'];
                final avatar = account['avatar'] ?? '';
                final createdAt = c['created_at'];
                final timeAgo = createdAt != null
                    ? timeago.format(DateTime.parse(createdAt))
                    : '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar - clickable
                      GestureDetector(
                        onTap: () {
                          context.push(Routes.profile, extra: account['id']);
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(avatar),
                          radius: 18,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Comment content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with name and timestamp
                            GestureDetector(
                              onTap: () {
                                context.push(
                                  Routes.profile,
                                  extra: account['id'],
                                );
                              },
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      displayNameWithEmoji(account),
                                      SizedBox(
                                        width:
                                            150, // atau MediaQuery jika mau dinamis
                                        child: Text(
                                          "@${account['acct']}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '· $timeAgo',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Comment text
                            Contentparsing(
                              content: content,
                              emojis: emojis,
                              mentions: mentions,
                            ),
                            const SizedBox(height: 8),

                            // Action buttons
                            Row(
                              children: [
                                _CommentActionButton(
                                  icon: Icons.favorite_border,
                                  label:
                                      c['favourites_count']?.toString() ?? '0',
                                  onTap: () {
                                    // TODO: Like comment
                                  },
                                ),
                                const SizedBox(width: 16),
                                _CommentActionButton(
                                  icon: Icons.chat_bubble_outline,
                                  label: 'Reply',
                                  onTap: () {
                                    // Navigate to reply page with mention
                                    context.push(
                                      Routes.addPost,
                                      extra: {
                                        'replyTo': c['id'],
                                        'mention': '@${account['acct']}',
                                        'isReply': true,
                                      },
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
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 12),
                  Text(
                    "Failed to load comments",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    err.toString(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Comment Input Box
        SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GestureDetector(
              onTap: () {
                // Navigate to add post page with reply context
                final mention = originalPost != null
                    ? '@${originalPost!['account']['acct']}'
                    : '';

                context.push(
                  Routes.addPost,
                  extra: {
                    'replyTo': statusId,
                    'mention': mention,
                    'isReply': true,
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Write a comment...',
                        style: TextStyle(color: Colors.grey[600], fontSize: 15),
                      ),
                    ),
                    Icon(Icons.send, color: Colors.grey[400], size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Helper widget for action buttons
class _CommentActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CommentActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
