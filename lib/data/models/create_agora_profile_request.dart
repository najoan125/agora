class CreateAgoraProfileRequest {
  final String agoraId;
  final String displayName;
  final String? statusMessage;

  CreateAgoraProfileRequest({
    required this.agoraId,
    required this.displayName,
    this.statusMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'agoraId': agoraId,
      'displayName': displayName,
      if (statusMessage != null) 'statusMessage': statusMessage,
    };
  }
}
