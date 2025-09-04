import 'package:permission_handler/permission_handler.dart';
import '../models/permission_models.dart';

class PermissionConstants {
  PermissionConstants._();

  /// User-friendly display names for permissions
  static Map<Permission, String> permissionDisplayNames = {
    Permission.camera: 'Camera',
    Permission.microphone: 'Microphone',
    Permission.photos: 'Photos',
    Permission.videos: 'Videos',
    Permission.audio: 'Audio Files',
    Permission.locationWhenInUse: 'Location (When In Use)',
    Permission.locationAlways: 'Location (Always)',
    Permission.contacts: 'Contacts',
    Permission.calendar: 'Calendar',
    Permission.reminders: 'Reminders',
    Permission.bluetooth: 'Bluetooth',
    Permission.bluetoothScan: 'Bluetooth Scan',
    Permission.bluetoothAdvertise: 'Bluetooth Advertise',
    Permission.bluetoothConnect: 'Bluetooth Connect',
    Permission.notification: 'Notifications',
    Permission.sensors: 'Sensors',
    Permission.activityRecognition: 'Activity Recognition',
    Permission.sms: 'SMS',
    Permission.phone: 'Phone',
    Permission.storage: 'Storage',
    Permission.ignoreBatteryOptimizations: 'Battery Optimization',
    Permission.systemAlertWindow: 'System Alert Window',
    Permission.requestInstallPackages: 'Install Packages',
    Permission.accessMediaLocation: 'Media Location',
    Permission.nearbyWifiDevices: 'Nearby WiFi Devices',
    Permission.manageExternalStorage: 'Manage External Storage',
    Permission.speech: 'Speech Recognition',
    Permission.accessNotificationPolicy: 'Notification Policy',
  };

