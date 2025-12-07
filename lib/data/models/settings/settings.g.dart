// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationSettings _$NotificationSettingsFromJson(
        Map<String, dynamic> json) =>
    NotificationSettings(
      pushEnabled: json['pushEnabled'] as bool? ?? true,
      messageNotification: json['messageNotification'] as bool? ?? true,
      friendRequestNotification:
          json['friendRequestNotification'] as bool? ?? true,
      teamNotification: json['teamNotification'] as bool? ?? true,
      noticeNotification: json['noticeNotification'] as bool? ?? true,
      todoNotification: json['todoNotification'] as bool? ?? true,
      birthdayNotification: json['birthdayNotification'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      doNotDisturb: json['doNotDisturb'] == null
          ? null
          : DoNotDisturbSettings.fromJson(
              json['doNotDisturb'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NotificationSettingsToJson(
        NotificationSettings instance) =>
    <String, dynamic>{
      'pushEnabled': instance.pushEnabled,
      'messageNotification': instance.messageNotification,
      'friendRequestNotification': instance.friendRequestNotification,
      'teamNotification': instance.teamNotification,
      'noticeNotification': instance.noticeNotification,
      'todoNotification': instance.todoNotification,
      'birthdayNotification': instance.birthdayNotification,
      'soundEnabled': instance.soundEnabled,
      'vibrationEnabled': instance.vibrationEnabled,
      'doNotDisturb': instance.doNotDisturb,
    };

DoNotDisturbSettings _$DoNotDisturbSettingsFromJson(
        Map<String, dynamic> json) =>
    DoNotDisturbSettings(
      enabled: json['enabled'] as bool? ?? false,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
    );

Map<String, dynamic> _$DoNotDisturbSettingsToJson(
        DoNotDisturbSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
    };

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) =>
    PrivacySettings(
      profileVisibility: $enumDecodeNullable(
              _$ProfileVisibilityEnumMap, json['profileVisibility']) ??
          ProfileVisibility.public,
      phoneVisibility: $enumDecodeNullable(
              _$ProfileVisibilityEnumMap, json['phoneVisibility']) ??
          ProfileVisibility.friendsOnly,
      birthdayVisibility: $enumDecodeNullable(
              _$ProfileVisibilityEnumMap, json['birthdayVisibility']) ??
          ProfileVisibility.friendsOnly,
      allowFriendRequests: json['allowFriendRequests'] as bool? ?? true,
      showOnlineStatus: json['showOnlineStatus'] as bool? ?? true,
    );

Map<String, dynamic> _$PrivacySettingsToJson(PrivacySettings instance) =>
    <String, dynamic>{
      'profileVisibility':
          _$ProfileVisibilityEnumMap[instance.profileVisibility]!,
      'phoneVisibility': _$ProfileVisibilityEnumMap[instance.phoneVisibility]!,
      'birthdayVisibility':
          _$ProfileVisibilityEnumMap[instance.birthdayVisibility]!,
      'allowFriendRequests': instance.allowFriendRequests,
      'showOnlineStatus': instance.showOnlineStatus,
    };

const _$ProfileVisibilityEnumMap = {
  ProfileVisibility.public: 'PUBLIC',
  ProfileVisibility.friendsOnly: 'FRIENDS_ONLY',
  ProfileVisibility.private: 'PRIVATE',
};

BirthdayReminderSettings _$BirthdayReminderSettingsFromJson(
        Map<String, dynamic> json) =>
    BirthdayReminderSettings(
      enabled: json['enabled'] as bool? ?? true,
      daysBefore: (json['daysBefore'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$BirthdayReminderSettingsToJson(
        BirthdayReminderSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'daysBefore': instance.daysBefore,
    };
