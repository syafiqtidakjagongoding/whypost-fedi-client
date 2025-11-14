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
    text: 'https://fedi.syafiq-paradisam.my.id',
  );
  bool _loading = false;
  String? _message;

  String? _validateInstance(String? v) {
    if (v == null || v.trim().isEmpty) return 'Masukkan URL instance';
    final text = v.trim();
    if (!text.startsWith('http')) return 'Gunakan format lengkap (https://...)';
    if (!text.contains('.')) return 'URL instance tampak tidak valid';
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
      // Coba ambil info instance dari /api/v1/instance (Mastodon-compatible)
      final uri = Uri.parse('$instance/api/v1/instance');
      final response = await http.get(uri);
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
          throw Exception("Instance isn't fediverse");
        }
      } else {
        print('Gagal: ${response.statusCode}');
      }
      // (Kamu bisa ganti dengan http.get(uri) jika ingin benar-benar fetch)
      // contoh dummy di sini, karena kita tidak konek ke server langsung

      // Jika sukses:
      setState(() {
        _message = 'Instance terdeteksi: $instance';
      });
      final appReg = await http.post(
        Uri.parse('$instance/api/v1/apps'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'client_name': 'WhyPost',
          'redirect_uris': 'myapp://callback',
          'scopes': 'read write follow push',
          'website': 'https://app.syafiq-paradisam.my.id',
        }),
      );

      if (appReg.statusCode != 200) {
        throw Exception("Gagal register app: ${appReg.body}");
      }

      final regJson = jsonDecode(appReg.body);

      final clientId = regJson['client_id'];
      final clientSecret = regJson['client_secret'];

      ref
          .read(instanceProvider.notifier)
          .setInstance(
            instance,
            jsonData['approval_required'],
            clientId,
            clientSecret,
          );

      // Setelah sukses, bisa pop ke halaman sebelumnya dengan membawa nilai
      context.push(
        Routes.instanceAuthPage,
        extra: jsonData, // kirim JSON hasil fetch
      );
    } catch (e) {
      setState(() {
        _message = '$e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
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
                label: Text(_loading ? 'Memeriksa...' : 'Gunakan Instance'),
                onPressed: _loading ? null : _checkInstance,
              ),
              const SizedBox(height: 20),
              if (_message != null)
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _message!.contains('Gagal')
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
