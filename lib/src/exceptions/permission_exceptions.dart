import 'package:permission_handler/permission_handler.dart';

class PermissionException implements Exception {
  final String message;
  final Permission? permission;

  const PermissionException(this.message, [this.permission]);

  @override
  String toString() => 'PermissionException: $message';
}

class PermissionNotDeclaredException extends PermissionException {
  final String androidHelp;
  final String iosHelp;

  PermissionNotDeclaredException({
    required Permission permission,
    required this.androidHelp,
    required this.iosHelp,
  }) : super(
          "❌ Permission $permission is not declared.\n\n"
          "👉 Android:\n$androidHelp\n\n"
          "👉 iOS:\n$iosHelp\n",
          permission,
        );
}

class PermissionTimeoutException extends PermissionException {
  PermissionTimeoutException(Permission permission)
      : super('Permission request timed out for $permission', permission);
}
