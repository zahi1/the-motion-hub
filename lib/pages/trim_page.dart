/*
//Uncompleted yet
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:path_provider/path_provider.dart';
import '../models/video_model.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class TrimPage extends StatefulWidget {
  final String videoPath;

  const TrimPage({Key? key, required this.videoPath}) : super(key: key);

  @override
  _TrimPageState createState() => _TrimPageState();
}

class _TrimPageState extends State<TrimPage> {
  final Trimmer _trimmer = Trimmer();
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isPlaying = false;
  bool isLoading = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndLoadVideo();
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.videos,
      Permission.photos,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<void> _checkPermissionsAndLoadVideo() async {
    try {
      final hasPermissions = await _requestPermissions();
      if (!hasPermissions) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please grant storage permissions to trim videos'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      await _loadVideo();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadVideo() async {
    try {
      final file = File(widget.videoPath);
      if (!await file.exists()) {
        throw Exception('Video file does not exist at ${widget.videoPath}');
      }

      await _trimmer.loadVideo(videoFile: file);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading video: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<String> _getOutputPath() async {
    final Directory? appDocDir = await getExternalStorageDirectory();
    if (appDocDir == null) {
      throw Exception('Could not access external storage');
    }

    final String outputDirPath = path.join(appDocDir.path, 'trimmed_videos');
    final Directory outputDir = Directory(outputDirPath);
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return path.join(outputDirPath, 'trimmed_video_$timestamp.mp4');
  }

  Future<void> _saveTrimmedVideo(BuildContext context) async {
    if (!_isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for video to initialize')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final String outputPath = await _getOutputPath();

      await _trimmer.saveTrimmedVideo(
        startValue: _startValue,
        endValue: _endValue,
        onSave: (String? outputPath) async {
          if (outputPath != null) {
            final video = VideoModel(
              filePath: outputPath,
              uploadedBy: Provider.of<UserProvider>(context, listen: false).username,
            );

            Provider.of<UserProvider>(context, listen: false).addVideo(video);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Video saved to: $outputPath'),
                  duration: const Duration(seconds: 3),
                ),
              );
              Navigator.pop(context);
            }
          } else {
            throw Exception('Failed to save trimmed video');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving video: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _togglePlay() async {
    if (!_isInitialized) return;

    setState(() {
      _isPlaying = !_isPlaying;
    });

    try {
      if (_isPlaying) {
        await _trimmer.videoPlayerController?.play();
      } else {
        await _trimmer.videoPlayerController?.pause();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error controlling playback: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trim Video'),
      ),
      body: !_isInitialized
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading video...'),
          ],
        ),
      )
          : isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Saving trimmed video...'),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: VideoViewer(trimmer: _trimmer),
          ),
          Center(
            child: TrimViewer(
              trimmer: _trimmer,
              viewerHeight: 50.0,
              viewerWidth: MediaQuery.of(context).size.width * 0.9,
              maxVideoLength: const Duration(minutes: 10),
              onChangeStart: (value) => _startValue = value,
              onChangeEnd: (value) => _endValue = value,
              onChangePlaybackState: (value) =>
                  setState(() => _isPlaying = value),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _togglePlay,
                child: Text(_isPlaying ? 'Pause' : 'Play'),
              ),
              ElevatedButton(
                onPressed: () => _saveTrimmedVideo(context),
                child: const Text('Save'),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }
}*/
