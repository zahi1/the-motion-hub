import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:math'; // For random selection

class VideoWidget extends StatefulWidget {
  final String videoPath;
  final bool isAsset;

  const VideoWidget({
    Key? key,
    required this.videoPath,
    this.isAsset = false,
  }) : super(key: key);

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool isLiked = false;

  // Predefined list of usernames and captions
  final List<String> usernames = [
    'user123', 'cool_rapper', 'tech_enthusiast', 'fitness_freak',
    'travel_blogger', 'foodie_chef', 'meme_master', 'artist_abc',
    'guitarist_007', 'photographer_x'
  ];

  final List<String> captions = [
    'Just nailed that new dance move! 💃 #dancechallenge',
    'Training hard for the next routine 🔥 #dancerlife',
    'Feeling the rhythm and owning the floor 🕺 #dancevibes',
    'Choreography on point today! 💥 #dancepractice',
    'Bringing my A-game to every step 👯 #dancingqueen',
    'Can’t stop, won’t stop dancing! 🎶 #dancefloorfrenzy',
    'Breaking a sweat, one move at a time 💦 #trainhard',
    'Grooving to the beat with all my heart 💖 #dancelife',
    'Every step is a step closer to perfection 🏆 #balletgoals',
    'When the music hits, I can’t stop dancing 💃 #danceaddict'
  ];

  String randomUsername = '';
  String randomCaption = '';

  @override
  void initState() {
    super.initState();

    // Randomly select a username and caption
    randomUsername = usernames[Random().nextInt(usernames.length)];
    randomCaption = captions[Random().nextInt(captions.length)];

    if (widget.isAsset) {
      _controller = VideoPlayerController.asset(widget.videoPath);
    } else {
      _controller = VideoPlayerController.network(widget.videoPath);
    }

    _controller.initialize().then((_) {
      setState(() {});
      _controller.play();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showShareDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Share Video'),
          content: TextField(
            controller: emailController,
            decoration: const InputDecoration(hintText: 'Enter recipient email'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                print('Video shared to: ${emailController.text}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Video shared with ${emailController.text}')),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Share'),
            ),
          ],
        );
      },
    );
  }

  void _showCommentDialog() {
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Comment'),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(hintText: 'Write your comment here'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                print('Comment: ${commentController.text}');
                Navigator.of(context).pop();
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Stack(
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 80,
          child: Column(
            children: [
              IconButton(
                iconSize: 28,
                icon: Icon(
                  Icons.favorite,
                  color: isLiked ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    isLiked = !isLiked;
                  });
                },
              ),
              const SizedBox(height: 12),
              IconButton(
                iconSize: 28,
                icon: const Icon(Icons.comment, color: Colors.white),
                onPressed: _showCommentDialog,
              ),
              const SizedBox(height: 12),
              IconButton(
                iconSize: 28,
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _showShareDialog,
              ),
            ],
          ),
        ),
        Positioned(
          left: 16,
          bottom: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                randomUsername,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                randomCaption,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    )
        : const Center(child: CircularProgressIndicator());
  }
}
