import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

/// Authentication status enum
enum AuthStatus {
  @JsonValue('unauthenticated')
  unauthenticated,
  @JsonValue('authenticating')
  authenticating,
  @JsonValue('authenticated')
  authenticated,
  @JsonValue('error')
  error,
}

/// Connection status enum
enum ConnectionStatus {
  @JsonValue('disconnected')
  disconnected,
  @JsonValue('connecting')
  connecting,
  @JsonValue('connected')
  connected,
  @JsonValue('reconnecting')
  reconnecting,
  @JsonValue('error')
  error,
}

/// Node status enum
enum NodeStatus {
  @JsonValue('idle')
  idle,
  @JsonValue('running')
  running,
  @JsonValue('stopped')
  stopped,
  @JsonValue('error')
  error,
  @JsonValue('maintenance')
  maintenance,
}

/// Task status enum
enum TaskStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('running')
  running,
  @JsonValue('completed')
  completed,
  @JsonValue('failed')
  failed,
  @JsonValue('cancelled')
  cancelled,
}

/// User model
@JsonSerializable()
class User {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const User({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
  
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? avatar,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Device model
@JsonSerializable()
class Device {
  final String id;
  final String name;
  final String type;
  final String? model;
  final String? osVersion;
  final String? appVersion;
  final bool isActive;
  final DateTime lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Device({
    required this.id,
    required this.name,
    required this.type,
    this.model,
    this.osVersion,
    this.appVersion,
    required this.isActive,
    required this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceToJson(this);
  
  Device copyWith({
    String? id,
    String? name,
    String? type,
    String? model,
    String? osVersion,
    String? appVersion,
    bool? isActive,
    DateTime? lastSeen,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Device(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      model: model ?? this.model,
      osVersion: osVersion ?? this.osVersion,
      appVersion: appVersion ?? this.appVersion,
      isActive: isActive ?? this.isActive,
      lastSeen: lastSeen ?? this.lastSeen,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Node model
@JsonSerializable()
class Node {
  final String id;
  final String name;
  final String type;
  final NodeStatus status;
  final double? cpuUsage;
  final double? memoryUsage;
  final int? activeTasks;
  final int? totalTasks;
  final String? ipAddress;
  final int? port;
  final DateTime lastHeartbeat;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Node({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.cpuUsage,
    this.memoryUsage,
    this.activeTasks,
    this.totalTasks,
    this.ipAddress,
    this.port,
    required this.lastHeartbeat,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Node.fromJson(Map<String, dynamic> json) => _$NodeFromJson(json);
  Map<String, dynamic> toJson() => _$NodeToJson(this);
  
  Node copyWith({
    String? id,
    String? name,
    String? type,
    NodeStatus? status,
    double? cpuUsage,
    double? memoryUsage,
    int? activeTasks,
    int? totalTasks,
    String? ipAddress,
    int? port,
    DateTime? lastHeartbeat,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Node(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      cpuUsage: cpuUsage ?? this.cpuUsage,
      memoryUsage: memoryUsage ?? this.memoryUsage,
      activeTasks: activeTasks ?? this.activeTasks,
      totalTasks: totalTasks ?? this.totalTasks,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
      lastHeartbeat: lastHeartbeat ?? this.lastHeartbeat,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Task model
@JsonSerializable()
class Task {
  final String id;
  final String title;
  final String? description;
  final String nodeId;
  final TaskStatus status;
  final int? progress;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.nodeId,
    required this.status,
    this.progress,
    this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);
  Map<String, dynamic> toJson() => _$TaskToJson(this);
  
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? nodeId,
    TaskStatus? status,
    int? progress,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      nodeId: nodeId ?? this.nodeId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// IDE Project model
@JsonSerializable()
class IdeProject {
  final String id;
  final String name;
  final String? description;
  final String path;
  final String language;
  final bool isOpen;
  final DateTime lastAccessed;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const IdeProject({
    required this.id,
    required this.name,
    this.description,
    required this.path,
    required this.language,
    required this.isOpen,
    required this.lastAccessed,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory IdeProject.fromJson(Map<String, dynamic> json) => _$IdeProjectFromJson(json);
  Map<String, dynamic> toJson() => _$IdeProjectToJson(this);
  
  IdeProject copyWith({
    String? id,
    String? name,
    String? description,
    String? path,
    String? language,
    bool? isOpen,
    DateTime? lastAccessed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return IdeProject(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      path: path ?? this.path,
      language: language ?? this.language,
      isOpen: isOpen ?? this.isOpen,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

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
}