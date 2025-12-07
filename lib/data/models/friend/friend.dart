import 'package:json_annotation/json_annotation.dart';

part 'friend.g.dart';

/// 친구 모델
@JsonSerializable()
class Friend {
  @JsonKey(name: 'friendId')
  final dynamic id;
  final String agoraId;
  final String displayName;
  @JsonKey(name: 'profileImage')
  final String? profileImageUrl;
  final String? statusMessage;
  final String? phone;
  final DateTime? birthday;
  final bool isFavorite;
  final bool isOnline;
  final DateTime? lastOnlineAt;
  final DateTime createdAt;

  const Friend({
    required this.id,
    required this.agoraId,
    required this.displayName,
    this.profileImageUrl,
    this.statusMessage,
    this.phone,
    this.birthday,
    this.isFavorite = false,
    this.isOnline = false,
    this.lastOnlineAt,
    required this.createdAt,
  });

  factory Friend.fromJson(Map<String, dynamic> json) => _$FriendFromJson(json);
  Map<String, dynamic> toJson() => _$FriendToJson(this);

  Friend copyWith({
    String? id,
    String? agoraId,
    String? displayName,
    String? profileImageUrl,
    String? statusMessage,
    String? phone,
    DateTime? birthday,
    bool? isFavorite,
    bool? isOnline,
    DateTime? lastOnlineAt,
    DateTime? createdAt,
  }) {
    return Friend(
      id: id ?? this.id,
      agoraId: agoraId ?? this.agoraId,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      statusMessage: statusMessage ?? this.statusMessage,
      phone: phone ?? this.phone,
      birthday: birthday ?? this.birthday,
      isFavorite: isFavorite ?? this.isFavorite,
      isOnline: isOnline ?? this.isOnline,
      lastOnlineAt: lastOnlineAt ?? this.lastOnlineAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// 생일까지 남은 일수 (오늘 기준)
  int? get daysUntilBirthday {
    if (birthday == null) return null;
    final now = DateTime.now();
    var nextBirthday = DateTime(now.year, birthday!.month, birthday!.day);
    if (nextBirthday.isBefore(now)) {
      nextBirthday = DateTime(now.year + 1, birthday!.month, birthday!.day);
    }
    return nextBirthday.difference(now).inDays;
  }

  /// 오늘이 생일인지
  bool get isBirthdayToday {
    if (birthday == null) return false;
    final now = DateTime.now();
    return birthday!.month == now.month && birthday!.day == now.day;
  }
}

/// 친구 목록 페이지네이션 응답
@JsonSerializable()
class FriendListResponse {
  final List<Friend> content;
  final int pageNumber;
  final int pageSize;
  final int totalElements;
  final int totalPages;
  final bool last;

  const FriendListResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  factory FriendListResponse.fromJson(Map<String, dynamic> json) =>
      _$FriendListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$FriendListResponseToJson(this);
}
