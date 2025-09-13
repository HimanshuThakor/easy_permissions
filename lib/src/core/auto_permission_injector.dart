import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/permission_helper.dart';
import 'package:permission_handler/permission_handler.dart';

class AutoPermissionInjector {
  static bool _isEnabled = true;
  static bool _hasShownWarning = false;

  /// Enable or disable auto-injection (useful for testing)
  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Automatically inject missing permission to manifest files
  static Future<bool> injectMissingPermission(Permission permission) async {
    if (!_isEnabled) return false;

    try {
      final projectRoot = findProjectRoot();
      if (projectRoot == null) {
        stdout.write('❌ Could not find Flutter project root directory');
        return false;
      }

      final injected = <String>[];

      // Inject Android permission
      if (await _injectAndroidPermission(projectRoot, permission)) {
        injected.add('Android');
      }

      // Inject iOS permission
      if (await _injectIOSPermission(projectRoot, permission)) {
        injected.add('iOS');
      }

      if (injected.isNotEmpty) {
        _showAutoInjectionMessage(permission, injected);
        return true;
      }
    } catch (e) {
      stdout.write('❌ Failed to auto-inject permission $permission: $e');
    }

    return false;
  }

  static Map<Permission, Map<String, String>> _permissionMap = {
    Permission.camera: {
      'android': '<uses-permission android:name="android.permission.CAMERA" />',
      'ios':
          '<key>NSCameraUsageDescription</key><string>App needs camera access.</string>',
    },
    Permission.microphone: {
      'android':
          '<uses-permission android:name="android.permission.RECORD_AUDIO" />',
      'ios':
          '<key>NSMicrophoneUsageDescription</key><string>App needs mic access.</string>',
    },
    Permission.photos: {
      'android':
          '<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />',
      'ios':
          '<key>NSPhotoLibraryUsageDescription</key><string>Access to photos.</string>',
    },
    Permission.mediaLibrary: {
      'android':
          '<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />',
      'ios':
          '<key>NSAppleMusicUsageDescription</key><string>Access to music.</string>',
    },
    Permission.locationWhenInUse: {
      'android':
          '<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />',
      'ios':
          '<key>NSLocationWhenInUseUsageDescription</key><string>Access location.</string>',
    },
    Permission.locationAlways: {
      'android':
          '<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />',
      'ios':
          '<key>NSLocationAlwaysAndWhenInUseUsageDescription</key><string>Background location.</string>',
    },
    Permission.bluetooth: {
      'android':
          '<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />',
      'ios':
          '<key>NSBluetoothAlwaysUsageDescription</key><string>Bluetooth access.</string>',
    },
    Permission.contacts: {
      'android':
          '<uses-permission android:name="android.permission.READ_CONTACTS" />',
      'ios':
          '<key>NSContactsUsageDescription</key><string>Access to contacts.</string>',
    },
    Permission.calendar: {
      'android':
          '<uses-permission android:name="android.permission.READ_CALENDAR" />',
      'ios':
          '<key>NSCalendarsUsageDescription</key><string>Access to calendar.</string>',
    },
    Permission.reminders: {
      'ios':
          '<key>NSRemindersUsageDescription</key><string>Access to reminders.</string>',
    },
    Permission.activityRecognition: {
      'android':
          '<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />',
      'ios':
          '<key>NSMotionUsageDescription</key><string>Access to motion sensors.</string>',
    },
    Permission.notification: {
      'ios':
          '<key>NSUserNotificationUsageDescription</key><string>Send notifications.</string>',
    },
    Permission.sms: {
      'android':
          '<uses-permission android:name="android.permission.SEND_SMS" />',
    },
    Permission.storage: {
      'android':
          '<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />',
      'ios':
          '<key>NSPhotoLibraryUsageDescription</key><string>Access to photos/media.</string>',
    },
    Permission.ignoreBatteryOptimizations: {
      'android':
          '<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />',
    },
    Permission.systemAlertWindow: {
      'android':
          '<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />',
    },
    Permission.requestInstallPackages: {
      'android':
          '<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />',
    },
    Permission.accessMediaLocation: {
      'android':
          '<uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION" />',
    },
    Permission.nearbyWifiDevices: {
      'android':
          '<uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES" />',
    },
  };

