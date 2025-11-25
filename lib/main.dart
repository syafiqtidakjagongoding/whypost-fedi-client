import 'dart:async';

// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileapp/api/auth_api.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/app.dart';
import 'package:mobileapp/state/post.dart';
import 'package:mobileapp/state/timeline.dart';
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
  Timer? _resetTimer;
  static const _keyToken = "access_token";
  static const _instanceurl = "instance_url";
  static const _clientId = "client_id";
  static const _clientSecret = "client_secret";

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  Future<void> initDeepLinks() async {
    _sub = AppLinks().uriLinkStream.listen((uri) async {
      debugPrint("Deep Link Triggered: $uri");

      final code = uri.queryParameters['code'];
      if (code != null) {
        // Navigate dengan delay
        if (mounted) {
          final prefs = await SharedPreferences.getInstance();

          final instanceUrl = prefs.getString(_instanceurl);
          final clientId = prefs.getString(_clientId);
          final clientSecret = prefs.getString(_clientSecret);

          // Cek mandatory values
          if (instanceUrl == null || clientId == null || clientSecret == null) {
            debugPrint("❌ Data OAuth tidak lengkap");
            return;
          }

          // Ambil access token
          final accToken = await getAccessToken(
            instanceBaseUrl: instanceUrl,
            clientId: clientId,
            clientSecret: clientSecret,
            code: code,
          );

          if (accToken == null || accToken.trim().isEmpty) {
            debugPrint("❌ Gagal mendapatkan token. Body kosong.");
            return;
          }

          // SIMPAN hanya jika token valid
          await prefs.setString(_keyToken, accToken);
          ref.invalidate(homeTimelineProvider);
       
          debugPrint("✅ Token berhasil disimpan: $accToken");
          router.go(Routes.home);
        }
      } else {
        router.go(Routes.instance);
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
