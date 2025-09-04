import 'package:permission_handler/permission_handler.dart';
import 'permission_constants.dart';

class PermissionHelper {
  /// Get platform-specific help text for a permission
  static Map<String, String> getPermissionHelp(Permission permission) {
    return PermissionConstants.permissionHelpMap[permission] ??
        PermissionConstants.getDefaultPermissionHelp(permission);
  }

  /// Check if permission is supported on current platform
  static bool isPermissionSupported(Permission permission) {
    // Add platform-specific logic here
    return true; // Simplified for now
  }

  /// Get user-friendly permission name
  static String getPermissionDisplayName(Permission permission) {
    return PermissionConstants.permissionDisplayNames[permission] ??
        permission.toString().split('.').last;
  }

  /// Group permissions by category
  static Map<String, List<Permission>> groupPermissionsByCategory(
    List<Permission> permissions,
  ) {
    final grouped = <String, List<Permission>>{};

    for (final permission in permissions) {
      final category = _getPermissionCategory(permission);
      grouped.putIfAbsent(category, () => []).add(permission);
    }

    return grouped;
  }

  static String _getPermissionCategory(Permission permission) {
    if ([Permission.camera, Permission.microphone].contains(permission)) {
      return 'Media';
    } else if ([Permission.photos, Permission.videos].contains(permission)) {
      return 'Storage';
    } else if ([Permission.locationWhenInUse, Permission.locationAlways]
        .contains(permission)) {
      return 'Location';
    }
    return 'Other';
  }
}
