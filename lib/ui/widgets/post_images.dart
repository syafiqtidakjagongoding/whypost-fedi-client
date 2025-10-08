import 'package:flutter/material.dart';

class PostImages extends StatelessWidget {
  final List<String> images;
  const PostImages({required this.images, super.key});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return SizedBox.shrink();

    if (images.length == 1) {
      // Single image → full width
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          images[0],
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (images.length == 2) {
      // 2 images → side by side
      return Row(
        children: images.map((url) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(url, fit: BoxFit.cover, height: 150),
              ),
            ),
          );
        }).toList(),
      );
    } else if (images.length == 3) {
      // 3 images → left big, right top-bottom
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(images[0], fit: BoxFit.cover, height: 150),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(images[1], fit: BoxFit.cover),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(images[2], fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      );
    } else {
      // 4+ images → 2x2 grid
      return GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: images.length > 4 ? 4 : images.length,
        gridDelegate:
            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 4, mainAxisSpacing: 4),
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              images[index],
              fit: BoxFit.cover,
            ),
          );
        },
      );
    }
  }
}
