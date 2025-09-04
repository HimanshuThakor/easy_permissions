import 'package:permission_handler/permission_handler.dart';

/// Represents a permission request with its configuration
class PermissionRequest {
  final Permission permission;
  final String? customRationale;
  final bool isRequired;
  final int priority;

  const PermissionRequest({
    required this.permission,
    this.customRationale,
    this.isRequired = true,
    this.priority = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionRequest &&
          runtimeType == other.runtimeType &&
          permission == other.permission;

  @override
  int get hashCode => permission.hashCode;

  @override
  String toString() => 'PermissionRequest(${permission.toString()})';

  Map<String, dynamic> toJson() => {
        'permission': permission.toString(),
        'customRationale': customRationale,
        'isRequired': isRequired,
        'priority': priority,
      };
}

/// Represents the status of a permission with additional metadata
class PermissionStatusInfo {
  final Permission permission;
  final PermissionStatus status;
  final DateTime lastChecked;
  final String? errorMessage;
  final bool wasRequestedInSession;

  const PermissionStatusInfo({
    required this.permission,
    required this.status,
    required this.lastChecked,
    this.errorMessage,
    this.wasRequestedInSession = false,
  });

  bool get isGranted => status.isGranted;

  bool get isDenied => status.isDenied;

  bool get isPermanentlyDenied => status.isPermanentlyDenied;

  bool get isRestricted => status.isRestricted;

  bool get isLimited => status.isLimited;

  bool get isProvisional => status.isProvisional;

  PermissionStatusInfo copyWith({
    PermissionStatus? status,
    DateTime? lastChecked,
    String? errorMessage,
    bool? wasRequestedInSession,
  }) {
    return PermissionStatusInfo(
      permission: permission,
      status: status ?? this.status,
      lastChecked: lastChecked ?? this.lastChecked,
      errorMessage: errorMessage ?? this.errorMessage,
      wasRequestedInSession:
          wasRequestedInSession ?? this.wasRequestedInSession,
    );
  }

  Map<String, dynamic> toJson() => {
        'permission': permission.toString(),
        'status': status.toString(),
        'lastChecked': lastChecked.toIso8601String(),
        'errorMessage': errorMessage,
        'wasRequestedInSession': wasRequestedInSession,
      };
}

/// Represents a group of related permissions
class PermissionGroup {
  final String name;
  final String description;
  final List<Permission> permissions;
  final bool allRequired;
  final String? rationale;

  const PermissionGroup({
    required this.name,
    required this.description,
    required this.permissions,
    this.allRequired = true,
    this.rationale,
  });

  bool get isEmpty => permissions.isEmpty;

  int get count => permissions.length;

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'permissions': permissions.map((p) => p.toString()).toList(),
        'allRequired': allRequired,
        'rationale': rationale,
      };
}

/// Platform-specific permission information
class PlatformPermissionInfo {
  final Permission permission;
  final String? androidPermission;
  final String? androidFeature;
  final String? iosUsageDescription;
  final String? iosInfoPlistKey;
  final List<String> requiredCapabilities;
  final int minimumSdkVersion;

  const PlatformPermissionInfo({
    required this.permission,
    this.androidPermission,
    this.androidFeature,
    this.iosUsageDescription,
    this.iosInfoPlistKey,
    this.requiredCapabilities = const [],
    this.minimumSdkVersion = 21,
  });

  bool get hasAndroidSupport => androidPermission != null;

  bool get hasIosSupport => iosUsageDescription != null;

  bool get requiresFeature => androidFeature != null;

  Map<String, dynamic> toJson() => {
        'permission': permission.toString(),
        'androidPermission': androidPermission,
        'androidFeature': androidFeature,
        'iosUsageDescription': iosUsageDescription,
        'iosInfoPlistKey': iosInfoPlistKey,
        'requiredCapabilities': requiredCapabilities,
        'minimumSdkVersion': minimumSdkVersion,
      };
}

/// Detailed permission analytics
class PermissionAnalytics {
  final Map<Permission, int> requestCounts;
  final Map<Permission, DateTime> lastRequested;
  final Map<Permission, List<PermissionStatus>> statusHistory;
  final Duration totalProcessingTime;
  final int successfulRequests;
  final int failedRequests;

  const PermissionAnalytics({
    required this.requestCounts,
    required this.lastRequested,
    required this.statusHistory,
    required this.totalProcessingTime,
    required this.successfulRequests,
    required this.failedRequests,
  });

  int get totalRequests => successfulRequests + failedRequests;

  double get successRate =>
      totalRequests > 0 ? (successfulRequests / totalRequests) * 100 : 0.0;

  Permission? get mostRequestedPermission {
    if (requestCounts.isEmpty) return null;
    return requestCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  Map<String, dynamic> toJson() => {
        'requestCounts': requestCounts.map(
          (k, v) => MapEntry(k.toString(), v),
        ),
        'lastRequested': lastRequested.map(
          (k, v) => MapEntry(k.toString(), v.toIso8601String()),
        ),
        'totalProcessingTimeMs': totalProcessingTime.inMilliseconds,
        'successfulRequests': successfulRequests,
        'failedRequests': failedRequests,
        'successRate': successRate,
        'mostRequestedPermission': mostRequestedPermission?.toString(),
      };
}
