import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/timeline.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:mobileapp/state/credentials.dart';
import 'package:mobileapp/ui/utils/FediverseImage.dart';
import 'package:mobileapp/ui/utils/InstanceLink.dart';
import 'package:mobileapp/ui/widgets/post_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // List<dynamic> posts = [];
  // int currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final notifier = ref.read(homeTimelineProvider.notifier);

      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        notifier.loadMore(); // INFINITE SCROLL TRIGGER
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timeline = ref.watch(homeTimelineProvider);

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
      drawer: Drawer(
        child: Column(
          children: [
            // Header
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromRGBO(255, 117, 31, 1)),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ==== Menu list ====
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Beranda"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profil"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Pengaturan"),
              onTap: () {},
            ),

            // ===== Spacer mendorong logout ke bawah =====
            const Spacer(),

            // ==== LOGOUT BUTTON ====
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Konfirmasi Logout"),
                        content: const Text("Apakah kamu yakin ingin logout?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("OK"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    final credential = ref.read(credentialRepoProvider);
                    await credential.clearAll();
                    if (context.mounted) {
                      context.go(Routes.instance);
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(homeTimelineProvider.notifier).refresh();
        },
        child: timeline.when(
          loading: () => const Center(child: CircularProgressIndicator()),

          error: (e, _) {
            router.go(Routes.instance);
            return Center(child: Text("Error: $e"));
          },
          data: (posts) {
            print(posts);
            return PostCard(posts: posts, scrollCtrl: _scrollController);
          },
        ),
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