  /// Platform-specific permission help text
  static Map<Permission, Map<String, String>> permissionHelpMap = {
    Permission.camera: {
      'android': '<uses-permission android:name="android.permission.CAMERA" />',
      'ios': '''<key>NSCameraUsageDescription</key>
<string>This app requires camera access to take photos and videos.</string>''',
    },
    Permission.microphone: {
      'android':
          '<uses-permission android:name="android.permission.RECORD_AUDIO" />',
      'ios': '''<key>NSMicrophoneUsageDescription</key>
<string>This app requires microphone access to record audio.</string>''',
    },
    Permission.photos: {
      'android':
          '''<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />''',
      'ios': '''<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to upload and manage images.</string>''',
    },
    Permission.videos: {
      'android':
          '''<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />''',
      'ios': '''<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to upload and manage videos.</string>''',
    },
    Permission.audio: {
      'android':
          '''<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />''',
      'ios': '''<key>NSAppleMusicUsageDescription</key>
<string>This app needs access to your music library for playback features.</string>''',
    },
    Permission.locationWhenInUse: {
      'android':
          '''<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />''',
      'ios': '''<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location while in use to provide location-based services.</string>''',
    },
    Permission.locationAlways: {
      'android':
          '''<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />''',
      'ios': '''<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs your location while in use.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs continuous location access for background tracking.</string>''',
    },
    Permission.contacts: {
      'android':
          '<uses-permission android:name="android.permission.READ_CONTACTS" />',
      'ios': '''<key>NSContactsUsageDescription</key>
<string>This app uses your contacts to help you connect with friends.</string>''',
    },
    Permission.calendar: {
      'android':
          '''<uses-permission android:name="android.permission.READ_CALENDAR" />
<uses-permission android:name="android.permission.WRITE_CALENDAR" />''',
      'ios': '''<key>NSCalendarsUsageDescription</key>
<string>This app needs access to your calendar to create and manage events.</string>''',
    },
    Permission.reminders: {
      'android': '<!-- Reminders are handled via calendar APIs on Android -->',
      'ios': '''<key>NSRemindersUsageDescription</key>
<string>This app uses reminders to help you track important tasks.</string>''',
    },
    Permission.bluetooth: {
      'android':
          '''<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />''',
      'ios': '''<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app uses Bluetooth to connect to nearby devices.</string>''',
    },
    Permission.bluetoothScan: {
      'android':
          '''<uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />''',
      'ios': '''<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app scans for Bluetooth devices to establish connections.</string>''',
    },
    Permission.bluetoothAdvertise: {
      'android':
          '<uses-permission android:name="android.permission.BLUETOOTH_ADVERTISE" />',
      'ios': '''<key>NSBluetoothPeripheralUsageDescription</key>
<string>This app advertises Bluetooth services to nearby devices.</string>''',
    },
    Permission.bluetoothConnect: {
      'android':
          '<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />',
      'ios': '''<key>NSBluetoothAlwaysUsageDescription</key>
<string>This app connects to Bluetooth devices for data transfer.</string>''',
    },
    Permission.notification: {
      'android':
          '<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />',
      'ios': '''<key>NSUserNotificationUsageDescription</key>
<string>This app sends notifications to keep you informed of important updates.</string>''',
    },
    Permission.sensors: {
      'android': '<!-- Sensor permissions are implicit for most sensors -->',
      'ios': '''<key>NSMotionUsageDescription</key>
<string>This app uses motion sensors to detect device movement and orientation.</string>''',
    },
    Permission.activityRecognition: {
      'android':
          '<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />',
      'ios': '''<key>NSMotionUsageDescription</key>
<string>This app tracks your physical activity for health and fitness features.</string>''',
    },
    Permission.sms: {
      'android':
          '''<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.READ_SMS" />''',
      'ios':
          '<!-- SMS permissions are not available on iOS. Use MFMessageComposeViewController instead -->',
    },
    Permission.phone: {
      'android':
          '''<uses-permission android:name="android.permission.READ_PHONE_STATE" />
<uses-permission android:name="android.permission.CALL_PHONE" />''',
      'ios': '<!-- Phone permissions are limited on iOS -->',
    },
    Permission.storage: {
      'android':
          '''<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />''',
      'ios': '''<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to storage for file management.</string>''',
    },
    Permission.ignoreBatteryOptimizations: {
      'android':
          '<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />',
      'ios': '<!-- Not applicable on iOS -->',
    },
    Permission.systemAlertWindow: {
      'android':
          '<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />',
      'ios': '<!-- Not applicable on iOS -->',
    },
    Permission.requestInstallPackages: {
      'android':
          '<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />',
      'ios': '<!-- Not applicable on iOS -->',
    },
    Permission.accessMediaLocation: {
      'android':
          '<uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION" />',
      'ios':
          '<!-- Media location access is handled through photo library permissions -->',
    },
    Permission.nearbyWifiDevices: {
      'android':
          '<uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES" />',
      'ios': '''<key>NSLocalNetworkUsageDescription</key>
<string>This app discovers and connects to devices on your local network.</string>''',
    },
    Permission.manageExternalStorage: {
      'android':
          '<uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE" />',
      'ios': '<!-- Not applicable on iOS -->',
    },
    Permission.speech: {
      'android':
          '<uses-permission android:name="android.permission.RECORD_AUDIO" />',
      'ios': '''<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech recognition to convert your voice to text.</string>''',
    },
  };

  /// Predefined permission groups for common use cases
  static final Map<String, PermissionGroup> commonPermissionGroups = {
    'media': PermissionGroup(
      name: 'Media Access',
      description:
          'Permissions required for camera, microphone, and media access',
      permissions: [
        Permission.camera,
        Permission.microphone,
        Permission.photos,
        Permission.videos,
      ],
      rationale:
          'We need access to your camera and media files to capture and share content.',
    ),
    'location': PermissionGroup(
      name: 'Location Services',
      description: 'Permissions required for location-based features',
      permissions: [
        Permission.locationWhenInUse,
      ],
      rationale:
          'We use your location to provide personalized, location-based services.',
    ),
    'location_background': PermissionGroup(
      name: 'Background Location',
      description: 'Permissions for continuous location tracking',
      permissions: [
        Permission.locationWhenInUse,
        Permission.locationAlways,
      ],
      rationale:
          'We need background location access to provide continuous tracking services.',
    ),
    'contacts': PermissionGroup(
      name: 'Contacts & Communication',
      description: 'Access to contacts and communication features',
      permissions: [
        Permission.contacts,
        Permission.phone,
        Permission.sms,
      ],
      allRequired: false,
      rationale:
          'We use your contacts to help you connect and communicate with others.',
    ),
    'bluetooth': PermissionGroup(
      name: 'Bluetooth Connectivity',
      description: 'Bluetooth permissions for device connectivity',
      permissions: [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
      ],
      allRequired: false,
      rationale:
          'We use Bluetooth to connect with nearby devices and accessories.',
    ),
    'storage': PermissionGroup(
      name: 'File Storage',
      description: 'Access to device storage and files',
      permissions: [
        Permission.storage,
        Permission.photos,
        Permission.videos,
        Permission.audio,
      ],
      allRequired: false,
      rationale: 'We need storage access to save and manage your files.',
    ),
  };

