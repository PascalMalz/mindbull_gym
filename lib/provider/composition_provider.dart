import 'package:flutter/foundation.dart';
import '../models/composition.dart';

class CompositionProvider extends ChangeNotifier {
  List<Composition> compositions = [];
  String listDescription = "";
  String listTitle = "";
  List<String> listTags = [];

  // Methods to manage compositions
  void addComposition(Composition composition) {
    compositions.add(composition);
    notifyListeners();
  }

  void removeComposition(Composition composition) {
    compositions.remove(composition);
    notifyListeners();
  }

  // Methods to manage list details
  void setListTitle(String title) {
    listTitle = title;
    notifyListeners();
  }

  void setListDescription(String description) {
    listDescription = description;
    notifyListeners();
  }

  void setListTags(List<String> tags) {
    listTags = tags;
    notifyListeners();
  }


  void clearList() {
    compositions.clear();
    listDescription = "";
    listTitle = "";
    listTags = [];
    notifyListeners();
  }
}