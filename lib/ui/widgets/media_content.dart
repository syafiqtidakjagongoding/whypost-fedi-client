import 'package:flutter/cupertino.dart';
import 'package:mobileapp/ui/utils/FediverseImage.dart';
import 'package:mobileapp/ui/widgets/video_player_widget.dart';

class _MediaContent extends StatelessWidget {
  final bool isVideo;
  final String url;

  const _MediaContent({
    required this.isVideo,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    if (isVideo) {
      return _VideoPlayerWidget(url);
    }

    return FediverseImage(
      url: url,
      width: double.infinity,
      height: 340,
      fit: BoxFit.cover,
    );
  }
}
