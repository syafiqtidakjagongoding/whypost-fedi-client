import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/timeline.dart';
import 'package:mobileapp/state/token.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(homeTimelineProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('For you'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(255, 117, 31, 1),
        titleTextStyle: const TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
      ),

      body: timelineAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) {
          Future.microtask(() {
            context.go(Routes.instance);
          });

          return Center(child: Text("Error: $e"));
        },
        data: (posts) {
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, i) {
              final post = posts[i];
              final account = post['account'];
              final avatar = account['avatar_static'] ?? '';
              final displayName =
                  account['display_name'] ?? account['username'];
              final acct = account['acct'];
              final content = post['content'] ?? '';
              print(account.toString());

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        backgroundImage: NetworkImage(avatar),
                        radius: 24,
                      ),
                      const SizedBox(width: 12),

                      // Post content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "@$acct",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(content, style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(Routes.addPost);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
