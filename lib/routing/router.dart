import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/ui/addpost/widgets/addpost_screen.dart';
import 'package:mobileapp/ui/home/widgets/home_screen.dart';
import 'package:mobileapp/ui/notifications/widgets/notifications_screen.dart';
import 'package:mobileapp/ui/profile/widgets/profile_screen.dart';
import 'package:mobileapp/ui/search/widgets/search_screen.dart';
import 'package:mobileapp/ui/splash/splash_screen.dart';

final router = GoRouter(
  initialLocation: Routes.splash,
  routes: [
    /// 🔹 ShellRoute untuk layout dengan BottomNavigationBar
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            fixedColor: Colors.black,
            unselectedItemColor: Colors.grey,
            currentIndex: _calculateIndex(state.uri.toString()),
            onTap: (index) {
              switch (index) {
                case 0:
                  context.go(Routes.home);
                  break;
                case 1:
                  context.go(Routes.search); // belum kamu definisikan di sini
                  break;
                case 2:
                  context.go(
                    Routes.notifications,
                  ); // belum kamu definisikan di sini
                  break;
                case 3:
                  context.go(Routes.profile);
                  break;
              }
            },
            showSelectedLabels: false, // 👈 sembunyikan label
            showUnselectedLabels: false, // 👈 sembunyikan label
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: "Search",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: "Notifications",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        );
      },
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: Routes.search,
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: Routes.notifications,
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: Routes.profile,
          builder: (context, state) => const ProfileScreen(),
        ),
         GoRoute(
          path: Routes.addPost,
          builder: (context, state) => const AddPostWidget(),
        ),
        GoRoute(
          path: Routes.splash,
          builder: (context,state) =>  SplashScreen(),
        )
      ],
    ),
  ],
);

/// Helper buat tahu index BottomNavigationBar
int _calculateIndex(String location) {
  if (location.startsWith(Routes.home)) return 0;
  if (location.startsWith(Routes.search)) return 1;
  if (location.startsWith(Routes.notifications)) return 3;
  if (location.startsWith(Routes.profile)) return 3;
  return 0;
}
