class CreateAgoraProfileRequest {
  final String agoraId;
  final String displayName;
  final String? bio;
  final String? phone;
  final String? birthday; // YYYY-MM-DD 형식
  final String? profileImage;

  CreateAgoraProfileRequest({
    required this.agoraId,
    required this.displayName,
    this.bio,
    this.phone,
    this.birthday,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'agoraId': agoraId,
      'displayName': displayName,
      if (bio != null) 'bio': bio,
      if (phone != null) 'phone': phone,
      if (birthday != null) 'birthday': birthday,
      if (profileImage != null) 'profileImage': profileImage,
    };
  }
}
