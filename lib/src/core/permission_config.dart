class PermissionConfig {
  final bool throwOnError;
  final bool throwOnUndeclaredPermission;
  final bool openSettingsOnPermanentDenial;
  final int maxRetries;
  final Duration delayBetweenRetries;
  final bool enableLogging;

  // Auto-injection settings
  final bool enableAutoInjection;
  final bool autoInjectAndroid;
  final bool autoInjectIOS;
  final bool createBackupBeforeInjection;
  final bool showInjectionWarnings;
  final bool requireAppRestartAfterInjection;

  const PermissionConfig({
    this.throwOnError = false,
    this.throwOnUndeclaredPermission =
        false, // Changed default to false for auto-injection
    this.openSettingsOnPermanentDenial = true,
    this.maxRetries = 2,
    this.delayBetweenRetries = const Duration(seconds: 1),
    this.enableLogging = false,

    // Auto-injection defaults
    this.enableAutoInjection = true,
    this.autoInjectAndroid = true,
    this.autoInjectIOS = true,
    this.createBackupBeforeInjection = true,
    this.showInjectionWarnings = true,
    this.requireAppRestartAfterInjection = true,
  });

  factory PermissionConfig.defaultConfig() => const PermissionConfig();

  /// Strict mode - throws errors, no auto-injection
  factory PermissionConfig.strict() => const PermissionConfig(
        throwOnError: true,
        throwOnUndeclaredPermission: true,
        openSettingsOnPermanentDenial: false,
        maxRetries: 0,
        enableAutoInjection: false,
        showInjectionWarnings: true,
      );

  /// Lenient mode - auto-injection enabled, no errors thrown
  factory PermissionConfig.lenient() => const PermissionConfig(
        throwOnError: false,
        throwOnUndeclaredPermission: false,
        openSettingsOnPermanentDenial: true,
        maxRetries: 3,
        delayBetweenRetries: Duration(seconds: 2),
        enableAutoInjection: true,
        showInjectionWarnings: false, // Less verbose
      );

  /// Development mode - auto-injection with detailed logging
  factory PermissionConfig.development() => const PermissionConfig(
        throwOnError: false,
        throwOnUndeclaredPermission: false,
        openSettingsOnPermanentDenial: true,
        maxRetries: 1,
        enableLogging: true,
        enableAutoInjection: true,
        showInjectionWarnings: true,
        createBackupBeforeInjection: true,
      );

  /// Production mode - no auto-injection, strict error handling
  factory PermissionConfig.production() => const PermissionConfig(
        throwOnError: false,
        throwOnUndeclaredPermission: true,
        openSettingsOnPermanentDenial: true,
        maxRetries: 2,
        enableLogging: false,
        enableAutoInjection: false, // Disabled for production
        showInjectionWarnings: false,
      );

  /// Auto-injection only mode - focuses on fixing missing permissions
  factory PermissionConfig.autoInjectionOnly() => const PermissionConfig(
        throwOnError: false,
        throwOnUndeclaredPermission: false,
        maxRetries: 0, // Don't retry, just inject
        enableAutoInjection: true,
        autoInjectAndroid: true,
        autoInjectIOS: true,
        showInjectionWarnings: true,
        requireAppRestartAfterInjection: true,
      );

  /// Copy configuration with modified values
  PermissionConfig copyWith({
    bool? throwOnError,
    bool? throwOnUndeclaredPermission,
    bool? openSettingsOnPermanentDenial,
    int? maxRetries,
    Duration? delayBetweenRetries,
    bool? enableLogging,
    bool? enableAutoInjection,
    bool? autoInjectAndroid,
    bool? autoInjectIOS,
    bool? createBackupBeforeInjection,
    bool? showInjectionWarnings,
    bool? requireAppRestartAfterInjection,
  }) {
    return PermissionConfig(
      throwOnError: throwOnError ?? this.throwOnError,
      throwOnUndeclaredPermission:
          throwOnUndeclaredPermission ?? this.throwOnUndeclaredPermission,
      openSettingsOnPermanentDenial:
          openSettingsOnPermanentDenial ?? this.openSettingsOnPermanentDenial,
      maxRetries: maxRetries ?? this.maxRetries,
      delayBetweenRetries: delayBetweenRetries ?? this.delayBetweenRetries,
      enableLogging: enableLogging ?? this.enableLogging,
      enableAutoInjection: enableAutoInjection ?? this.enableAutoInjection,
      autoInjectAndroid: autoInjectAndroid ?? this.autoInjectAndroid,
      autoInjectIOS: autoInjectIOS ?? this.autoInjectIOS,
      createBackupBeforeInjection:
          createBackupBeforeInjection ?? this.createBackupBeforeInjection,
      showInjectionWarnings:
          showInjectionWarnings ?? this.showInjectionWarnings,
      requireAppRestartAfterInjection: requireAppRestartAfterInjection ??
          this.requireAppRestartAfterInjection,
    );
  }

  @override
  String toString() {
    return 'PermissionConfig('
        'throwOnError: $throwOnError, '
        'throwOnUndeclaredPermission: $throwOnUndeclaredPermission, '
        'enableAutoInjection: $enableAutoInjection, '
        'maxRetries: $maxRetries'
        ')';
  }

  /// Convert to JSON for debugging
  Map<String, dynamic> toJson() => {
        'throwOnError': throwOnError,
        'throwOnUndeclaredPermission': throwOnUndeclaredPermission,
        'openSettingsOnPermanentDenial': openSettingsOnPermanentDenial,
        'maxRetries': maxRetries,
        'delayBetweenRetries': delayBetweenRetries.inMilliseconds,
        'enableLogging': enableLogging,
        'enableAutoInjection': enableAutoInjection,
        'autoInjectAndroid': autoInjectAndroid,
        'autoInjectIOS': autoInjectIOS,
        'createBackupBeforeInjection': createBackupBeforeInjection,
        'showInjectionWarnings': showInjectionWarnings,
        'requireAppRestartAfterInjection': requireAppRestartAfterInjection,
      };
}
