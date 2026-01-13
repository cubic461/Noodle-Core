import 'package:json_annotation/json_annotation.dart';

part 'app_settings.g.dart';

/// App settings model
@JsonSerializable()
class AppSettings {
  final String serverUrl;
  final bool autoConnect;
  final bool notificationsEnabled;
  final bool darkMode;
  final String themeMode;
  final int connectionTimeout;
  final int maxRetries;
  final bool enableLogging;
  final String logLevel;

  const AppSettings({
    required this.serverUrl,
    required this.autoConnect,
    required this.notificationsEnabled,
    required this.darkMode,
    required this.themeMode,
    required this.connectionTimeout,
    required this.maxRetries,
    required this.enableLogging,
    required this.logLevel,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  AppSettings copyWith({
    String? serverUrl,
    bool? autoConnect,
    bool? notificationsEnabled,
    bool? darkMode,
    String? themeMode,
    int? connectionTimeout,
    int? maxRetries,
    bool? enableLogging,
    String? logLevel,
  }) {
    return AppSettings(
      serverUrl: serverUrl ?? this.serverUrl,
      autoConnect: autoConnect ?? this.autoConnect,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkMode: darkMode ?? this.darkMode,
      themeMode: themeMode ?? this.themeMode,
      connectionTimeout: connectionTimeout ?? this.connectionTimeout,
      maxRetries: maxRetries ?? this.maxRetries,
      enableLogging: enableLogging ?? this.enableLogging,
      logLevel: logLevel ?? this.logLevel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is AppSettings &&
      other.serverUrl == serverUrl &&
      other.autoConnect == autoConnect &&
      other.notificationsEnabled == notificationsEnabled &&
      other.darkMode == darkMode &&
      other.themeMode == themeMode &&
      other.connectionTimeout == connectionTimeout &&
      other.maxRetries == maxRetries &&
      other.enableLogging == enableLogging &&
      other.logLevel == logLevel;
  }

  @override
  int get hashCode {
    return serverUrl.hashCode ^
      autoConnect.hashCode ^
      notificationsEnabled.hashCode ^
      darkMode.hashCode ^
      themeMode.hashCode ^
      connectionTimeout.hashCode ^
      maxRetries.hashCode ^
      enableLogging.hashCode ^
      logLevel.hashCode;
  }

  @override
  String toString() {
    return 'AppSettings(serverUrl: $serverUrl, autoConnect: $autoConnect, notificationsEnabled: $notificationsEnabled, darkMode: $darkMode, themeMode: $themeMode, connectionTimeout: $connectionTimeout, maxRetries: $maxRetries, enableLogging: $enableLogging, logLevel: $logLevel)';
  }
}