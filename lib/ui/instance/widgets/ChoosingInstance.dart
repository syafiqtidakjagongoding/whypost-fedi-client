import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/instance.dart';

class ChooseInstancePage extends ConsumerStatefulWidget {
  const ChooseInstancePage({super.key});

  @override
  ConsumerState<ChooseInstancePage> createState() => _ChooseInstancePageState();
}

class _ChooseInstancePageState extends ConsumerState<ChooseInstancePage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController(
    text: 'https://mastodon.social',
  );
  bool _loading = false;
  String? _message;

  String? _validateInstance(String? v) {
    if (v == null || v.trim().isEmpty) return 'Please enter the instance URL.';
    final text = v.trim();
    if (!text.startsWith('http')) {
      return 'Use the full URL format (https://...).';
    }
    if (!text.contains('.')) return 'The instance URL looks invalid.';
    return null;
  }

  

  Future<void> _checkInstance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _message = null;
    });

    final instance = _controller.text.trim();

    try {
      final redirectUri = "whypostapp://callback";
      // Coba ambil info instance dari /api/v1/instance (Mastodon-compatible)
      final uri = Uri.parse('$instance/api/v1/instance');
       final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 7), onTimeout: () {
        throw TimeoutException("Instance take too longer to respond");
      });
      dynamic jsonData;
      if (response.statusCode == 200) {
        // Parse JSON body
        jsonData = jsonDecode(response.body);

        final data = jsonDecode(response.body);

        if (data is! Map<String, dynamic>) {
          throw Exception("Response isn't valid (not JSON object)");
        }

        // pastikan field utama ada dan tidak null
        if (data['uri'] == null || data['registrations'] == null) {
          throw Exception("Instance isn't fediverse or mastodon compatible");
        }
      } else {
        throw Exception("Failed to checking instance");
      }
      // (Kamu bisa ganti dengan http.get(uri) jika ingin benar-benar fetch)
      // contoh dummy di sini, karena kita tidak konek ke server langsung

      // Jika sukses:
      setState(() {
        _message = 'Instance detected: $instance';
      });
      jsonData['uri'] = normalizeUrl(jsonData['uri']);

      ref
          .read(instanceProvider.notifier)
          .setInstanceFromData(jsonData, redirectUri);

      // Setelah sukses, bisa pop ke halaman sebelumnya dengan membawa nilai
      context.push(Routes.instanceAuthPage, extra: {"instanceData": jsonData});
    } on TimeoutException catch (_) {
      setState(() {
        _message = "Request timed out. The server is too slow.";
      });
    } catch (e) {
      setState(() {
        _message = "Failed to check instance: $e";
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String normalizeUrl(String? url) {
    if (url == null || url.trim().isEmpty) return "";

    var u = url.trim();

    // Jika tidak ada scheme → pakai https secara default
    if (!u.startsWith("http://") && !u.startsWith("https://")) {
      u = "https://$u";
    }

    // Buang trailing slash
    if (u.endsWith("/")) {
      u = u.substring(0, u.length - 1);
    }

    return u;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Fediverse Instance')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter Fediverse Instance URL\n',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _controller,
                validator: _validateInstance,
                decoration: const InputDecoration(
                  labelText: 'Instance URL',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: _loading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_done),
                label: Text(_loading ? 'Checking...' : 'Use Instance'),
                onPressed: _loading ? null : _checkInstance,
              ),
              const SizedBox(height: 20),
              if (_message != null)
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _message!.contains('Fail')
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
