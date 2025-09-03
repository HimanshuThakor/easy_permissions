# 📖 Easy Permissions – Supported Permissions

This package simplifies permission handling in Flutter.  
When a permission is missing from **AndroidManifest.xml** or **Info.plist**,  
the package will throw an error with **ready-to-copy XML/Plist entries**.

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
