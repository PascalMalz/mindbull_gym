import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';
import '../provider/user_data_provider.dart';


//Most of the fields have to be named in line with composition fields!!! (See JoinPage return)
class Audio {
  final String id;
  final String title;
  String description;
  final String clientAppAudioFilePath;
  int duration;
  int durationInMilliseconds;
  final List<String> tags;
  final String username;
  final String customFileName;
  final String userTimeStamp;
  TextEditingController descriptionController;

  Audio({
    required this.title,
    String? description,
    String? clientAppAudioFilePath,
    int? duration,
    int? durationInMilliseconds,
    String? id,
    List<String>? tags,
    String? username,
    this.customFileName = '',
    String? userTimeStamp,
  }) :  id = id ?? const Uuid().v4(),
        tags = tags ?? [], // Set default value here;
        descriptionController = TextEditingController(text: description),
        description = description ?? '',
        clientAppAudioFilePath = clientAppAudioFilePath ?? '',
        duration = duration ?? 0,
        durationInMilliseconds = durationInMilliseconds ?? 0,
        username = username ?? '',
        userTimeStamp = userTimeStamp ?? '';

  factory Audio.fromJson(Map<String, dynamic> json) {
    print('Audio.fromJson: Starting parsing');
    print('JSON Data: $json');

    var title = json['customFileName'] != null && json['customFileName'] != ''
        ? json['customFileName']
        : json['title'] ?? 'Unknown Title';
    print('Parsed title: $title');

    var description = json['description'] ?? '';
    print('Parsed description: $description');

    var duration = json['duration'] != null ? int.tryParse(json['duration'].toString()) ?? 0 : 0;
    print('Parsed duration: $duration');

    var durationInMilliseconds = json['durationMilliseconds'] != null ? int.tryParse(json['durationMilliseconds'].toString()) ?? 0 : 0;
    print('Parsed durationInMilliseconds: $durationInMilliseconds');

    var clientAppAudioFilePath = json['clientAppAudioFilePath'] != null
        ? 'https://neurotune.de' + json['clientAppAudioFilePath']
        : '';

    print('Parsed clientAppAudioFilePath: $clientAppAudioFilePath');

    var id = json['ID'] ?? '';
    print('Parsed id: $id');

    var tags = _parseTags(json['tags']);
    print('Parsed tags: $tags');

    var username = json['username'] ?? '';
    print('Parsed username: $username');

    var customFileName = json['customFileName'] ?? '';
    print('Parsed customFileName: $customFileName');

    var userTimeStamp = json['userTimeStamp'] == null ? '' : json['userTimeStamp'] ?? '';
    print('Parsed userTimeStamp: $userTimeStamp');

    return Audio(
      title: title,
      description: description,
      duration: duration,
      durationInMilliseconds: durationInMilliseconds,
      clientAppAudioFilePath: clientAppAudioFilePath,
      id: id,
      tags: tags,
      username: username,
      customFileName: customFileName,
      userTimeStamp: userTimeStamp,
    );
  }

// Helper method to parse tags
  static List<String> _parseTags(dynamic tags) {
    if (tags is String) {
      return tags.split(',').map((tag) => tag.trim()).toList();
    } else if (tags is List) {
      return List<String>.from(tags);
    } else {
      return [];
    }
  }

  //final userDataProvider = getIt.get<UserDataProvider>();
  Map<String, dynamic> toJson() {
    return {
      'audio_title': title,
      'description': description,
      'clientAppAudioFilePath': clientAppAudioFilePath,
      'duration': duration,
      'durationMilliseconds': durationInMilliseconds,
      'frontend_id': id,
      'tags': tags,
      'user': username,//userDataProvider.user?.id,
      'customFileName': customFileName,
      'userTimeStamp': userTimeStamp,
    };
  }

  @override
  String toString() {
    return 'AudioFile('
        'Title: $title, '
        'Description: $description, '
        'Client App Audio File Path: $clientAppAudioFilePath, '
        'Duration: $duration, '
        'Duration Milliseconds: $durationInMilliseconds, '
        'id: $id, '
        'Tags: ${tags.join(", ")}, '
        'Username: $username, '
        'Custom File Name: $customFileName, '
        'User Timestamp: $userTimeStamp'
        ')';
  }


}
