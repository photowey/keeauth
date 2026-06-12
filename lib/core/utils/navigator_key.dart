import 'package:flutter/material.dart';

/// Global key for the root navigator.
/// Use [rootNavigatorKey.currentContext] to show dialogs from contexts
/// that may have been deactivated (e.g. after popping a bottom sheet).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
