import 'package:flutter/material.dart';
import '../widgets/video_widget.dart';

class FullViewPage extends StatelessWidget {
  final String videoPath;
  final bool isAsset;

  const FullViewPage({
    Key? key,
    required this.videoPath,
    this.isAsset = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VideoWidget(
        videoPath: videoPath,
        isAsset: isAsset,
        isFullScreen: true, // Enable full-screen mode
      ),
    );
  }
}
