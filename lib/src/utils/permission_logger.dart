import 'package:flutter/cupertino.dart';

import '../../flutter_easy_permission_manager.dart';

extension PermissionNameExtension on Permission {
  /// Converts "Permission.camera" → "camera"
  String get displayName => toString().split('.').last;
}

class PermissionLogger {
  static void log(PermissionResult result) {
    if (result.allGranted) {
      debugPrint("✅ All permissions granted!");
      return;
    }

    for (final p in result.denied) {
      debugPrint("❌ Permission ${p.displayName} was denied by user.");
    }

    for (final p in result.permanentlyDenied) {
      debugPrint(
        "⛔ Permission ${p.displayName} is permanently denied.\n"
        "👉 User must enable it manually in system settings.\n",
      );
    }

    if (result.undeclared.isNotEmpty) {
      final undeclaredList =
          result.undeclared.map((e) => e.displayName).join(",");

      for (final p in result.undeclared) {
        final help = PermissionHelper.getPermissionHelp(p);

        debugPrint(
          "🚨 Missing Permission Declaration\n"
          "--------------------------------\n"
          "❌ Permission: ${p.displayName}\n\n"
          "👉 Android:\n${help['android']}\n\n"
          "👉 iOS:\n${help['ios']}\n\n"
          "👉 Quick fix:\n"
          "   dart run flutter_easy_permission_manager:auto_inject_permissions -p $undeclaredList\n"
          "--------------------------------",
        );
      }
    }
  }
}
