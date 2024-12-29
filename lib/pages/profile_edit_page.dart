// Filename: bio_edit_page.dart

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import '../api/api_user_profile_upload.dart';
import '../provider/user_data_provider.dart';


class ProfileEditPage extends StatefulWidget {
  @override
  _ProfileEditPageState createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final TextEditingController _bioController = TextEditingController();

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDataProvider = Provider.of<UserDataProvider>(context, listen: false);
    // Assuming currentUser is non-null. Make sure to handle nullability as per your app logic.
    _bioController.text = userDataProvider.currentUser?.bio ?? '';

    return Scaffold(

      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
              ),
              maxLines: null, // Makes it expandable
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _updateBio(_bioController.text);
                // Implement your logic to update the bio here
                // For example: userDataProvider.updateBio(_bioController.text);
                Navigator.pop(context); // Return to the previous screen
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBio(String newBio) async {
    if (newBio.isEmpty) {
      // Optionally, show an error or feedback to the user
      print('Bio cannot be empty');
      return;
    }

    final apiUserProfileUpload = GetIt.I<ApiUserProfileUpload>();
    try {
      // Call the method to update the bio in your API
      final String? response = await apiUserProfileUpload.updateBio(newBio);
      if (response == null) {
        // Handle success
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bio updated successfully')));
      } else {
        // Handle the error response from your API
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update bio: $response')));
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating bio: $e')));
    }
  }


}
