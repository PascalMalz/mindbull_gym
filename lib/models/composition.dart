import 'package:flutter/cupertino.dart';
import 'package:self_code/provider/user_data_provider.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';
import 'composition_audio.dart';
import 'composition_tag.dart';
//todo the user id should not be uuid when nothing is provided does not make sense what is the right way?

class Composition {
  final String id;
  final String title;
  final String description;
  DateTime? createdAt;
  DateTime? updatedAt;
  final List<CompositionAudio> compositionAudios;
  final List<CompositionTag> compositionTags;
  int duration;
  int durationInMilliseconds;
  final List<String> tags;
  TextEditingController descriptionController;
  final String user;

  Composition({
    String? id, // id is now an optional parameter
    required this.title,
    String? description,
    required this.createdAt,
    required this.updatedAt,
    required this.compositionAudios,
    required this.compositionTags,
    int? duration,
    int? durationInMilliseconds,
    List<String>? tags,
    String? user,
  }) : id = id ?? const Uuid().v4(),
        descriptionController = TextEditingController(text: description),
        description = description ?? '',
        duration = duration ?? 0,
        durationInMilliseconds = durationInMilliseconds ?? 0,
        user = user ?? '',
        tags = tags ?? [] ; // Generates a new UUID if id is not provided


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
  factory Composition.fromJson(Map<String, dynamic> json) {
    print('Composition.fromJson: Starting parsing');
    print('JSON Data: $json');
    var compositionAudiosList = json['composition_audios'] != null ? List.from(json['composition_audios']) : [];
    print('compositionAudiosList: $compositionAudiosList');
    var compositionTagsList = json['compositionTags'] != null ? List.from(json['compositionTags']) : [];
    print('compositionTagsList: $compositionTagsList');
    var duration = json['duration'] != null ? int.tryParse(json['duration'].toString()) ?? 0 : 0;
    print('Parsed duration: $duration');
    var durationInMilliseconds = json['durationMilliseconds'] != null ? int.tryParse(json['durationMilliseconds'].toString()) ?? 0 : 0;
    print('Parsed durationInMilliseconds: $durationInMilliseconds');
    var id = json['id'];
    print('Parsed id: $id');
    var title = json['title'];
    print('Parsed title: $title');
    var description = json['description'];
    print('Parsed description: $description');
    var createdAt = json['created_at'] != null ? DateTime.parse(json['created_at']) : null;
    print('Parsed createdAt: $createdAt');
    var updatedAt = json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null;
    print('Parsed updatedAt: $updatedAt');
    var user = json['user'] ?? '';
    print('Parsed user: $user');

    return Composition(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      compositionAudios: compositionAudiosList.map((e) => CompositionAudio.fromJson(e)).toList(),
      compositionTags: compositionTagsList.map((e) => CompositionTag.fromJson(e)).toList(),
      duration: duration,
      durationInMilliseconds: durationInMilliseconds,
      tags: _parseTags(json['tags']),
      user: user,
    );
  }

//todo check how and where the user id (owner should be set. If it is done like this it appears that the owner is always the one who does the post request.
  //final userDataProvider = getIt.get<UserDataProvider>();
  Map<String, dynamic> toJson() {
    return {
      'user': user,//userDataProvider.user?.id,
      'title': title,
      'description': description,
      'created_at__': createdAt?.toIso8601String(),
      'updated_at__': updatedAt?.toIso8601String(),
      'duration': duration,
      'durationMilliseconds': durationInMilliseconds,
      'user_frontend_id': user,
      'composition_audios': compositionAudios.map((e) => e.toJson()).toList(),
      'composition_tags': compositionTags.map((e) => e.toJson()).toList(),
      'tags': tags,
    };
  }



  @override
  String toString() {
    return 'Composition{id: $id, title: $title, description: $description, CompositionAudios: ${compositionAudios.length}, tags: $tags, user: $user}';
    // Add more fields to the string as necessary
  }


}
