# 📖 Flutter Easy Permissions Manager

A simple wrapper around [`permission_handler`](https://pub.dev/packages/permission_handler) that makes requesting permissions in Flutter apps **easy and developer-friendly**.

- 🚀 Request multiple permissions with a single call
- ⚡ Provides clear error messages when `AndroidManifest.xml` or `Info.plist` entries are missing
- 🛡️ Helps you avoid common mistakes when handling permissions
- 🖥️ Prints **developer-friendly logs** with ready-to-copy fixes

---

## ✨ Features
- Request **single or multiple permissions**
- Automatically checks if **permissions are declared properly** in Android/iOS configs
- Provides **ready-to-copy XML/Plist entries** when missing
- 🖥️ Logs **quick CLI fix command** to auto-inject missing permissions
- Clean and minimal API

---

## ✅ Permissions Mapping (Android & iOS)

| Permission                    | Android Manifest                                                                 | iOS Info.plist                                                                 |
|--------------------------------|----------------------------------------------------------------------------------|--------------------------------------------------------------------------------|
| **Camera**                    | `<uses-permission android:name="android.permission.CAMERA" />`                   | `<key>NSCameraUsageDescription</key><string>App needs camera access.</string>` |
| **Microphone**                | `<uses-permission android:name="android.permission.RECORD_AUDIO" />`             | `<key>NSMicrophoneUsageDescription</key><string>App needs mic access.</string>`|
| **Photos / Videos**           | `<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />`        | `<key>NSPhotoLibraryUsageDescription</key><string>Access to photos.</string>`  |
| **Audio / Music Library**     | `<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />`         | `<key>NSAppleMusicUsageDescription</key><string>Access to music.</string>`     |
| **Location (When in Use)**    | `<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />`   | `<key>NSLocationWhenInUseUsageDescription</key><string>Access location.</string>`|
| **Location (Always)**         | `<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />`| `<key>NSLocationAlwaysAndWhenInUseUsageDescription</key><string>Background location.</string>`|
| **Bluetooth**                 | `<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />`        | `<key>NSBluetoothAlwaysUsageDescription</key><string>Bluetooth access.</string>`|
| **Contacts**                  | `<uses-permission android:name="android.permission.READ_CONTACTS" />`            | `<key>NSContactsUsageDescription</key><string>Access to contacts.</string>`   |
| **Calendar**                  | `<uses-permission android:name="android.permission.READ_CALENDAR" />`            | `<key>NSCalendarsUsageDescription</key><string>Access to calendar.</string>`  |
| **Reminders**                 | *(handled via calendar API)*                                                     | `<key>NSRemindersUsageDescription</key><string>Access to reminders.</string>` |
| **Activity / Sensors**        | `<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />`     | `<key>NSMotionUsageDescription</key><string>Access to motion sensors.</string>`|
| **Notifications**             | *(no Android manifest entry)*                                                    | `<key>NSUserNotificationUsageDescription</key><string>Send notifications.</string>`|
| **SMS**                       | `<uses-permission android:name="android.permission.SEND_SMS" />`                 | *(not allowed in iOS – use MFMessageComposeViewController)*                    |
| **Storage (Legacy)**          | `<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />`    | `<key>NSPhotoLibraryUsageDescription</key><string>Access to photos/media.</string>`|
| **Ignore Battery Optimizations** | `<uses-permission android:name="android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS" />` | *(not applicable on iOS)*                                                     |
| **System Alert Window**       | `<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />`      | *(not applicable on iOS)*                                                     |
| **Request Install Packages**  | `<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />` | *(not applicable on iOS)*                                                     |
| **Access Media Location**     | `<uses-permission android:name="android.permission.ACCESS_MEDIA_LOCATION" />`    | *(not applicable on iOS)*                                                     |
| **Nearby Wi-Fi Devices**      | `<uses-permission android:name="android.permission.NEARBY_WIFI_DEVICES" />`      | *(not applicable on iOS)*                                                     |

---

## 🚀 Usage Example

```dart
final result = await EasyPermissions.request([
  Permission.camera,
  Permission.microphone,
  Permission.locationWhenInUse,
]);

if (result.allGranted) {
  print("✅ All permissions granted!");
} else {
  print("❌ Missing: ${result.denied}");
}
```
---

## ⚡ CLI Commands

You can also run the injector manually without waiting for runtime errors.

Inject specific permissions
```log
dart run flutter_easy_permission_manager:auto_inject_permissions -p camera,location

```

---

## 🖥️ Developer Logs & Quick Fix

When a required permission is **not declared**, the logger will print a detailed fix message:

```log
🚨 Missing Permission Declaration
--------------------------------
❌ Permission: camera

👉 Android:
<uses-permission android:name="android.permission.CAMERA"/>

👉 iOS:
<key>NSCameraUsageDescription</key>
<string>App needs camera access.</string>

👉 Quick fix:
dart run flutter_easy_permission_manager:auto_inject_permissions -p camera,microphone
--------------------------------

```


