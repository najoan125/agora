import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

/// 알림 타입
enum NotificationType {
  @JsonValue('FRIEND_REQUEST')
  friendRequest,
  @JsonValue('MESSAGE')
  message,
  @JsonValue('GROUP_INVITE')
  groupInvite,
  @JsonValue('TEAM_INVITE')
  teamInvite,
  @JsonValue('NOTICE')
  notice,
  @JsonValue('TODO_ASSIGNED')
  todoAssigned,
  @JsonValue('BIRTHDAY')
  birthday,
}

/// 알림 모델
@JsonSerializable()
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String content;
  final String? relatedId;
  final String? relatedType;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    this.relatedId,
    this.relatedType,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? content,
    String? relatedId,
    String? relatedType,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 알림 목록 응답
@JsonSerializable()
class NotificationListResponse {
  final List<AppNotification> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool last;

  const NotificationListResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationListResponseToJson(this);
}

/// 읽지 않은 알림 수 응답
@JsonSerializable()
class UnreadCountResponse {
  final int count;

  const UnreadCountResponse({required this.count});

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) =>
      _$UnreadCountResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UnreadCountResponseToJson(this);
}
