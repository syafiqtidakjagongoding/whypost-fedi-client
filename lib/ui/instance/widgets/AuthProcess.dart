import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobileapp/api/auth_api.dart';
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/credentials.dart';
import 'package:mobileapp/state/timeline.dart';

class AuthProcess extends ConsumerStatefulWidget {
  final String? code;
  const AuthProcess({super.key, required this.code});

  @override
  ConsumerState<AuthProcess> createState() => _AuthProcessState();
}

class _AuthProcessState extends ConsumerState<AuthProcess> {
  bool _isProcessing = false;
  bool _navigationHandled = false; // Tambahkan flag ini

  @override
  void initState() {
    super.initState();
    // Cukup panggil sekali dengan delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && !_isProcessing && !_navigationHandled) {
        processOAuth();
      }
    });
  }

  Future<void> processOAuth() async {
    if (_isProcessing || _navigationHandled) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      if (!mounted) return;
      final credRepo = ref.read(credentialRepoProvider);

      final credential = await ref.read(credentialProvider.future);

      if (credential.instanceUrl == null ||
          credential.clientId == null ||
          credential.clientSecret == null ||
          widget.code == null) {
        // throw Exception('Missing required credentials or code');
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

      // ✅ Invalidate semua provider untuk "fresh start"
      ref.invalidate(credentialProvider);
      ref.invalidate(homeTimelineProvider);
      // Pastikan navigation hanya terjadi sekali
      if (mounted && !_navigationHandled) {
        _navigationHandled = true;
        // Gunakan SchedulerBinding untuk navigate di frame berikutnya
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.go(Routes.home);
          }
        });
      }
    } catch (e) {
      if (mounted && !_navigationHandled) {
        _navigationHandled = true;

        // Tampilkan error dulu, baru navigate
        Future.delayed(const Duration(seconds: 2), () {
          // ✅ Invalidate semua provider untuk "fresh start"
          ref.invalidate(credentialProvider);
          ref.invalidate(homeTimelineProvider);
          if (mounted) {
            context.go(Routes.home);
          }
        });
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
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text("Processing authentication..."),
          ],
        ),
      ),
    );
  }
}
