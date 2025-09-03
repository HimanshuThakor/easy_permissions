library easy_permissions;

import 'package:permission_handler/permission_handler.dart';

class EasyPermissions {
  static Future<PermissionResult> request(List<Permission> permissions) async {
    final granted = <Permission>[];
    final denied = <Permission>[];

    for (var permission in permissions) {
      PermissionStatus status = await permission.status;

      final firstRequest = await permission.request();

      if (status.isDenied && firstRequest.isDenied) {
        final help = _permissionHelp(permission);
        throw Exception(
          "❌ Permission $permission is not declared.\n\n"
          "👉 Android:\n${help['android']}\n\n"
          "👉 iOS:\n${help['ios']}\n",
        );
      }

      status = firstRequest;
      while (!status.isGranted && !status.isPermanentlyDenied) {
        status = await permission.request();
      }

      if (status.isGranted) {
        granted.add(permission);
      } else {
        denied.add(permission);
        if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
      }
    }

    return PermissionResult(granted: granted, denied: denied);
  }

  static Map<String, String> _permissionHelp(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return {
          "android":
              '<uses-permission android:name="android.permission.CAMERA" />',
          "ios": '''
<key>NSCameraUsageDescription</key>
<string>This app requires camera access to take photos and videos.</string>
          '''
        };
      case Permission.microphone:
        return {
          "android":
              '<uses-permission android:name="android.permission.RECORD_AUDIO" />',
          "ios": '''
<key>NSMicrophoneUsageDescription</key>
<string>This app requires microphone access to record audio.</string>
          '''
        };
      case Permission.photos:
      case Permission.videos:
        return {
          "android":
              '<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />',
          "ios": '''
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to upload media.</string>
          '''
        };
      case Permission.audio:
        return {
          "android":
              '<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />',
          "ios": '''
<key>NSAppleMusicUsageDescription</key>
<string>This app needs access to your music library for playback features.</string>
          '''
        };
      case Permission.locationWhenInUse:
        return {
          "android":
              '<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />',
          "ios": '''
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location while using the app to show nearby services.</string>
          '''
        };
      case Permission.locationAlways:
        return {
          "android":
              '<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />',
          "ios": '''
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need background location to track your activity even when the app is closed.</string>
          '''
        };
      case Permission.bluetooth:
      case Permission.bluetoothScan:
      case Permission.bluetoothAdvertise:
      case Permission.bluetoothConnect:
        return {
          "android":
              '<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />',
          "ios": '''
<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app needs Bluetooth access to connect to nearby devices.</string>
          '''
        };
      case Permission.contacts:
        return {
          "android":
              '<uses-permission android:name="android.permission.READ_CONTACTS" />',
          "ios": '''
<key>NSContactsUsageDescription</key>
<string>We use your contacts to help you connect with friends.</string>
          '''
        };
      case Permission.calendar:
        return {
          "android":
              '<uses-permission android:name="android.permission.READ_CALENDAR" />',
          "ios": '''
<key>NSCalendarsUsageDescription</key>
<string>We need access to your calendar to add and manage events.</string>
          '''
        };
      case Permission.reminders:
        return {
          "android":
              '<!-- No direct Android permission, reminders handled via calendar APIs -->',
          "ios": '''
<key>NSRemindersUsageDescription</key>
<string>We use reminders to notify you about important tasks.</string>
          '''
        };
      case Permission.sensors:
      case Permission.activityRecognition:
        return {
          "android":
              '<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />',
          "ios": '''
<key>NSMotionUsageDescription</key>
<string>This app uses motion data to detect steps and physical activity.</string>
          '''
        };
      case Permission.notification:
        return {
          "android":
              '<!-- No AndroidManifest permission needed for notifications -->',
          "ios": '''
<key>NSUserNotificationUsageDescription</key>
<string>We send notifications to keep you updated about new events.</string>
          '''
        };
      case Permission.sms:
        return {
          "android":
              '<uses-permission android:name="android.permission.SEND_SMS" />',
          "ios": '''
<!-- iOS does not allow SMS sending permission, use MFMessageComposeViewController -->
          '''
        };
      case Permission.storage:
        return {
          "android":
              '<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />',
          "ios": '''
<!-- iOS uses NSPhotoLibraryUsageDescription for storage-like access -->
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photos and media files.</string>
          '''
        };
      case Permission.ignoreBatteryOptimizations:
        return {
          "android":
              '<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />',
          "ios": '<!-- Not applicable on iOS -->'
        };
      case Permission.systemAlertWindow:
        return {
          "android":
              '<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />',
          "ios": '<!-- Not applicable on iOS -->'
        };
      case Permission.requestInstallPackages:
        return {
          "android":
              '<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />',
          "ios": '<!-- Not applicable on iOS -->'
        };
      case Permission.accessMediaLocation:
        return {
          "android":
              '<uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION" />',
          "ios": '<!-- Not applicable on iOS -->'
        };
      case Permission.nearbyWifiDevices:
        return {
          "android":
              '<uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES" />',
          "ios": '<!-- Not applicable on iOS -->'
        };
      default:
        return {
          "android": '<!-- Add correct Android permission for $permission -->',
          "ios": '''
<key>NS${permission.toString()}UsageDescription</key>
<string>Explain why your app needs $permission access.</string>
          '''
        };
    }
  }
}

class PermissionResult {
  final List<Permission> granted;
  final List<Permission> denied;

  PermissionResult({
    required this.granted,
    required this.denied,
  });

  bool get allGranted => denied.isEmpty;
}