  /// Platform-specific information for each permission
  static final Map<Permission, PlatformPermissionInfo> platformInfo = {
    Permission.camera: PlatformPermissionInfo(
      permission: Permission.camera,
      androidPermission: 'android.permission.CAMERA',
      iosUsageDescription: 'Camera access for taking photos and videos',
      iosInfoPlistKey: 'NSCameraUsageDescription',
    ),
    Permission.microphone: PlatformPermissionInfo(
      permission: Permission.microphone,
      androidPermission: 'android.permission.RECORD_AUDIO',
      iosUsageDescription: 'Microphone access for recording audio',
      iosInfoPlistKey: 'NSMicrophoneUsageDescription',
    ),
    Permission.locationWhenInUse: PlatformPermissionInfo(
      permission: Permission.locationWhenInUse,
      androidPermission: 'android.permission.ACCESS_FINE_LOCATION',
      iosUsageDescription: 'Location access while app is in use',
      iosInfoPlistKey: 'NSLocationWhenInUseUsageDescription',
    ),
    Permission.locationAlways: PlatformPermissionInfo(
      permission: Permission.locationAlways,
      androidPermission: 'android.permission.ACCESS_BACKGROUND_LOCATION',
      iosUsageDescription: 'Location access at all times',
      iosInfoPlistKey: 'NSLocationAlwaysAndWhenInUseUsageDescription',
      minimumSdkVersion: 29, // Background location requires API 29+
    ),
    Permission.notification: PlatformPermissionInfo(
      permission: Permission.notification,
      androidPermission: 'android.permission.POST_NOTIFICATIONS',
      iosUsageDescription: 'Push notifications',
      iosInfoPlistKey: 'NSUserNotificationUsageDescription',
      minimumSdkVersion: 33, // POST_NOTIFICATIONS introduced in API 33
    ),
    // Add more permissions as needed...
  };

  /// Get default permission help for unknown permissions
  static Map<String, String> getDefaultPermissionHelp(Permission permission) {
    final permissionName = permission.toString().split('.').last;
    return {
      'android': '<!-- Add Android permission for $permissionName -->',
      'ios': '''<key>NS${_capitalize(permissionName)}UsageDescription</key>
<string>This app requires $permissionName permission.</string>''',
    };
  }

  /// Get permission category for grouping
  static String getPermissionCategory(Permission permission) {
    switch (permission) {
      case Permission.camera:
      case Permission.microphone:
      case Permission.photos:
      case Permission.videos:
      case Permission.audio:
        return 'Media';

      case Permission.locationWhenInUse:
      case Permission.locationAlways:
        return 'Location';

      case Permission.bluetooth:
      case Permission.bluetoothScan:
      case Permission.bluetoothAdvertise:
      case Permission.bluetoothConnect:
        return 'Bluetooth';

      case Permission.contacts:
      case Permission.phone:
      case Permission.sms:
        return 'Communication';

      case Permission.calendar:
      case Permission.reminders:
        return 'Calendar';

      case Permission.sensors:
      case Permission.activityRecognition:
        return 'Sensors';

      case Permission.storage:
      case Permission.manageExternalStorage:
        return 'Storage';

      default:
        return 'Other';
    }
  }

  /// Check if permission is critical (usually required for core functionality)
  static bool isCriticalPermission(Permission permission) {
    return [
      Permission.camera,
      Permission.microphone,
      Permission.locationWhenInUse,
      Permission.storage,
    ].contains(permission);
  }

  /// Get minimum Android SDK version required for permission
  static int getMinimumSdkVersion(Permission permission) {
    return platformInfo[permission]?.minimumSdkVersion ?? 21;
  }

  /// Check if permission is available on current platform
  static bool isAvailableOnPlatform(Permission permission, String platform) {
    final info = platformInfo[permission];
    if (info == null) return true; // Assume available if no info

    switch (platform.toLowerCase()) {
      case 'android':
        return info.hasAndroidSupport;
      case 'ios':
        return info.hasIosSupport;
      default:
        return false;
    }
  }

  /// Helper method to capitalize first letter
  static String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
