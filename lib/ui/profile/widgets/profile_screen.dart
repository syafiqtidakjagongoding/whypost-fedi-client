import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // 🔹 Header
            Container(
              padding: EdgeInsets.fromLTRB(16, 30, 16, 25),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
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
                    
                    ],
                  ),
                ],
              ),
            ),

            // 🔹 TabBar
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

            // 🔹 TabBarView
            Expanded(
              child: TabBarView(
                children: [
                ]))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go(Routes.addPost);
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
