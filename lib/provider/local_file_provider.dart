import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/audio.dart';
import '../models/composition.dart';

class LocalFilesProvider with ChangeNotifier {
  List<dynamic> _localItems = [];

  List<dynamic> get localItems => _localItems;

  Future<void> loadLocalItems() async {
    var audioBox = Hive.box('audioMetadata');
    var compositionBox = Hive.box<Composition>('compositionMetadata');

    List audioFiles = audioBox.values.toList();
    List<Composition> compositions = compositionBox.values.toList();

    _localItems = [...audioFiles, ...compositions];

    notifyListeners();
  }
}