  /// Inject multiple permissions at once
  static Future<Map<Permission, bool>> injectMissingPermissions(
      List<Permission> permissions) async {
    final results = <Permission, bool>{};
    final root = findProjectRoot();
    if (root == null) throw Exception("Project root not found");

    final androidManifest =
        File('$root/android/app/src/main/AndroidManifest.xml');
    final iosInfoPlist = File('$root/ios/Runner/Info.plist');

    for (final permission in permissions) {
      final mapping = _permissionMap[permission];
      if (mapping == null) {
        results[permission] = false;
        continue;
      }

      // Inject Android
      if (androidManifest.existsSync() && mapping['android'] != null) {
        final content = androidManifest.readAsStringSync();
        if (!content.contains(mapping['android']!)) {
          androidManifest.writeAsStringSync(
            content.replaceFirst(
                '</manifest>', '    ${mapping['android']}\n</manifest>'),
          );
          results[permission] = true;
        } else {
          results[permission] = false; // already exists
        }
      }

      // Inject iOS
      if (iosInfoPlist.existsSync() && mapping['ios'] != null) {
        final content = iosInfoPlist.readAsStringSync();
        if (!content.contains(mapping['ios']!.split('</key>').first)) {
          iosInfoPlist.writeAsStringSync(
            content.replaceFirst('</dict>', '    ${mapping['ios']}\n</dict>'),
          );
          results[permission] = true;
        } else {
          results[permission] = false; // already exists
        }
      }
    }

    return results;
  }

  /// Find the Flutter project root directory
  static String? findProjectRoot() {
    Directory current = Directory.current;

    // Look for pubspec.yaml going up the directory tree
    while (current.path != current.parent.path) {
      final pubspecFile = File(path.join(current.path, 'pubspec.yaml'));
      if (pubspecFile.existsSync()) {
        // Verify it's a Flutter project
        final content = pubspecFile.readAsStringSync();
        if (content.contains('flutter:')) {
          return current.path;
        }
      }
      current = current.parent;
    }

    return null;
  }

  /// Inject Android permission to AndroidManifest.xml
  static Future<bool> _injectAndroidPermission(
    String projectRoot,
    Permission permission,
  ) async {
    final manifestPath = path.join(
      projectRoot,
      'android',
      'app',
      'src',
      'main',
      'AndroidManifest.xml',
    );

    final manifestFile = File(manifestPath);
    if (!manifestFile.existsSync()) {
      stdout.write('⚠️ Android manifest not found: $manifestPath');
      return false;
    }

    try {
      var content = await manifestFile.readAsString();
      final helpInfo = PermissionHelper.getPermissionHelp(permission);
      final androidPermission = helpInfo['android']!;

      // Check if permission already exists
      if (content.contains(androidPermission.replaceAll(RegExp(r'\s+'), ' '))) {
        return false; // Already exists
      }

      // Find the best place to inject the permission
      content = _injectAndroidPermissionContent(content, androidPermission);

      // Create backup
      await _createBackup(manifestFile);

      // Write updated content
      await manifestFile.writeAsString(content);

      return true;
    } catch (e) {
      stdout.write('❌ Failed to inject Android permission: $e');
      return false;
    }
  }

  /// Inject iOS permission to Info.plist
  static Future<bool> _injectIOSPermission(
    String projectRoot,
    Permission permission,
  ) async {
    final plistPath = path.join(
      projectRoot,
      'ios',
      'Runner',
      'Info.plist',
    );

    final plistFile = File(plistPath);
    if (!plistFile.existsSync()) {
      stdout.write('⚠️ iOS Info.plist not found: $plistPath');
      return false;
    }

    try {
      var content = await plistFile.readAsString();
      final helpInfo = PermissionHelper.getPermissionHelp(permission);
      final iosPermission = helpInfo['ios']!;

      // Extract the key from iOS permission
      final keyMatch = RegExp(r'<key>([^<]+)</key>').firstMatch(iosPermission);
      if (keyMatch == null) return false;

      final key = keyMatch.group(1)!;

      // Check if permission already exists
      if (content.contains('<key>$key</key>')) {
        return false; // Already exists
      }

      // Inject the permission
      content = _injectIOSPermissionContent(content, iosPermission);

      // Create backup
      await _createBackup(plistFile);

      // Write updated content
      await plistFile.writeAsString(content);

      return true;
    } catch (e) {
      stdout.write('❌ Failed to inject iOS permission: $e');
      return false;
    }
  }

