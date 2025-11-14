import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mobileapp/routing/routes.dart';
import 'package:mobileapp/state/instance.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  Instance? instance;
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _reasonController = TextEditingController();

  bool _loading = false;
  String? _resultMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final instanceProv = ref.read(instanceProvider);
    setState(() {
      instance = instanceProv;
    });

    if (!_formKey.currentState!.validate()) return;

    if (instance == null) {
      setState(() {
        _resultMessage = "Instance belum diset!";
      });
      return;
    }

    setState(() {
      _loading = true;
      _resultMessage = null;
    });

    final baseUrl = instance!.url.trim();
    final url = Uri.parse(baseUrl).resolve('/api/v1/accounts');

    final body = <String, String>{
      'username': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text.trim(),
      'agreement': 'true',
      'locale': 'en',
      if (instance!.isApproval == true) 'reason': _reasonController.text.trim(),
    };

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        setState(() {
          _resultMessage =
              'Registrasi berhasil! Username: ${data['username'] ?? _usernameController.text}';
        });

        // TODO:
        // Panggil login OAuth di sini
        // _startOAuthLogin();
      } else {
        String err = "Status: ${response.statusCode}";
        try {
          final json = jsonDecode(response.body);
          if (json['error'] != null) err += "\n${json['error']}";
          if (json['error_description'] != null)
            err += "\n${json['error_description']}";
          if (json['errors'] != null) err += "\n${json['errors']}";
        } catch (_) {
          if (response.body.isNotEmpty) err += "\n${response.body}";
        }

        setState(() {
          _resultMessage = "Gagal registrasi.\n$err";
        });
      }
    } catch (e) {
      setState(() {
        _resultMessage = "Terjadi kesalahan: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String? _validateUsername(String? v) {
    if (v == null || v.trim().isEmpty) return 'Masukkan username';
    if (v.length < 2) return 'Username terlalu pendek';
    // tambahan: larang spasi
    if (v.contains(' ')) return 'Username tidak boleh mengandung spasi';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Masukkan email';
    final emailRegex = RegExp(r"^[^\s@]+@[^\s@]+\.[^\s@]+$");
    if (!emailRegex.hasMatch(v.trim())) return 'Format email tidak valid';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Masukkan password';
    if (v.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Fediverse')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                'Isi data untuk mendaftar ke instance Fediverse',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: _validateUsername,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _reasonController,
                      decoration: const InputDecoration(
                        labelText: 'Reason',
                        alignLabelWithHint:
                            true, // penting untuk textarea agar label rapi di atas
                        prefixIcon: Icon(Icons.message_outlined),
                        hintText:
                            'Write your reason why do you want to join this instance ?',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      maxLines: 5, // bikin textarea tinggi
                      minLines: 3,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: _loading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                ),
                              )
                            : const Icon(Icons.app_registration),
                        label: Text(_loading ? 'Mendaftarkan...' : 'Daftar'),
                        onPressed: _loading ? null : _register,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_resultMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _resultMessage!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
