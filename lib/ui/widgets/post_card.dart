import 'package:flutter/material.dart';
import 'package:mobileapp/domain/posts.dart';
import 'package:mobileapp/ui/widgets/post_images.dart';

class PostCard extends StatelessWidget {
  final Posts post;

  const PostCard({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 35, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Text(post.nickname ?? "Anonymous"),
              ],
            ),
            // Konten teks
            Text(post.content),
            const SizedBox(height: 8),

            PostImages(images: post.images),

            const SizedBox(height: 8),
            Text(
              post.createdAt.toLocal().toString(),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
