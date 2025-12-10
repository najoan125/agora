import 'package:json_annotation/json_annotation.dart';

part 'settings.g.dart';

/// 알림 설정
@JsonSerializable()
class NotificationSettings {
  final bool pushEnabled;
  final bool messageNotification;
  final bool friendRequestNotification;
  final bool teamNotification;
  final bool noticeNotification;
  final bool todoNotification;
  final bool birthdayNotification;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final DoNotDisturbSettings? doNotDisturb;

  const NotificationSettings({
    this.pushEnabled = true,
    this.messageNotification = true,
    this.friendRequestNotification = true,
    this.teamNotification = true,
    this.noticeNotification = true,
    this.todoNotification = true,
    this.birthdayNotification = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.doNotDisturb,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationSettingsToJson(this);

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? messageNotification,
    bool? friendRequestNotification,
    bool? teamNotification,
    bool? noticeNotification,
    bool? todoNotification,
    bool? birthdayNotification,
    bool? soundEnabled,
    bool? vibrationEnabled,
    DoNotDisturbSettings? doNotDisturb,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      messageNotification: messageNotification ?? this.messageNotification,
      friendRequestNotification:
          friendRequestNotification ?? this.friendRequestNotification,
      teamNotification: teamNotification ?? this.teamNotification,
      noticeNotification: noticeNotification ?? this.noticeNotification,
      todoNotification: todoNotification ?? this.todoNotification,
      birthdayNotification: birthdayNotification ?? this.birthdayNotification,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      doNotDisturb: doNotDisturb ?? this.doNotDisturb,
    );
  }
}

/// 방해 금지 설정
@JsonSerializable()
class DoNotDisturbSettings {
  final bool enabled;
  final String? startTime; // HH:mm 형식
  final String? endTime; // HH:mm 형식

  const DoNotDisturbSettings({
    this.enabled = false,
    this.startTime,
    this.endTime,
  });

  factory DoNotDisturbSettings.fromJson(Map<String, dynamic> json) =>
      _$DoNotDisturbSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$DoNotDisturbSettingsToJson(this);
}

/// 프로필 공개 범위
enum ProfileVisibility {
  @JsonValue('PUBLIC')
  public,
  @JsonValue('FRIENDS')
  friends,
  @JsonValue('NONE')
  none,
}

/// 개인정보 설정
@JsonSerializable()
class PrivacySettings {
  final ProfileVisibility profileVisibility;
  final ProfileVisibility phoneVisibility;
  final ProfileVisibility birthdayVisibility;
  final bool allowFriendRequests;
  final bool allowGroupInvites;
  final bool showOnlineStatus;
  final int sessionTimeout;

  const PrivacySettings({
    this.profileVisibility = ProfileVisibility.public,
    this.phoneVisibility = ProfileVisibility.friends,
    this.birthdayVisibility = ProfileVisibility.friends,
    this.allowFriendRequests = true,
    this.allowGroupInvites = true,
    this.showOnlineStatus = true,
    this.sessionTimeout = 30,
  });

  factory PrivacySettings.fromJson(Map<String, dynamic> json) =>
      _$PrivacySettingsFromJson(json);
  Map<String, dynamic> toJson() => _$PrivacySettingsToJson(this);

  PrivacySettings copyWith({
    ProfileVisibility? profileVisibility,
    ProfileVisibility? phoneVisibility,
    ProfileVisibility? birthdayVisibility,
    bool? allowFriendRequests,
    bool? allowGroupInvites,
    bool? showOnlineStatus,
    int? sessionTimeout,
  }) {
    return PrivacySettings(
      profileVisibility: profileVisibility ?? this.profileVisibility,
      phoneVisibility: phoneVisibility ?? this.phoneVisibility,
      birthdayVisibility: birthdayVisibility ?? this.birthdayVisibility,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      allowGroupInvites: allowGroupInvites ?? this.allowGroupInvites,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
    );
  }
}

/// 생일 알림 설정
@JsonSerializable()
class BirthdayReminderSettings {
  final bool enabled;
  final int daysBefore; // 며칠 전에 알림

  const BirthdayReminderSettings({
    this.enabled = true,
    this.daysBefore = 1,
  });

  factory BirthdayReminderSettings.fromJson(Map<String, dynamic> json) =>
      _$BirthdayReminderSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$BirthdayReminderSettingsToJson(this);
}
