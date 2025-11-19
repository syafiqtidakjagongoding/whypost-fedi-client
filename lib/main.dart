import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/api/auth_api.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/credentials.dart';
import 'package:mobileapp/state/oauthcode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routing/router.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await SharedPreferences.getInstance();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription? _sub;
  bool _handled = false;
  Timer? _resetTimer;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      initDeepLinks();
    });
  }

  Future<void> initDeepLinks() async {
    _sub = AppLinks().uriLinkStream.listen((uri) {
      debugPrint("Deep Link Triggered: $uri");

      if (_handled) {
        debugPrint("Deep link already handled, ignoring");
        return;
      }

      final code = uri.queryParameters['code'];
      if (code != null) {
        _handled = true;

        // Cancel timer lama jika ada
        _resetTimer?.cancel();

        // Navigate dengan delay
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            debugPrint("Navigating to auth process with code: $code");
            router.go(Routes.authProcess, extra: {"code": code});
          }
        });

        // Reset flag setelah 5 detik
        _resetTimer = Timer(const Duration(seconds: 5), () {
          _handled = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _resetTimer?.cancel();
    super.dispose();
  }

  // ... rest of code
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "WhyPost App",
      routerConfig: router,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          primary: Color.fromRGBO(255, 117, 31, 1),
          seedColor: Colors.white,
        ),
        useMaterial3: true,
      ),
    );
  }
}
