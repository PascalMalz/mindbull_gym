// Filename: scroll_position_notifier.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScrollPositionNotifier with ChangeNotifier {
  double _position = 0.0;

  double get position => _position;

  set position(double newPosition) {
    _position = newPosition;
    notifyListeners();
  }

  Future<void> saveScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('scroll_position', _position);
  }

  Future<void> loadScrollPosition() async {
    final prefs = await SharedPreferences.getInstance();
    _position = prefs.getDouble('scroll_position') ?? 0.0;
    notifyListeners();
  }
}
