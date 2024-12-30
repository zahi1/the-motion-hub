import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/video_model.dart';
import '../providers/user_provider.dart';

class UploadPage extends StatelessWidget {
  const UploadPage({Key? key}) : super(key: key);

  Future<void> _pickVideo(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      final video = VideoModel(
        filePath: pickedFile.path,
        uploadedBy: Provider.of<UserProvider>(context, listen: false).username,
      );
      Provider.of<UserProvider>(context, listen: false).addVideo(video);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video uploaded successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // Show message if no video was selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No video selected.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Video'),
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _pickVideo(context),
          child: const Text('Pick Video from Gallery'),
        ),
      ),
    );
  }
}
