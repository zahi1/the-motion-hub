import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/video_widget.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final videos = Provider.of<UserProvider>(context).uploadedVideos;

    return Scaffold(
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return VideoWidget(
            videoPath: videos[index].filePath,
            isAsset: videos[index].isAsset,
          );
        },
      ),
    );
  }
}
