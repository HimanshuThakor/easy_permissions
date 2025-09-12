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
      stdout.write('❌ No permissions specified. Use -p or --permissions');
      _printUsage(parser);
      exit(1);
    }

    final permissions = _parsePermissions(permissionNames);
    await _injectPermissions(permissions);
  } catch (e) {
    stdout.write('❌ Error: $e');
    _printUsage(parser);
    exit(1);
  }
}

void _printUsage(ArgParser parser) {
  stdout.write('Flutter Easy Permission Manager - Auto Injection CLI');
  stdout.write('');
  stdout.write('Usage: dart run auto_inject_permissions.dart [options]');
  stdout.write('');
  stdout.write('Options:');
  stdout.write(parser.usage);
  stdout.write('');
  stdout.write('Examples:');
  stdout.write('  # Inject camera and microphone permissions');
  stdout.write('  dart run auto_inject_permissions.dart -p camera,microphone');
  stdout.write('');
  stdout.write('  # Inject location permission for Android only');
  stdout.write('  dart run auto_inject_permissions.dart -p location --android-only');
  stdout.write('');
  stdout.write('  # Restore from backups');
  stdout.write('  dart run auto_inject_permissions.dart --restore');
  stdout.write('');
  stdout.write('  # Clean backup files');
  stdout.write('  dart run auto_inject_permissions.dart --clean');
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
        stdout.write('⚠️  Unknown permission: $name');
    }
  }

  return permissions;
}

Future<void> _injectPermissions(List<Permission> permissions) async {
  stdout.write('🔧 Starting auto-injection for ${permissions.length} permissions...');
  stdout.write('');

  final results =
      await AutoPermissionInjector.injectMissingPermissions(permissions);

  int successCount = 0;
  for (final entry in results.entries) {
    final permission = entry.key;
    final success = entry.value;

    if (success) {
      stdout.write('✅ ${permission.toString().split('.').last}');
      successCount++;
    } else {
      stdout.write(
          '⏭️  ${permission.toString().split('.').last} (already exists or failed)');
    }
  }

  stdout.write('');
  stdout.write('📊 Results: $successCount/${permissions.length} permissions injected');

  if (successCount > 0) {
    stdout.write('');
    stdout.write('⚠️  IMPORTANT: Restart your app to apply the changes!');
    stdout.write('📁 Check the following files for updates:');
    stdout.write('   • android/app/src/main/AndroidManifest.xml');
    stdout.write('   • ios/Runner/Info.plist');
  }
}

Future<void> _restoreBackups() async {
  stdout.write('🔄 Restoring manifest files from backup...');

  try {
    final projectRoot = AutoPermissionInjector.findProjectRoot();
    if (projectRoot != null) {
      await AutoPermissionInjector.restoreFromBackup(projectRoot);
      stdout.write('✅ Backup restoration completed!');
    } else {
      stdout.write('❌ Could not find Flutter project root');
    }
  } catch (e) {
    stdout.write('❌ Error during restoration: $e');
  }
}

Future<void> _cleanBackups() async {
  stdout.write('🗑️ Cleaning backup files...');

  try {
    final projectRoot = AutoPermissionInjector.findProjectRoot();
    if (projectRoot != null) {
      await AutoPermissionInjector.cleanBackups(projectRoot);
      stdout.write('✅ Backup cleanup completed!');
    } else {
      stdout.write('❌ Could not find Flutter project root');
    }
  } catch (e) {
    stdout.write('❌ Error during cleanup: $e');
  }
}
