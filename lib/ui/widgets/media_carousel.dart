import 'package:flutter/material.dart';

class MediaCarousel extends StatefulWidget {
  final List<dynamic> media;
  final bool isSensitive;

  const MediaCarousel({
    super.key,
    required this.media,
    required this.isSensitive,
  });

  @override
  State<MediaCarousel> createState() => _MediaCarouselState();
}

class _MediaCarouselState extends State<MediaCarousel> {
  final PageController _controller = PageController();
  int _index = 0;
  bool _revealed = false;

  bool isVideo(String url, dynamic type) {
    return (type?.toString().contains("video") ?? false) ||
        url.endsWith(".mp4") ||
        url.endsWith(".webm") ||
        url.endsWith(".mov");
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.media;

    return Column(
      children: [
        SizedBox(
          height: 340,
          child: PageView.builder(
            controller: _controller,
            itemCount: media.length,
            onPageChanged: (v) => setState(() => _index = v),
            itemBuilder: (context, i) {
              final m = media[i];
              final url = m["url"];
              final preview = m["preview_url"];
              final type = m["type"] ?? m["media_type"] ?? m["mimetype"];

              final isVid = isVideo(url, type);

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: widget.isSensitive && !_revealed
                        ? _Blurred(
                            child: _MediaContent(
                              isVideo: isVid,
                              url: preview ?? url,
                            ),
                          )
                        : _MediaContent(
                            isVideo: isVid,
                            url: preview ?? url,
                          ),
                  ),

                  // tombol reveal jika sensitive
                  if (widget.isSensitive && !_revealed)
                    Positioned.fill(
                      child: Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black.withOpacity(0.6),
                          ),
                          onPressed: () {
                            setState(() => _revealed = true);
                          },
                          child: const Text("Tap to Reveal"),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // DOTS INDICATOR
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            media.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _index == i ? 10 : 6,
              height: _index == i ? 10 : 6,
              decoration: BoxDecoration(
                color: _index == i ? Colors.blueAccent : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          ),
        )
      ],
    );
  }
}
