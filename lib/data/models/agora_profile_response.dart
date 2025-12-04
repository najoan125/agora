class AgoraProfileResponse {
  final String agoraId;
  final String displayName;
  final String? profileImageUrl;
  final String? statusMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  AgoraProfileResponse({
    required this.agoraId,
    required this.displayName,
    this.profileImageUrl,
    this.statusMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AgoraProfileResponse.fromJson(Map<String, dynamic> json) {
    return AgoraProfileResponse(
      agoraId: json['agoraId'] as String,
      displayName: json['displayName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      statusMessage: json['statusMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agoraId': agoraId,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'statusMessage': statusMessage,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
