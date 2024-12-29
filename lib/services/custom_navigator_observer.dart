// What this code does:
// This custom NavigatorObserver checks for route changes and updates the
// _currentIndex of the HomeScreen to highlight the correct bottom navigation bar item.

// Filename: custom_navigator_observer.dart
import 'package:flutter/material.dart';

class CustomNavigatorObserver extends NavigatorObserver {
  final Function(String) onRouteChanged;

  CustomNavigatorObserver(this.onRouteChanged);

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    if (route.settings.name != null) {
      onRouteChanged(route.settings.name!);
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      onRouteChanged(route.settings.name!);
    }
  }
}
