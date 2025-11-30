import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/comment.dart';
import 'package:mobileapp/ui/utils/ContentParsing.dart';
import 'package:mobileapp/ui/utils/displayNameWithEmoji.dart';

class CommentListWidget extends ConsumerWidget {
  final String statusId;

  const CommentListWidget({super.key, required this.statusId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentAsync = ref.watch(commentProvider(statusId));

    return commentAsync.when(
      data: (comments) {
        if (comments == null) {
          return const Center(child: Text("No comments yet."));
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final c = comments[index];
            final content = c['content'] ?? '';
            final account = c['account'] ?? {};
            final mentions = c['mentions'];
            final emojis = c['emojis'];
            final avatar = account['avatar'] ?? '';

            return Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER + AVATAR → clickable
                    InkWell(
                      onTap: () {
                        context.go(Routes.profile, extra: account['id']);
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(avatar),
                            radius: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: displayNameWithEmoji(account)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // CONTENT → tidak clickable
                    Contentparsing(
                      content: content,
                      emojis: emojis,
                      mentions: mentions,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text("Failed to load comments: $err")),
    );
  }
}
