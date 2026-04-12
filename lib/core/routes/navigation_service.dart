import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static String? _lastRoute;
  static DateTime? _lastNavigationAt;

  static Future<T?>? navigateTo<T extends Object?>(
    String routeName, {
    Object? arguments,
    bool preventDuplicate = true,
  }) {
    if (preventDuplicate && _isDuplicateNavigation(routeName)) {
      debugPrint('[NavigationService] Duplicate navigation blocked: $routeName');
      return null;
    }

    debugPrint('[NavigationService] pushNamed: $routeName, args: $arguments');
    return navigatorKey.currentState
        ?.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?>? replaceWith<T extends Object?, TO extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    debugPrint(
      '[NavigationService] pushReplacementNamed: $routeName, args: $arguments',
    );
    return navigatorKey.currentState?.pushReplacementNamed<T, TO>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?>? clearAndNavigateTo<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) {
    debugPrint('[NavigationService] pushNamedAndRemoveUntil: $routeName');
    return navigatorKey.currentState?.pushNamedAndRemoveUntil<T>(
      routeName,
      (_) => false,
      arguments: arguments,
    );
  }

  static void goBack<T extends Object?>([T? result]) {
    final state = navigatorKey.currentState;
    if (state == null) return;

    if (state.canPop()) {
      debugPrint('[NavigationService] pop');
      state.pop(result);
    } else {
      debugPrint('[NavigationService] pop skipped: no route to pop');
    }
  }

  static bool _isDuplicateNavigation(String routeName) {
    final now = DateTime.now();

    if (_lastRoute == routeName && _lastNavigationAt != null) {
      final delta = now.difference(_lastNavigationAt!);
      if (delta.inMilliseconds < 400) {
        return true;
      }
    }

    _lastRoute = routeName;
    _lastNavigationAt = now;
    return false;
  }
}
