import 'package:permission_handler/permission_handler.dart';

class PermissionResult {
  final List<Permission> granted;
  final List<Permission> denied;
  final List<Permission> undeclared;
  final List<Permission> permanentlyDenied;

  PermissionResult({
    List<Permission>? granted,
    List<Permission>? denied,
    List<Permission>? undeclared,
    List<Permission>? permanentlyDenied,
  })  : granted = granted ?? [],
        denied = denied ?? [],
        undeclared = undeclared ?? [],
        permanentlyDenied = permanentlyDenied ?? [];

  /// Check if all requested permissions were granted
  bool get allGranted =>
      denied.isEmpty && undeclared.isEmpty && permanentlyDenied.isEmpty;

  /// Check if any permissions were denied
  bool get hasDenied => denied.isNotEmpty;

  /// Check if any permissions are permanently denied
  bool get hasPermanentlyDenied => permanentlyDenied.isNotEmpty;

  /// Check if any permissions are undeclared
  bool get hasUndeclared => undeclared.isNotEmpty;

  /// Get total count of all permissions processed
  int get totalCount =>
      granted.length +
      denied.length +
      undeclared.length +
      permanentlyDenied.length;

  /// Get success rate as percentage
  double get successRate =>
      totalCount > 0 ? (granted.length / totalCount) * 100 : 0.0;

  /// Get all non-granted permissions (denied + undeclared + permanently denied)
  List<Permission> get notGranted => [
        ...denied,
        ...undeclared,
        ...permanentlyDenied,
      ];

  @override
  String toString() {
    return 'PermissionResult('
        'granted: ${granted.length}, '
        'denied: ${denied.length}, '
        'undeclared: ${undeclared.length}, '
        'permanentlyDenied: ${permanentlyDenied.length}'
        ')';
  }

  /// Convert to JSON for logging/debugging
  Map<String, dynamic> toJson() => {
        'granted': granted.map((p) => p.toString()).toList(),
        'denied': denied.map((p) => p.toString()).toList(),
        'undeclared': undeclared.map((p) => p.toString()).toList(),
        'permanentlyDenied':
            permanentlyDenied.map((p) => p.toString()).toList(),
        'successRate': successRate,
        'totalCount': totalCount,
      };

  /// Create a copy with updated values
  PermissionResult copyWith({
    List<Permission>? granted,
    List<Permission>? denied,
    List<Permission>? undeclared,
    List<Permission>? permanentlyDenied,
  }) {
    return PermissionResult(
      granted: granted ?? this.granted,
      denied: denied ?? this.denied,
      undeclared: undeclared ?? this.undeclared,
      permanentlyDenied: permanentlyDenied ?? this.permanentlyDenied,
    );
  }

  /// Merge this result with another result
  PermissionResult merge(PermissionResult other) {
    return PermissionResult(
      granted: [...granted, ...other.granted],
      denied: [...denied, ...other.denied],
      undeclared: [...undeclared, ...other.undeclared],
      permanentlyDenied: [...permanentlyDenied, ...other.permanentlyDenied],
    );
  }
}
