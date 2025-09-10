import 'dart:async';
import 'package:flutter_easy_permission_manager/flutter_easy_permission_manager.dart';
import '../utils/permission_logger.dart';
import 'auto_permission_injector.dart';
import 'package:logging/logging.dart'; // Import the logging package

// Define a logger for this class
final _logger = Logger('EasyPermissions');

class EasyPermissions {
  static const Duration _requestTimeout = Duration(seconds: 30);

  // Optional: Initialize logging in a static block or an init method
  // if you want to configure it globally for your app when this class is first used.
  // For this example, we'll assume logging is configured elsewhere (e.g., in main.dart)
  // or you can add a static method:
  static void initializeLogging({Level level = Level.INFO}) {
    Logger.root.level = level;
    Logger.root.onRecord.listen((record) {
      print(
          '${record.level.name}: ${record.time}: ${record.loggerName}: ${record.message}');
      if (record.error != null) {
        print('  Error: ${record.error}');
      }
      if (record.stackTrace != null) {
        print('  StackTrace: ${record.stackTrace}');
      }
    });
    _logger.info('EasyPermissions logging initialized.');
  }

  /// Request multiple permissions with auto-injection for missing ones
  static Future<PermissionResult> request(
    List<Permission> permissions, {
    PermissionConfig? config,
  }) async {
    if (permissions.isEmpty) {
      _logger.warning('Attempted to request an empty list of permissions.');
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

      // ✅ Only log after all permissions have been processed
      PermissionLogger.log(result);
    } catch (e, s) {
      if (configToUse.throwOnError) {
        _logger.severe('Error processing permissions, rethrowing.', e, s);
        rethrow;
      }
      _logger.warning('Error processing permissions (suppressed): $e', e, s);
      if (configToUse.enableLogging && e is! PermissionException) {
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
    _logger.fine(
        'Requesting single permission: $permission with config: $configToUse');

    try {
      return await _requestSinglePermissionWithRetryAndAutoInjection(
        permission,
        configToUse,
      );
    } on PermissionException catch (e, s) {
      _logger.warning(
          'PermissionException in requestSingle for $permission: ${e.message}',
          e,
          s);
      if (configToUse.throwOnError ||
          (e is PermissionNotDeclaredException &&
              configToUse.throwOnUndeclaredPermission)) {
        rethrow;
      }
      // If not throwing, determine a fallback status or rely on the status from within the caught exception if appropriate
      // For now, if not rethrown, this path will lead to a non-granted status being returned if the exception occurred before a status was determined.
      // Or, more robustly, ensure _requestSinglePermissionWithRetryAndAutoInjection always returns a status or throws.
      // Based on its current structure, it will throw or return a status.
      // We might want to return a specific status if an error is caught and suppressed here.
      // e.g., return PermissionStatus.denied; or whatever makes sense.
      // For now, let's assume if it throws, it's handled by rethrow or caught by caller.
      // If it was caught and suppressed inside _requestSinglePermissionWithRetryAndAutoInjection, this catch won't hit.
      rethrow; // Or handle more gracefully, e.g. return PermissionStatus.denied
    } catch (e, s) {
      _logger.severe('Unexpected error in requestSingle for $permission', e, s);
      if (configToUse.throwOnError) {
        rethrow;
      }
      return PermissionStatus
          .denied; // Fallback for unexpected errors if not rethrowing
    }
  }

  /// Enable/disable auto-injection globally
  static void setAutoInjectionEnabled(bool enabled) {
    _logger.info('Auto-injection globally set to: $enabled');
    AutoPermissionInjector.setEnabled(enabled);
  }

  /// Check if all permissions are granted
  static Future<bool> areAllGranted(List<Permission> permissions) async {
    if (permissions.isEmpty) return true;
    _logger.finer('Checking if all permissions are granted for: $permissions');

    for (final permission in permissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        _logger.finer('Permission $permission is not granted. Status: $status');
        return false;
      }
    }
    _logger.finer('All permissions are granted for: $permissions');
    return true;
  }

  /// Get detailed status for multiple permissions
  static Future<Map<Permission, PermissionStatus>> getStatuses(
    List<Permission> permissions,
  ) async {
    _logger.finer('Getting statuses for permissions: $permissions');
    final statuses = <Permission, PermissionStatus>{};

    for (final permission in permissions) {
      try {
        statuses[permission] = await permission.status;
      } catch (e, s) {
        _logger.warning(
            'Failed to get status for permission $permission', e, s);
        // Decide what to put in the map for this permission, e.g., a specific error status or skip it.
        // For now, let's assume permission.status itself handles its errors or we skip.
        // If permission.status can throw, and we want to continue, we should handle it.
      }
    }
    _logger.finer('Statuses retrieved: $statuses');
    return statuses;
  }

  /// Private method to handle single permission request with auto-injection
  static Future<void> _requestSinglePermissionWithAutoInjection(
    Permission permission,
    PermissionResult result,
    PermissionConfig config,
  ) async {
    _logger.fine('_requestSinglePermissionWithAutoInjection for $permission');
    try {
      final status = await _requestSinglePermissionWithRetryAndAutoInjection(
        permission,
        config,
      );

      if (status.isGranted) {
        _logger.info('Permission $permission GRANTED.');
        result.granted.add(permission);
      } else if (status.isPermanentlyDenied) {
        _logger.warning('Permission $permission PERMANENTLY DENIED.');
        result.permanentlyDenied.add(permission);

        if (config.openSettingsOnPermanentDenial) {
          if (config.enableLogging) {
            // Keep existing print for consistency or replace
            print(
                'Opening app settings for permanently denied permission: $permission');
          }
          _logger.info(
              'Opening app settings for permanently denied permission: $permission');
          await openAppSettings(); // Ensure this function also has error handling or logging
        }
      } else {
        // Denied but not permanently
        _logger.info('Permission $permission DENIED.');
        result.denied.add(permission);
      }
    } on PermissionNotDeclaredException catch (e, s) {
      _logger.warning('Permission $permission not declared in manifest.', e, s);
      // Try auto-injection first
      final injected =
          await AutoPermissionInjector.injectMissingPermission(permission);

      if (injected) {
        _logger.info('Permission $permission was auto-injected! Restart app.');
        result.undeclared
            .add(permission); // Add to undeclared as it was missing initially

        // Keep existing prints for user feedback, or integrate into a more formal user notification system
        print('\n🚀 Permission $permission was auto-injected!');
        print('⚠️  Please restart your app to use the permission.');

        if (!config.throwOnUndeclaredPermission) {
          _logger.info(
              'Auto-injection successful for $permission, not throwing as per config.');
          return; // Don't throw, just log
        }
        // If throwOnUndeclaredPermission is true, it will fall through to the rethrow
      }

      // If not injected OR if injected but throwOnUndeclaredPermission is true
      if (config.throwOnUndeclaredPermission) {
        _logger.severe(
            'Throwing PermissionNotDeclaredException for $permission as per config.',
            e,
            s);
        rethrow;
      }

      result.undeclared.add(permission); // Ensure it's added if not rethrown
      // The existing print for config.enableLogging is fine here, or use logger
      if (config.enableLogging) {
        // print('Warning: ${e.message}'); // Original
        _logger.warning(
            'Undeclared permission ${e.permission}: ${e.message} (logging enabled)');
      }
    } on PermissionTimeoutException catch (e, s) {
      // Specific catch for Timeout
      _logger.log(
          Level('', 1), 'Timeout requesting permission $permission', e, s);
      if (config.throwOnError) {
        rethrow;
      }
      result.denied.add(permission); // Treat timeout as denied if not throwing
    } catch (e, s) {
      // Catch other generic errors
      _logger.severe(
          'Error in _requestSinglePermissionWithAutoInjection for $permission',
          e,
          s);
      if (config.throwOnError) {
        rethrow;
      }

      result.denied
          .add(permission); // Add to denied if error caught and not rethrown
      if (config.enableLogging) {
        // Keep existing print or replace
        // print('Error requesting permission $permission: $e'); // Original
        _logger.warning(
            'Error requesting permission $permission: $e (logging enabled)',
            e,
            s);
      }
    }
  }

  /// Private method with retry logic, timeout, and auto-injection
  static Future<PermissionStatus>
      _requestSinglePermissionWithRetryAndAutoInjection(
    Permission permission,
    PermissionConfig config,
  ) async {
    _logger.fine(
        '_requestSinglePermissionWithRetryAndAutoInjection for $permission');
    PermissionStatus status = await permission.status;

    if (status.isGranted) {
      _logger.info('Permission $permission already granted.');
      return status;
    }

    if (status.isPermanentlyDenied) {
      _logger.warning(
          'Permission $permission is permanently denied. Not requesting.');
      return status;
    }

    // Check if permission is declared by making a test request
    if (status.isDenied) {
      // Only attempt if initially denied
      try {
        _logger.finer(
            'Performing initial request for $permission to check declaration.');
        final firstRequest =
            await permission.request().timeout(_requestTimeout);
        _logger.finer(
            'Initial request for $permission resulted in: $firstRequest');

        // If the status didn't change from denied after request,
        // it might indicate the permission isn't declared
        // This logic needs to be careful: permission.request() should change status if successful.
        // If it's still denied, it could be user denial OR not declared.
        // The original check was: `status.isDenied && firstRequest.isDenied`
        // `status` here refers to the status *before* `firstRequest`.
        // A more direct way to check if it's not declared might involve platform-specific checks,
        // but this heuristic is common.
        if (status.isDenied && firstRequest.isDenied) {
          // status here is the one before firstRequest
          final help = PermissionHelper.getPermissionHelp(permission);
          _logger.warning(
              'Permission $permission appears undeclared. Throwing PermissionNotDeclaredException.');
          throw PermissionNotDeclaredException(
            permission: permission,
            androidHelp: help['android']!,
            iosHelp: help['ios']!,
          );
        }
        status = firstRequest;
      } on TimeoutException catch (e, s) {
        // Catch TimeoutException specifically
        _logger.severe('Timeout during initial request for $permission.', e, s);
        throw PermissionTimeoutException(
            permission); // Rethrow as specific permission timeout
      } on PermissionNotDeclaredException {
        // If it's already this type, rethrow
        rethrow;
      } catch (e, s) {
        // Catch any other error during initial request
        _logger.severe(
            'Error during initial request for $permission: $e', e, s);
        // Decide how to handle this. If it's not a timeout or undeclared,
        // it's an unexpected issue with permission.request() itself.
        // Depending on `config.throwOnError` it might be rethrown by the caller.
        // For now, we'll let it propagate if it's not a Timeout.
        // If it's critical, rethrow:
        // if (config.throwOnError) rethrow;
        // Or, assume it means denied and proceed to retries if applicable.
        // For safety, if it's not a known exception, let's treat it as a failure of this step.
        // This is a bit tricky, as permission.request() itself might throw other things.
        // The original code only explicitly threw PermissionTimeoutException.
        // Let's assume other errors are caught by the calling function's try-catch.
        // For more robustness, one might wrap permission.request() more tightly.
      }
    }

    // Retry logic for denied permissions (but not permanently denied)
    int retryCount = 0;
    while (!status.isGranted &&
        !status.isPermanentlyDenied &&
        retryCount < config.maxRetries) {
      _logger.info(
          'Attempting retry ${retryCount + 1}/${config.maxRetries} for $permission. Current status: $status');
      if (config.delayBetweenRetries.inMilliseconds > 0) {
        _logger.finer(
            'Delaying ${config.delayBetweenRetries.inMilliseconds}ms before next retry for $permission.');
        await Future.delayed(config.delayBetweenRetries);
      }

      try {
        status = await permission.request().timeout(_requestTimeout);
        retryCount++;

        if (config.enableLogging) {
          // Keep existing print or replace
          // print('Retry $retryCount for $permission: $status'); // Original
          _logger.info(
              'Retry $retryCount for $permission completed. New status: $status');
        }
      } on TimeoutException catch (e, s) {
        // Catch TimeoutException specifically
        _logger.severe(
            'Timeout during retry $retryCount for $permission.', e, s);
        if (config.throwOnError) {
          throw PermissionTimeoutException(
              permission); // Rethrow as specific permission timeout
        }
        _logger.warning(
            'Timeout on retry for $permission, breaking retry loop (throwOnError=false).');
        break; // Exit retry loop if timeout and not throwing
      } catch (e, s) {
        _logger.severe(
            'Unexpected error during retry $retryCount for $permission: $e',
            e,
            s);
        if (config.throwOnError) {
          rethrow; // Rethrow unexpected error during retry if configured
        }
        // If not throwing, we might break or let the loop condition handle it.
        // Let's break to avoid infinite loops on unexpected persistent errors.
        _logger.warning(
            'Unexpected error on retry for $permission, breaking retry loop (throwOnError=false).');
        break;
      }
    }
    _logger.fine('Finished retry logic for $permission. Final status: $status');
    return status;
  }

  /// Restore manifest files from backup (useful for development)
  static Future<void> restoreManifestsFromBackup() async {
    _logger.info('Attempting to restore manifests from backup.');
    final projectRoot = AutoPermissionInjector.findProjectRoot();
    if (projectRoot != null) {
      await AutoPermissionInjector.restoreFromBackup(projectRoot);
      _logger.info('Manifests restored from backup for project: $projectRoot');
    } else {
      _logger.warning('Could not find project root to restore manifests.');
    }
  }

  /// Clean up backup files
  static Future<void> cleanBackupFiles() async {
    _logger.info('Attempting to clean up backup manifest files.');
    final projectRoot = AutoPermissionInjector.findProjectRoot();
    if (projectRoot != null) {
      await AutoPermissionInjector.cleanBackups(projectRoot);
      _logger.info('Backup manifest files cleaned for project: $projectRoot');
    } else {
      _logger.warning('Could not find project root to clean backup files.');
    }
  }
}

// Assuming these exception classes are defined elsewhere (as in your context)
// For example:
// class PermissionException implements Exception {
//   final Permission permission;
//   final String message;
//   PermissionException(this.permission, this.message);
//   @override
//   String toString() => '$runtimeType: $message (Permission: $permission)';
// }

// class PermissionNotDeclaredException extends PermissionException {
//   final String androidHelp;
//   final String iosHelp;
//   PermissionNotDeclaredException({
//     required Permission permission,
//     this.androidHelp = "",
//     this.iosHelp = "",
//   }) : super(permission, "Permission $permission is not declared in the manifest.");
// }

// class PermissionTimeoutException extends PermissionException {
//   PermissionTimeoutException(Permission permission)
//       : super(permission, "Timeout waiting for permission $permission request.");
// }

// --- Helper stubs for classes/methods used in EasyPermissions ---
// These would be part of your actual flutter_easy_permission_manager or permission_handler
// enum Permission { camera, photos, location } // Example
// enum PermissionStatus { granted, denied, permanentlyDenied, restricted, limited }

// extension PermissionStatusGetters on PermissionStatus {
//   bool get isGranted => this == PermissionStatus.granted;
//   bool get isDenied => this == PermissionStatus.denied;
//   bool get isPermanentlyDenied => this == PermissionStatus.permanentlyDenied;
// }

// class PermissionResult {
//   final List<Permission> granted = [];
//   final List<Permission> denied = [];
//   final List<Permission> permanentlyDenied = [];
//   final List<Permission> undeclared = [];
// }

// class PermissionConfig {
//   final bool throwOnError;
//   final bool enableLogging; // This seems to control your print statements
//   final bool openSettingsOnPermanentDenial;
//   final bool throwOnUndeclaredPermission;
//   final int maxRetries;
//   final Duration delayBetweenRetries;

//   PermissionConfig({
//     this.throwOnError = false,
//     this.enableLogging = true, // Default based on your usage
//     this.openSettingsOnPermanentDenial = true,
//     this.throwOnUndeclaredPermission = false,
//     this.maxRetries = 0,
//     this.delayBetweenRetries = Duration.zero,
//   });

//   static PermissionConfig defaultConfig() => PermissionConfig();
//   @override
//   String toString(){
//       return "PermissionConfig(throwOnError: $throwOnError, enableLogging: $enableLogging, ...)";
//   }
// }

// extension PermissionMethods on Permission {
//   Future<PermissionStatus> get status async => PermissionStatus.denied; // Stub
//   Future<PermissionStatus> request() async => PermissionStatus.denied; // Stub
// }

// class PermissionHelper { // Stub
//   static Map<String, String> getPermissionHelp(Permission permission) =>
//       {'android': 'Android help for $permission', 'ios': 'iOS help for $permission'};
// }

// Future<void> openAppSettings() async { // Stub
//   _logger.info("Opening app settings (stub)");
// }
