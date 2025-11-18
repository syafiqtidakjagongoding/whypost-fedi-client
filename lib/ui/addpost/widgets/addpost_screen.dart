import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobileapp/api/post_api.dart';
import 'dart:io';

import 'package:mobileapp/state/credentials.dart';

class AddPostWidget extends ConsumerStatefulWidget {
  const AddPostWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<AddPostWidget> createState() => _AddPostWidgetState();
}

class _AddPostWidgetState extends ConsumerState<AddPostWidget> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 80);
    if (picked.isNotEmpty) {
      setState(() {
        _images.addAll(picked);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  // ===========================
  // PERBAIKI DI SINI
  // ===========================
  Future<void> submitPost(WidgetRef ref) async {
    final content = _contentController.text.trim();

    if (content.isEmpty && _images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tulis sesuatu atau tambahkan gambar')),
      );
      return;
    }

    // 🔹 Convert XFile → File
    final List<File> files = _images.map((x) => File(x.path)).toList();

    final credential = await ref.read(credentialProvider.future);

    if (credential.instanceUrl == null || credential.accToken == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Anda belum login!')));
      return;
    }

    try {
      // 🔥 Kirim ke Fediverse
      await createFediversePost(
        content: content,
        instanceUrl: credential.instanceUrl!,
        accessToken: credential.accToken!,
        images: files,
      );

      // 🔥 Hapus input setelah sukses
      setState(() {
        _contentController.clear();
        _images.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan berhasil dibuat!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat postingan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          backgroundColor: Colors.grey[200],
          body: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      500, // optional, biar nggak terlalu lebar di layar besar
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 📝 Input konten
                      TextField(
                        controller: _contentController,
                        maxLines: null,
                        decoration: const InputDecoration(
                          hintText: "Lets post as you like",
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 🖼️ Preview gambar
                      if (_images.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _images.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final file = File(_images[index].path);
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      file,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 8),
                      // 📸 Tombol pilih gambar + Post
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: _pickImages,
                            icon: const Icon(Icons.image),
                            label: const Text('Tambah Gambar'),
                          ),
                          ElevatedButton(
                            onPressed: () => {submitPost(ref)},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Post'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
