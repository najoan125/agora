class UpdateAgoraProfileRequest {
  final String? displayName;
  final String? statusMessage;

  UpdateAgoraProfileRequest({
    this.displayName,
    this.statusMessage,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (displayName != null) data['displayName'] = displayName;
    if (statusMessage != null) data['statusMessage'] = statusMessage;
    return data;
  }
}
