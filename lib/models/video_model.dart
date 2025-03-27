class VideoModel {
  final String filePath;
  final String uploadedBy;
  final bool isAsset; // Add this field to indicate if the video is an asset or user-uploadeded

  VideoModel({
    required this.filePath,
    required this.uploadedBy,
    this.isAsset = false, // Default to false for user-uploaded videos
  });
}
