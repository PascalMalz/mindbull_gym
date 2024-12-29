// What this code does:
// This Dart file defines a RouteNavigationManager class which is responsible for managing
// page navigation. It keeps a stack of previously visited pages to ensure that you return to
// the last state if you navigate back to a previously visited page.

import 'package:flutter/material.dart';

class RouteNavigationManager {
  final List<String> routeStack = [];

  // Pop until the specific route and then push to it if exists; otherwise, just push to the new route
  Future<void> navigateToRoute(BuildContext context, String route) async {
    if (routeStack.contains(route)) {
      // Pop until the specific route
      Navigator.popUntil(context, ModalRoute.withName(route));
    } else {
      // Push to the new route
      Navigator.pushNamed(context, route);
    }

    // Update the routeStack
    updateRouteStack(route);
  }

  // Update the route stack to remove any routes that come after the current one
  // And then add the current route at the top
  void updateRouteStack(String currentRoute) {
    int? existingIndex = routeStack.indexOf(currentRoute);
    if (existingIndex != null && existingIndex > -1) {
      routeStack.removeRange(existingIndex + 1, routeStack.length);
    }
    routeStack.add(currentRoute);
  }
}
