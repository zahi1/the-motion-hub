import 'dart:io'; // For File class
import 'dart:math'; // For generating random numbers
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/video_widget.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _profilePicturePath;

  Future<void> _pickProfilePicture() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profilePicturePath = pickedFile.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  String _generateRandomViews() {
    final random = Random();
    return '${random.nextInt(900) + 100}K'; // Random views between 100K and 999K
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacementNamed('/login'); // Redirect to login page
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showSignOutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            // Profile Picture
            Center(
              child: GestureDetector(
                onTap: _pickProfilePicture,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profilePicturePath != null
                      ? FileImage(File(_profilePicturePath!))
                      : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                  child: _profilePicturePath == null
                      ? const Icon(Icons.camera_alt, size: 30, color: Colors.grey)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Editable Full Name
            GestureDetector(
              onLongPress: () {
                final nameController = TextEditingController(text: userProvider.profileName);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Edit Full Name'),
                    content: TextField(controller: nameController),
                    actions: [
                      TextButton(
                        onPressed: () {
                          userProvider.updateProfileName(nameController.text);
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  userProvider.profileName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Editable Username
            GestureDetector(
              onLongPress: () {
                final usernameController = TextEditingController(text: userProvider.username);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Edit Username'),
                    content: TextField(controller: usernameController),
                    actions: [
                      TextButton(
                        onPressed: () {
                          userProvider.setUser(usernameController.text, userProvider.profileName);
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '@${userProvider.username}',
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Editable Description
            GestureDetector(
              onLongPress: () {
                final descriptionController = TextEditingController(text: userProvider.description);
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Edit Description'),
                    content: TextField(
                      controller: descriptionController,
                      maxLines: 3,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          userProvider.updateDescription(descriptionController.text);
                          Navigator.pop(context);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  userProvider.description ?? 'Tap and hold to add a description...',
                  style: const TextStyle(fontSize: 14, color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Videos Section
            GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 9 / 16,
              ),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: userProvider.profileVideos.length,
              itemBuilder: (context, index) {
                final video = userProvider.profileVideos[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenVideoPage(videoPath: video.filePath),
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Remove Video'),
                        content: const Text('Do you want to remove this video?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              userProvider.removeVideo(index);
                              Navigator.pop(context);
                            },
                            child: const Text('Remove'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      VideoWidget(videoPath: video.filePath, isAsset: video.isAsset),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          color: Colors.black.withOpacity(0.5),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Text(
                            _generateRandomViews(),
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for Full-Screen Video Page
class FullScreenVideoPage extends StatelessWidget {
  final String videoPath;
  const FullScreenVideoPage({required this.videoPath, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: VideoWidget(videoPath: videoPath, isAsset: false),
      ),
    );
  }
}
