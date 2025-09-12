// bin/auto_inject_permissions.dart
import 'dart:io';
import 'package:args/args.dart';

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
    ..addFlag('restore',
        help: 'Restore from backup files (not yet implemented)')
    ..addFlag('clean', help: 'Clean backup files (not yet implemented)');

  final results = parser.parse(args);

  if (results['help'] as bool) {
    _printUsage(parser);
    return;
  }

  final permissionNames = results['permissions'] as List<String>;
  if (permissionNames.isEmpty) {
    stdout.write('❌ No permissions specified. Use -p or --permissions');
    _printUsage(parser);
    exit(1);
  }

  final androidOnly = results['android-only'] as bool;
  final iosOnly = results['ios-only'] as bool;

  await _injectPermissions(permissionNames, androidOnly, iosOnly);
}

void _printUsage(ArgParser parser) {
  stdout.write('Flutter Easy Permission Manager - Auto Injection CLI\n');
  stdout.write('Usage: dart run auto_inject_permissions.dart [options]\n');
  stdout.write('Options:');
  stdout.write(parser.usage);
  stdout.write('\nExamples:');
  stdout.write('  dart run auto_inject_permissions.dart -p camera,microphone');
  stdout.write(
      '  dart run auto_inject_permissions.dart -p location --android-only');
}

/// Permission mapping (simple)
final Map<String, Map<String, String>> _permissionMap = {
  'camera': {
    'android': '<uses-permission android:name="android.permission.CAMERA"/>',
    'ios':
        '<key>NSCameraUsageDescription</key><string>We need camera access</string>',
  },
  'microphone': {
    'android':
        '<uses-permission android:name="android.permission.RECORD_AUDIO"/>',
    'ios':
        '<key>NSMicrophoneUsageDescription</key><string>We need microphone access</string>',
  },
  'location': {
    'android':
        '<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>',
    'ios':
        '<key>NSLocationWhenInUseUsageDescription</key><string>We need location access</string>',
  },
  'contacts': {
    'android':
        '<uses-permission android:name="android.permission.READ_CONTACTS"/>',
    'ios':
        '<key>NSContactsUsageDescription</key><string>We need contacts access</string>',
  },
};

Future<void> _injectPermissions(
    List<String> names, bool androidOnly, bool iosOnly) async {
  stdout
      .write('🔧 Starting auto-injection for ${names.length} permissions...\n');

  if (!iosOnly) {
    final manifestFile = File('android/app/src/main/AndroidManifest.xml');
    if (manifestFile.existsSync()) {
      var content = manifestFile.readAsStringSync();
      for (var name in names) {
        final snippet = _permissionMap[name.toLowerCase()]?['android'];
        if (snippet != null && !content.contains(snippet)) {
          content =
              content.replaceFirst('</manifest>', '  $snippet\n</manifest>');
          stdout.write('✅ Injected $name (Android)');
        }
      }
      manifestFile.writeAsStringSync(content);
    } else {
      stdout.write('⚠️ AndroidManifest.xml not found.');
    }
  }

  if (!androidOnly) {
    final plistFile = File('ios/Runner/Info.plist');
    if (plistFile.existsSync()) {
      var content = plistFile.readAsStringSync();
      for (var name in names) {
        final snippet = _permissionMap[name.toLowerCase()]?['ios'];
        if (snippet != null && !content.contains(snippet)) {
          content = content.replaceFirst('</dict>', '  $snippet\n</dict>');
          stdout.write('✅ Injected $name (iOS)');
        }
      }
      plistFile.writeAsStringSync(content);
    } else {
      stdout.write('⚠️ Info.plist not found.');
    }
  }

  stdout.write('\n📊 Injection completed!');
}
