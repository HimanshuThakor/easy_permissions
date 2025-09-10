import 'dart:io';
import 'package:args/args.dart';
import 'package:flutter_easy_permission_manager/src/core/auto_permission_injector.dart';
import 'package:permission_handler/permission_handler.dart';

/// CLI tool for batch permission injection
Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addFlag('help', abbr: 'h', help: 'Show usage information')
    ..addMultiOption('permissions',
        abbr: 'p',
        help: 'Permissions to inject (e.g., camera,microphone,location)')
    ..addFlag('android-only', help: 'Inject only Android permissions')
    ..addFlag('ios-only', help: 'Inject only iOS permissions')
    ..addFlag('backup',
        defaultsTo: true, help: 'Create backup before injection')
    ..addFlag('restore', help: 'Restore from backup files')
    ..addFlag('clean', help: 'Clean backup files');

  try {
    final results = parser.parse(args);

    if (results['help'] as bool) {
      _printUsage(parser);
      return;
    }

    if (results['restore'] as bool) {
      await _restoreBackups();
      return;
    }

    if (results['clean'] as bool) {
      await _cleanBackups();
      return;
    }

    final permissionNames = results['permissions'] as List<String>;
    if (permissionNames.isEmpty) {
      print('❌ No permissions specified. Use -p or --permissions');
      _printUsage(parser);
      exit(1);
    }

    final permissions = _parsePermissions(permissionNames);
    await _injectPermissions(permissions);
  } catch (e) {
    print('❌ Error: $e');
    _printUsage(parser);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  print('Flutter Easy Permission Manager - Auto Injection CLI');
  print('');
  print('Usage: dart run auto_inject_permissions.dart [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print('  # Inject camera and microphone permissions');
  print('  dart run auto_inject_permissions.dart -p camera,microphone');
  print('');
  print('  # Inject location permission for Android only');
  print('  dart run auto_inject_permissions.dart -p location --android-only');
  print('');
  print('  # Restore from backups');
  print('  dart run auto_inject_permissions.dart --restore');
  print('');
  print('  # Clean backup files');
  print('  dart run auto_inject_permissions.dart --clean');
}

List<Permission> _parsePermissions(List<String> permissionNames) {
  final permissions = <Permission>[];

  for (final name in permissionNames) {
    switch (name.toLowerCase()) {
      case 'camera':
        permissions.add(Permission.camera);
        break;
      case 'microphone':
        permissions.add(Permission.microphone);
        break;
      case 'location':
      case 'locationwheninuse':
        permissions.add(Permission.locationWhenInUse);
        break;
      case 'locationalways':
        permissions.add(Permission.locationAlways);
        break;
      case 'photos':
      case 'photo':
        permissions.add(Permission.photos);
        break;
      case 'videos':
        permissions.add(Permission.videos);
        break;
      case 'audio':
        permissions.add(Permission.audio);
        break;
      case 'contacts':
        permissions.add(Permission.contacts);
        break;
      case 'calendar':
        permissions.add(Permission.calendar);
        break;
      case 'reminders':
        permissions.add(Permission.reminders);
        break;
      case 'sensors':
      case 'activity':
        permissions.add(Permission.sensors);
        break;
      case 'bluetooth':
        permissions.add(Permission.bluetooth);
        break;
      case 'notification':
      case 'notifications':
        permissions.add(Permission.notification);
        break;
      case 'sms':
        permissions.add(Permission.sms);
        break;
      case 'storage':
        permissions.add(Permission.storage);
        break;
      case 'ignore-battery-optimizations':
      case 'ignorebatteryoptimizations':
        permissions.add(Permission.ignoreBatteryOptimizations);
        break;
      case 'system-alert-window':
      case 'systemalertwindow':
        permissions.add(Permission.systemAlertWindow);
        break;
      case 'request-install-packages':
      case 'requestinstallpackages':
        permissions.add(Permission.requestInstallPackages);
        break;
      case 'access-media-location':
      case 'accessmedialocation':
        permissions.add(Permission.accessMediaLocation);
        break;
      case 'nearby-wifi-devices':
      case 'nearbywifidevices':
        permissions.add(Permission.nearbyWifiDevices);
        break;

      default:
        print('⚠️  Unknown permission: $name');
    }
  }

  return permissions;
}

Future<void> _injectPermissions(List<Permission> permissions) async {
  print('🔧 Starting auto-injection for ${permissions.length} permissions...');
  print('');

  final results =
      await AutoPermissionInjector.injectMissingPermissions(permissions);

  int successCount = 0;
  for (final entry in results.entries) {
    final permission = entry.key;
    final success = entry.value;

    if (success) {
      print('✅ ${permission.toString().split('.').last}');
      successCount++;
    } else {
      print(
          '⏭️  ${permission.toString().split('.').last} (already exists or failed)');
    }
  }

  print('');
  print('📊 Results: $successCount/${permissions.length} permissions injected');

  if (successCount > 0) {
    print('');
    print('⚠️  IMPORTANT: Restart your app to apply the changes!');
    print('📁 Check the following files for updates:');
    print('   • android/app/src/main/AndroidManifest.xml');
    print('   • ios/Runner/Info.plist');
  }
}

Future<void> _restoreBackups() async {
  print('🔄 Restoring manifest files from backup...');

  try {
    final projectRoot = AutoPermissionInjector.findProjectRoot();
    if (projectRoot != null) {
      await AutoPermissionInjector.restoreFromBackup(projectRoot);
      print('✅ Backup restoration completed!');
    } else {
      print('❌ Could not find Flutter project root');
    }
  } catch (e) {
    print('❌ Error during restoration: $e');
  }
}

Future<void> _cleanBackups() async {
  print('🗑️ Cleaning backup files...');

  try {
    final projectRoot = AutoPermissionInjector.findProjectRoot();
    if (projectRoot != null) {
      await AutoPermissionInjector.cleanBackups(projectRoot);
      print('✅ Backup cleanup completed!');
    } else {
      print('❌ Could not find Flutter project root');
    }
  } catch (e) {
    print('❌ Error during cleanup: $e');
  }
}
