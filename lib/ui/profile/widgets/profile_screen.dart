import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/api/user_api.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/user.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String? id;
  ProfileScreen({super.key, this.id});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = widget.id == null
        ? ref.watch(currentUserProvider)
        : ref.watch(selectedUserProvider(widget.id!));

    return Scaffold(
      body: userAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (user) => DefaultTabController(
          length: 3,
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.fromLTRB(16, 30, 16, 25),
                color: Theme.of(context).colorScheme.primary,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person, size: 35, color: Colors.white),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?['acct'] ?? "(no acct)")
                        ],
                    ),
                  ],
                ),
              ),

              // TabBar
              TabBar(
                indicatorColor: Colors.black,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(text: "Your posts", icon: Icon(Icons.post_add)),
                  Tab(text: "Likes", icon: Icon(Icons.favorite)),
                  Tab(text: "Saved post", icon: Icon(Icons.bookmark)),
                ],
              ),

              // TabBarView
              Expanded(
                child: TabBarView(
                  children: [
                    Center(child: Text("Posts")),
                    Center(child: Text("Likes")),
                    Center(child: Text("Saved")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go(Routes.addPost),
        child: Icon(Icons.add),
      ),
    );
  }
}
