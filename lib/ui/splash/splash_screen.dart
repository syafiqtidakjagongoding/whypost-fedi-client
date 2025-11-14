import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/token.dart';

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
    final token = ref.read(tokenProvider);
    if (token != null && token.isNotEmpty) {
      context.go(Routes.home);
      return;
    }
    if (!mounted) return;
    context.go(Routes.instance); // navigasi ke HomeScreen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 117, 31, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/icon_app.png", width: 200, height: 200),

            const SizedBox(height: 20),

            // 🔄 Loading indicator
            const CircularProgressIndicator(color: Colors.white),
            
          ],
        ),
      ),
    );
  }
}
