class AgoraProfileResponse {
  final int? userId;
  final String agoraId;
  final String displayName;
  final String? profileImage;
  final String? bio;
  final String? phone;
  final String? birthday;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AgoraProfileResponse({
    this.userId,
    required this.agoraId,
    required this.displayName,
    this.profileImage,
    this.bio,
    this.phone,
    this.birthday,
    this.createdAt,
    this.updatedAt,
  });

  factory AgoraProfileResponse.fromJson(Map<String, dynamic> json) {
    return AgoraProfileResponse(
      userId: json['userId'] as int?,
      agoraId: json['agoraId'] as String,
      displayName: json['displayName'] as String,
      profileImage: json['profileImage'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      birthday: json['birthday'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'userId': userId,
      'agoraId': agoraId,
      'displayName': displayName,
      'profileImage': profileImage,
      'bio': bio,
      'phone': phone,
      'birthday': birthday,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // 하위 호환성을 위한 getter
  String? get profileImageUrl => profileImage;

  String? get statusMessage => bio;
}