  /// Inject Android permission content into manifest
  static String _injectAndroidPermissionContent(
    String content,
    String androidPermission,
  ) {
    // Add auto-generated comment if not present
    const marker = '<!-- AUTO-GENERATED PERMISSIONS -->';

    if (!content.contains(marker)) {
      // Find manifest tag and inject after it
      final manifestMatch = RegExp(r'<manifest[^>]*>').firstMatch(content);
      if (manifestMatch != null) {
        final insertPos = manifestMatch.end;
        content =
            '${content.substring(0, insertPos)}\n    $marker\n    $androidPermission${content.substring(insertPos)}';
      }
    } else {
      // Add to existing auto-generated section
      final regex = RegExp(
          r'(<!-- AUTO-GENERATED PERMISSIONS -->)([\s\S]*?)(<application|<uses-feature|</manifest>)');
      final match = regex.firstMatch(content);

      if (match != null) {
        final existingPermissions = match.group(2)!;
        final newSection =
            '${match.group(1)!}$existingPermissions    $androidPermission\n    ${match.group(3)!}';

        content = content.replaceAll(regex, newSection);
      }
    }

    return content;
  }

  /// Inject iOS permission content into Info.plist
  static String _injectIOSPermissionContent(
    String content,
    String iosPermission,
  ) {
    // Add auto-generated comment if not present
    const marker = '<!-- AUTO-GENERATED PERMISSIONS -->';

    if (!content.contains(marker)) {
      // Find the last </dict> and inject before it
      final lastDictIndex = content.lastIndexOf('</dict>');
      if (lastDictIndex != -1) {
        content =
            '${content.substring(0, lastDictIndex)}\t$marker\n\t$iosPermission\n${content.substring(lastDictIndex)}';
      }
    } else {
      // Add to existing auto-generated section
      final regex =
          RegExp(r'(<!-- AUTO-GENERATED PERMISSIONS -->)([\s\S]*?)(</dict>)');
      final match = regex.firstMatch(content);

      if (match != null) {
        final existingPermissions = match.group(2)!;
        final newSection =
            '${match.group(1)!}$existingPermissions\t$iosPermission\n\t${match.group(3)!}';

        content = content.replaceAll(regex, newSection);
      }
    }

    return content;
  }

  /// Create backup of original file
  static Future<void> _createBackup(File file) async {
    final backupPath = '${file.path}.backup';
    final backupFile = File(backupPath);

    if (!backupFile.existsSync()) {
      await file.copy(backupPath);
    }
  }

  /// Show auto-injection success message
  static void _showAutoInjectionMessage(
    Permission permission,
    List<String> platforms,
  ) {
    if (!_hasShownWarning) {
      stdout.write('\n${'=' * 60}');
      stdout.write('🔧 AUTO-PERMISSION INJECTION ACTIVATED');
      stdout.write('=' * 60);
      _hasShownWarning = true;
    }

    stdout.write(
        '\n✅ Auto-injected $permission permission for: ${platforms.join(', ')}');
    stdout.write('📁 Files updated:');

    if (platforms.contains('Android')) {
      stdout.write('   • android/app/src/main/AndroidManifest.xml');
    }
    if (platforms.contains('iOS')) {
      stdout.write('   • ios/Runner/Info.plist');
    }

    stdout.write(
        '\n⚠️  IMPORTANT: Please restart your app to apply the changes!');
    stdout.write(
        '💡 Tip: Add permissions manually to avoid runtime injection.\n');
  }

  /// Restore files from backup
  static Future<void> restoreFromBackup(String projectRoot) async {
    final manifestBackup = File(path.join(
      projectRoot,
      'android',
      'app',
      'src',
      'main',
      'AndroidManifest.xml.backup',
    ));

    final plistBackup = File(path.join(
      projectRoot,
      'ios',
      'Runner',
      'Info.plist.backup',
    ));

    if (manifestBackup.existsSync()) {
      final manifest = File(manifestBackup.path.replaceAll('.backup', ''));
      await manifestBackup.copy(manifest.path);
      stdout.write('✅ Restored Android manifest from backup');
    }

    if (plistBackup.existsSync()) {
      final plist = File(plistBackup.path.replaceAll('.backup', ''));
      await plistBackup.copy(plist.path);
      stdout.write('✅ Restored iOS Info.plist from backup');
    }
  }

  /// Clean up backup files
  static Future<void> cleanBackups(String projectRoot) async {
    final backupFiles = [
      File(path.join(projectRoot, 'android', 'app', 'src', 'main',
          'AndroidManifest.xml.backup')),
      File(path.join(projectRoot, 'ios', 'Runner', 'Info.plist.backup')),
    ];

    for (final backup in backupFiles) {
      if (backup.existsSync()) {
        await backup.delete();
        stdout.write('🗑️ Cleaned backup: ${backup.path}');
      }
    }
  }
}
