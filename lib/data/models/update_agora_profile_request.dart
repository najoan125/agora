class UpdateAgoraProfileRequest {
  final String? agoraId;
  final String? displayName;
  final String? bio;
  final String? phone;
  final String? birthday; // YYYY-MM-DD 형식

  UpdateAgoraProfileRequest({
    this.agoraId,
    this.displayName,
    this.bio,
    this.phone,
    this.birthday,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (agoraId != null) data['agoraId'] = agoraId;
    if (displayName != null) data['displayName'] = displayName;
    if (bio != null) data['bio'] = bio;
    if (phone != null) data['phone'] = phone;
    if (birthday != null) data['birthday'] = birthday;
    return data;
  }
}
