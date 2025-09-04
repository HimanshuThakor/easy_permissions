import 'dart:async';
import 'package:flutter_easy_permission_manager/flutter_easy_permission_manager.dart';
import 'auto_permission_injector.dart';

class EasyPermissions {
  static const Duration _requestTimeout = Duration(seconds: 30);

  /// Request multiple permissions with auto-injection for missing ones
  static Future<PermissionResult> request(
    List<Permission> permissions, {
    PermissionConfig? config,
  }) async {
    if (permissions.isEmpty) {
      throw ArgumentError('Permissions list cannot be empty');
    }

    final result = PermissionResult();
    final configToUse = config ?? PermissionConfig.defaultConfig();

    try {
      for (final permission in permissions) {
        await _requestSinglePermissionWithAutoInjection(
          permission,
          result,
          configToUse,
        );
      }
    } catch (e) {
      if (configToUse.throwOnError) {
        rethrow;
      }
      if (configToUse.enableLogging) {
        print('Warning: Error processing permissions: $e');
      }
    }

    return result;
  }

  /// Request a single permission with auto-injection
  static Future<PermissionStatus> requestSingle(
    Permission permission, {
    PermissionConfig? config,
  }) async {
    final configToUse = config ?? PermissionConfig.defaultConfig();

    return await _requestSinglePermissionWithRetryAndAutoInjection(
      permission,
      configToUse,
    );
  }

  /// Enable/disable auto-injection globally
  static void setAutoInjectionEnabled(bool enabled) {
    AutoPermissionInjector.setEnabled(enabled);
  }

  /// Check if all permissions are granted
  static Future<bool> areAllGranted(List<Permission> permissions) async {
    if (permissions.isEmpty) return true;

    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) return false;
    }
    return true;
  }

  /// Get detailed status for multiple permissions
  static Future<Map<Permission, PermissionStatus>> getStatuses(
    List<Permission> permissions,
  ) async {
    final statuses = <Permission, PermissionStatus>{};

    for (final permission in permissions) {
      statuses[permission] = await permission.status;
    }

    return statuses;
  }

  /// Private method to handle single permission request with auto-injection
  static Future<void> _requestSinglePermissionWithAutoInjection(
    Permission permission,
    PermissionResult result,
    PermissionConfig config,
  ) async {
    try {
      final status = await _requestSinglePermissionWithRetryAndAutoInjection(
        permission,
        config,
      );

      if (status.isGranted) {
        result.granted.add(permission);
      } else if (status.isPermanentlyDenied) {
        result.permanentlyDenied.add(permission);

        if (config.openSettingsOnPermanentDenial) {
          if (config.enableLogging) {
            print(
                'Opening app settings for permanently denied permission: $permission');
          }
          await openAppSettings();
        }
      } else {
        result.denied.add(permission);
      }
    } on PermissionNotDeclaredException catch (e) {
      // Try auto-injection first
      final injected =
          await AutoPermissionInjector.injectMissingPermission(permission);

      if (injected) {
        // Permission was auto-injected, add to undeclared but don't throw
        result.undeclared.add(permission);

        print('\n🚀 Permission $permission was auto-injected!');
        print('⚠️  Please restart your app to use the permission.');

        if (!config.throwOnUndeclaredPermission) {
          return; // Don't throw, just log
        }
      }

      if (config.throwOnUndeclaredPermission) {
        rethrow;
      }

      result.undeclared.add(permission);
      if (config.enableLogging) {
        print('Warning: ${e.message}');
      }
    } catch (e) {
      if (config.throwOnError) {
        rethrow;
      }

      result.denied.add(permission);
      if (config.enableLogging) {
        print('Error requesting permission $permission: $e');
      }
    }
  }

  /// Private method with retry logic, timeout, and auto-injection
  static Future<PermissionStatus>
      _requestSinglePermissionWithRetryAndAutoInjection(
    Permission permission,
    PermissionConfig config,
  ) async {
    PermissionStatus status = await permission.status;

    // If already granted, return immediately
    if (status.isGranted) {
      return status;
    }

    // If permanently denied, don't try to request
    if (status.isPermanentlyDenied) {
      return status;
    }

    // Check if permission is declared by making a test request
    if (status.isDenied) {
      try {
        final firstRequest =
            await permission.request().timeout(_requestTimeout);

        // If the status didn't change from denied after request,
        // it might indicate the permission isn't declared
        if (status.isDenied && firstRequest.isDenied) {
          final help = PermissionHelper.getPermissionHelp(permission);
          throw PermissionNotDeclaredException(
            permission: permission,
            androidHelp: help['android']!,
            iosHelp: help['ios']!,
          );
        }
        status = firstRequest;
      } on TimeoutException {
        throw PermissionTimeoutException(permission);
      }
    }

    // Retry logic for denied permissions (but not permanently denied)
    int retryCount = 0;
    while (!status.isGranted &&
        !status.isPermanentlyDenied &&
        retryCount < config.maxRetries) {
      if (config.delayBetweenRetries.inMilliseconds > 0) {
        await Future.delayed(config.delayBetweenRetries);
      }

      try {
        status = await permission.request().timeout(_requestTimeout);
        retryCount++;

        if (config.enableLogging) {
          print('Retry $retryCount for $permission: $status');
        }
      } on TimeoutException {
        if (config.throwOnError) {
          throw PermissionTimeoutException(permission);
        }
        break;
      }
    }

    return status;
  }

  /// Restore manifest files from backup (useful for development)
  static Future<void> restoreManifestsFromBackup() async {
    final projectRoot = AutoPermissionInjector.findProjectRoot();
    if (projectRoot != null) {
      await AutoPermissionInjector.restoreFromBackup(projectRoot);
    }
  }

  /// Clean up backup files
  static Future<void> cleanBackupFiles() async {
    final projectRoot = AutoPermissionInjector.findProjectRoot();
    if (projectRoot != null) {
      await AutoPermissionInjector.cleanBackups(projectRoot);
    }
  }
}
