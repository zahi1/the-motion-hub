import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_model.dart';

class UserProvider with ChangeNotifier {
  String _username = '';
  String _profileName = '';
  String? _description; // User description
  final List<VideoModel> _uploadedVideos = [];
  final List<VideoModel> _assetVideos = [
    VideoModel(filePath: 'assets/videos/video1.mp4', uploadedBy: 'App', isAsset: true),
    VideoModel(filePath: 'assets/videos/video2.mp4', uploadedBy: 'App', isAsset: true),
    VideoModel(filePath: 'assets/videos/video3.mp4', uploadedBy: 'App', isAsset: true),
    VideoModel(filePath: 'assets/videos/video4.mp4', uploadedBy: 'App', isAsset: true),
  ];

  // Getters
  String get username => _username;
  String get profileName => _profileName;
  String? get description => _description;

  // Getter for the feed: combines uploaded videos with asset videos
  List<VideoModel> get uploadedVideos => [..._uploadedVideos, ..._assetVideos];

  // Getter for profile: includes only uploaded videos
  List<VideoModel> get profileVideos => [..._uploadedVideos];

  // Set username and profile name
  void setUser(String username, String profileName) async {
    _username = username;
    _profileName = profileName;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('profileName', profileName);

    notifyListeners();
  }

  // Update profile name
  void updateProfileName(String newName) async {
    _profileName = newName;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileName', newName);

    notifyListeners();
  }

  // Update user description
  void updateDescription(String newDescription) async {
    _description = newDescription;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('description', newDescription);

    notifyListeners();
  }

  // Add a video to uploaded videos
  void addVideo(VideoModel video) {
    _uploadedVideos.insert(0, video); // Insert new video at the beginning of the uploaded videos
    notifyListeners();
  }

  // Remove a video from uploaded videos by index
  void removeVideo(int index) async {
    if (index >= 0 && index < _uploadedVideos.length) {
      _uploadedVideos.removeAt(index);

      // Optional: Update any persistent storage if necessary
      notifyListeners();
    }
  }

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? '';
    _profileName = prefs.getString('profileName') ?? '';
    _description = prefs.getString('description') ?? '';
    notifyListeners();
  }
}
