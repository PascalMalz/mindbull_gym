//Api to post compositions with optional image
//All clientAppAudioFilePath of the composition are extracted from jsonEncode(composition.toJson())
//titles also by basename(clientAppAudioFilePath)
//Everything is attached with the related audio files to the post load together with the composition (jsonEncode(composition.toJson()))).

import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:self_code/provider/user_data_provider.dart';
import '../main.dart';
import '../models/composition.dart';
import '../provider/auth_provider.dart';
import 'token_handler.dart'; // Import your TokenHandler

class ApiPostPost {
  static final Dio dio = Dio(); // Create a Dio instance
  TokenHandler tokenHandler = TokenHandler();
  final userDataProvider = getIt.get<UserDataProvider>();

  Future<String?> uploadPost({
    File? imageFile,
    File? audioFile,
    Composition? composition,
    String? description,
    List<String>? tags,
    Function(int, int)? onUploadProgress, // Added a callback function for upload progress
  }) async {
    final String apiUrl = 'https://neurotune.de/api/post_content/'; // Replace with your actual API endpoint
    final String authToken = await tokenHandler.getAccessToken();

    // Set headers including the Authorization token
    final Map<String, String> headers = {
      'Content-Type': 'multipart/form-data',
      'Authorization': 'Bearer $authToken',
    };

    FormData formData = FormData();

    if (imageFile != null) {
      String fileName = basename(imageFile.path);
      formData.files.add(
        MapEntry(
          "image",
          await MultipartFile.fromFile(imageFile.path, filename: fileName),
        ),
      );
    }


    if (composition != null) {
      // Extract all unique audio file details from the composition JSON string
      Set<AudioFileDetails> audioDetails = extractAudioDetails(jsonEncode(composition.toJson()));

      // Attach each unique audio file to FormData
      for (AudioFileDetails details in audioDetails) {
        formData.files.add(
          MapEntry(
            details.filePath, // Use the exact clientAppAudioFilePath as key
            await MultipartFile.fromFile(details.filePath, filename: details.title),
          ),
        );
      }

      // Attach the composition JSON
      formData.fields.add(MapEntry("composition", jsonEncode(composition.toJson())));
    }


    // Add other post details to FormData
    formData.fields..add(MapEntry("description", description ?? ""))..add(
        MapEntry("user", userDataProvider.currentUser?.id ?? ''))..add(
        MapEntry("tags", tags?.join(',') ?? ""));
    print('Api request started with ${userDataProvider.currentUser?.id}');
    // Make a POST request
    printFormDataDetails(formData);
    try {
      Response response = await dio.post(
        apiUrl,
        data: formData,
        options: Options(headers: headers),
        onSendProgress: (int sent, int total) {
          // This callback is periodically called during the upload
          // You can use this to update your UI or send progress updates
          if (onUploadProgress != null) {
            onUploadProgress(sent, total);
          }
        },
      );
// Check for success response
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return "Post uploaded successfully";
      } else {
        return "Failed to upload post: ${response.statusCode} ${response.data}";
      }
    } on DioException catch (dioError) {
      // Check for authentication error
      if (dioError.response != null) {
        if (dioError.response!.statusCode == 413) {
          return "File too large. Please reduce the file size and try again.";
        }
        if (dioError.response!.statusCode == 401 || dioError.response!.statusCode == 403) {
          // Authentication error with a more user-friendly message
          return "Not logged in. Please log in to continue.";
        }
        // Handle other DioErrors with response
        print("DioError: ${dioError.message}");
        print("Status Code: ${dioError.response!.statusCode}");
        print("Data: ${dioError.response!.data}");
        return "Failed to upload post: ${dioError.response!.statusCode} ${dioError.response!.data}";
      } else {
        // Error before response is received
        return "DioError: No response received: ${dioError.message}";
      }
    } catch (e) {
      // Handle any other errors
      return "Error uploading post: $e";
    }
  }

  void printFormDataDetails(FormData formData) {
    print("----- Form Data Details -----");

    // Print files with more details
    for (var fileEntry in formData.files) {
      var file = fileEntry.value;
      print("File - Key: ${fileEntry.key}");
      print("\tFilename: ${file.filename}");
      print("\tLength: ${file.length}");
      print("\tContent-Type: ${file.contentType}");
      // Add more file details here as needed
    }

    // Print fields in chunks
    for (var field in formData.fields) {
      print("Field - Key: ${field.key}");
      // If the field value is too long, break it down.
      const chunkSize = 800; // Define a suitable chunk size
      if (field.value.length > chunkSize) {
        for (int i = 0; i < field.value.length; i += chunkSize) {
          print("\tValue chunk: ${field.value.substring(i, i + chunkSize > field.value.length ? field.value.length : i + chunkSize)}");
        }
      } else {
        print("\tValue: ${field.value}");
      }
    }
  }

}

// Define a custom class to hold both file path and audio title
class AudioFileDetails {
  final String filePath;
  final String title;

  AudioFileDetails(this.filePath, this.title);
}

Set<AudioFileDetails> extractAudioDetails(String compositionJson) {
  RegExp regex = RegExp(r'"clientAppAudioFilePath":"(.*?)"');
  Iterable<RegExpMatch> matches = regex.allMatches(compositionJson);
  Set<AudioFileDetails> audioDetails = {};
  for (var match in matches) {
    String filePath = match.group(1)!;
    String title = basename(filePath);
    print('filePath: $filePath, title: $title');
    audioDetails.add(AudioFileDetails(filePath, title)); // Add the extracted details
  }
  return audioDetails;
}