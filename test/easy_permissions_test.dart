import 'package:flutter_easy_permissions/flutter_easy_permissions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  group('PermissionResult', () {
    test('allGranted returns true when no denied permissions', () {
      final result = PermissionResult(
        granted: [Permission.camera, Permission.microphone],
        denied: [],
      );

      expect(result.allGranted, true);
    });

    test('allGranted returns false when some permissions denied', () {
      final result = PermissionResult(
        granted: [Permission.camera],
        denied: [Permission.microphone],
      );

      expect(result.allGranted, false);
      expect(result.denied.contains(Permission.microphone), true);
    });
  });
}
