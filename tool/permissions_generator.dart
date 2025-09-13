import 'dart:io';
import 'package:yaml/yaml.dart';

/// Mapping of supported permissions → Android + iOS entries
final permissionsMap = {
  "camera": {
    "android": '<uses-permission android:name="android.permission.CAMERA"/>',
    "ios":
        '<key>NSCameraUsageDescription</key>\n<string>This app requires camera access.</string>',
  },
  "microphone": {
    "android":
        '<uses-permission android:name="android.permission.RECORD_AUDIO"/>',
    "ios":
        '<key>NSMicrophoneUsageDescription</key>\n<string>This app requires microphone access.</string>',
  },
  "photos": {
    "android":
        '<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>',
    "ios":
        '<key>NSPhotoLibraryUsageDescription</key>\n<string>This app requires photo library access.</string>',
  },
  "location": {
    "android": '''
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>''',
    "ios": '''
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location while in use.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access even in background.</string>''',
  },
  "contacts": {
    "android":
        '<uses-permission android:name="android.permission.READ_CONTACTS"/>',
    "ios":
        '<key>NSContactsUsageDescription</key>\n<string>This app requires contacts access.</string>',
  },
  "calendar": {
    "android":
        '<uses-permission android:name="android.permission.READ_CALENDAR"/>',
    "ios":
        '<key>NSCalendarsUsageDescription</key>\n<string>This app requires calendar access.</string>',
  },
  "bluetooth": {
    "android": '''
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>''',
    "ios":
        '<key>NSBluetoothAlwaysUsageDescription</key>\n<string>This app requires Bluetooth access.</string>',
  },
  "notifications": {
    "android":
        '<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>',
    "ios":
        '<key>NSUserNotificationUsageDescription</key>\n<string>This app requires notifications.</string>',
  },
};

Future<void> main(List<String> args) async {
  final dryRun = args.contains("--dry-run");

  final file = File("permissions.yaml");

  if (!await file.exists()) {
    stdout.write("❌ No permissions.yaml file found in project root.");
    exit(1);
  }

  final content = await file.readAsString();
  final yaml = loadYaml(content);

  final permissions = List<String>.from(yaml["permissions"] ?? []);

  if (permissions.isEmpty) {
    stdout.write("⚠️ No permissions found in permissions.yaml.");
    exit(0);
  }

  final androidBuffer = StringBuffer();
  final iosBuffer = StringBuffer();

  for (var perm in permissions) {
    final mapping = permissionsMap[perm.toLowerCase()];
    if (mapping != null) {
      androidBuffer.writeln(mapping["android"]);
      iosBuffer.writeln(mapping["ios"]);
    } else {
      stdout.write("⚠️ Unknown permission: $perm");
    }
  }

  // ===== Android Preview =====
  final manifestPath = "android/app/src/main/AndroidManifest.xml";
  final manifestFile = File(manifestPath);

  if (await manifestFile.exists()) {
    var manifestContent = await manifestFile.readAsString();

    final updatedManifest =
        _injectAndroid(manifestContent, androidBuffer.toString());

    if (dryRun) {
      stdout.write("\n📄 ANDROID MANIFEST PREVIEW ($manifestPath):\n");
      _printDiff(manifestContent, updatedManifest);
    } else {
      await manifestFile.writeAsString(updatedManifest);
      stdout.write("✅ Updated $manifestPath");
    }
  }

  // ===== iOS Preview =====
  final plistPath = "ios/Runner/Info.plist";
  final plistFile = File(plistPath);

  if (await plistFile.exists()) {
    var plistContent = await plistFile.readAsString();

    final updatedPlist = _injectIOS(plistContent, iosBuffer.toString());

    if (dryRun) {
      stdout.write("\n📄 INFO.PLIST PREVIEW ($plistPath):\n");
      _printDiff(plistContent, updatedPlist);
    } else {
      await plistFile.writeAsString(updatedPlist);
      stdout.write("✅ Updated $plistPath");
    }
  }

  if (dryRun) {
    stdout.write("\n🔍 Dry run complete. No files were modified.");
  } else {
    stdout.write("\n🎉 Permissions updated successfully!");
  }
}

String _injectAndroid(String content, String androidEntries) {
  if (!content.contains("<!-- AUTO-GENERATED PERMISSIONS -->")) {
    return content.replaceFirst(
      "<manifest",
      "<manifest\n    <!-- AUTO-GENERATED PERMISSIONS -->\n$androidEntries",
    );
  } else {
    return content.replaceAll(
      RegExp(r'<!-- AUTO-GENERATED PERMISSIONS -->[\s\S]*?<application'),
      "<!-- AUTO-GENERATED PERMISSIONS -->\n$androidEntries\n    <application",
    );
  }
}

String _injectIOS(String content, String iosEntries) {
  if (!content.contains("<!-- AUTO-GENERATED PERMISSIONS -->")) {
    return content.replaceFirst(
      "</dict>",
      "    <!-- AUTO-GENERATED PERMISSIONS -->\n$iosEntries\n</dict>",
    );
  } else {
    return content.replaceAll(
      RegExp(r'<!-- AUTO-GENERATED PERMISSIONS -->[\s\S]*?</dict>'),
      "<!-- AUTO-GENERATED PERMISSIONS -->\n$iosEntries\n</dict>",
    );
  }
}

/// Simple diff viewer (line-by-line)
void _printDiff(String oldContent, String newContent) {
  final oldLines = oldContent.split("\n");
  final newLines = newContent.split("\n");

  for (int i = 0; i < newLines.length; i++) {
    if (i >= oldLines.length) {
      stdout.write("+ ${newLines[i]}");
    } else if (oldLines[i] != newLines[i]) {
      stdout.write("- ${oldLines[i]}");
      stdout.write("+ ${newLines[i]}");
    }
  }
}
