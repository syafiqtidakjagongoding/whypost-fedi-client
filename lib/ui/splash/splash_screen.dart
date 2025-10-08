import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/api/anon_login.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initGuest();
  }

  void _initGuest() async {
   await initGuestUser(ref);       // pasti ke-execute
    if (!mounted) return;
    context.go(Routes.home);        // navigasi ke HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
