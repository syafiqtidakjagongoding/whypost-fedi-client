import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/api/auth_api.dart';
import 'package:mobileapp/routing/router.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/credentials.dart';
import 'package:mobileapp/state/oauthcode.dart';

class AuthProcess extends ConsumerStatefulWidget {
  final String? code;
  const AuthProcess({super.key, required this.code});

  @override
  ConsumerState<AuthProcess> createState() => _AuthProcessState();
}
class _AuthProcessState extends ConsumerState<AuthProcess> {
  String? _errorMessage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isProcessing) {
        processOAuth();
      }
    });
  }

  Future<void> processOAuth() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      if (!mounted) return;

      final credential = await ref.read(credentialProvider.future);
      final credRepo = ref.read(credentialRepoProvider);

      if (credential.instanceUrl == null || 
          credential.clientId == null || 
          credential.clientSecret == null ||
          widget.code == null) {
        throw Exception('Missing required credentials or code');
      }

      final token = await getAccessToken(
        instanceBaseUrl: credential.instanceUrl!,
        clientId: credential.clientId!,
        clientSecret: credential.clientSecret!,
        code: widget.code!,
      );

      if (token == null) {
        throw Exception('Failed to get access token');
      }

      debugPrint('Token received: $token');
      
      await credRepo.saveCredentials(
        token,
        credential.instanceUrl!,
        credential.clientId!,
        credential.clientSecret!,
      );

      // KUNCI: Pastikan navigation di frame berikutnya
      if (mounted) {
        // Cara 1: Pakai Future.delayed
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          context.go(Routes.home);
        }
        
        // ATAU Cara 2: Pakai addPostFrameCallback lagi
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   if (mounted) {
        //     context.go(Routes.home);
        //   }
        // });
      }
    } catch (e) {
      debugPrint('OAuth error: $e');
      
      // Tetap redirect ke home meskipun error
      // (karena token mungkin sudah tersimpan)
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          context.go(Routes.home);
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Processing authentication..."),
          ],
        ),
      ),
    );
  }
}