/// API 엔드포인트 상수 정의
class ApiEndpoints {
  ApiEndpoints._();

  /// Base URL
  static const String baseUrl = 'https://api.hyfata.kr';

  // ============ OAuth ============
  static const String oauthAuthorize = '/oauth/authorize';
  static const String oauthToken = '/oauth/token';
  static const String oauthLogout = '/oauth/logout';

  // ============ Auth (Legacy) ============
  static const String authRegister = '/api/auth/register';
  static const String authLogin = '/api/auth/login';
  static const String authRefresh = '/api/auth/refresh';
  static const String authLogout = '/api/auth/logout';

  // ============ Account ============
  static const String accountPassword = '/api/account/password';
  static const String accountDeactivate = '/api/account/deactivate';
  static const String account = '/api/account';
  static const String accountRestore = '/api/account/restore';

  // ============ Profile ============
  static const String profile = '/api/agora/profile';
  static String profileById(String agoraId) => '/api/agora/profile/$agoraId';
  static const String profileSearch = '/api/agora/profile/search';
  static const String profileCheckId = '/api/agora/profile/check-id';
  static const String profileImage = '/api/agora/profile/image';

  // ============ Friends ============
  static const String friends = '/api/agora/friends';
  static const String friendRequest = '/api/agora/friends/request';
  static const String friendRequests = '/api/agora/friends/requests';
  static String friendRequestAccept(String id) =>
      '/api/agora/friends/requests/$id/accept';
  static String friendRequestReject(String id) =>
      '/api/agora/friends/requests/$id';
  static String friendDelete(String friendId) =>
      '/api/agora/friends/$friendId';
  static String friendFavorite(String friendId) =>
      '/api/agora/friends/$friendId/favorite';
  static String friendBlock(String friendId) =>
      '/api/agora/friends/$friendId/block';
  static const String friendsBlocked = '/api/agora/friends/blocked';
  static const String friendsBirthdays = '/api/agora/friends/birthdays';

  // ============ Chat ============
  static const String chats = '/api/agora/chats';
  static String chatById(String chatId) => '/api/agora/chats/$chatId';
  static String chatMessages(String chatId) =>
      '/api/agora/chats/$chatId/messages';
  static String chatMessageDelete(String chatId, String msgId) =>
      '/api/agora/chats/$chatId/messages/$msgId';
  static String chatRead(String chatId) => '/api/agora/chats/$chatId/read';

  // Context-based Chat API (신규)
  static const String chatsDirect = '/api/agora/chats/direct';

  // ============ Group Chat ============
  static const String groupChats = '/api/agora/chats/groups';
  static String groupChatById(String id) => '/api/agora/chats/groups/$id';
  static String groupChatMembers(String id) =>
      '/api/agora/chats/groups/$id/members';
  static String groupChatMemberRemove(String id, String userId) =>
      '/api/agora/chats/groups/$id/members/$userId';
  static String groupChatLeave(String id) => '/api/agora/chats/groups/$id/leave';

  // 신규 Group Chat API
  static const String groupChat = '/api/agora/chats/group';

  // ============ Chat Folder ============
  static const String chatFolders = '/api/agora/chats/folders';
  static String chatFolderById(String id) => '/api/agora/chats/folders/$id';
  static String chatToFolder(String folderId, String chatId) =>
      '/api/agora/chats/folders/$folderId/chats/$chatId';
  static String chatRemoveFromFolder(String folderId, String chatId) =>
      '/api/agora/chats/folders/$folderId/chats/$chatId';

  // ============ Files ============
  static const String fileUpload = '/api/agora/files/upload';
  static const String fileUploadImage = '/api/agora/files/upload-image';
  static String fileMeta(String fileId) => '/api/agora/files/meta/$fileId';
  static String fileById(String fileId) => '/api/agora/files/$fileId';
  static String fileDownload(String fileId) =>
      '/api/agora/files/$fileId/download';

  // ============ Notifications ============
  static const String notifications = '/api/agora/notifications';
  static const String notificationsUnreadCount =
      '/api/agora/notifications/unread-count';
  static String notificationRead(String id) =>
      '/api/agora/notifications/$id/read';
  static const String notificationsReadAll = '/api/agora/notifications/read-all';
  static String notificationDelete(String id) => '/api/agora/notifications/$id';
  static const String fcmToken = '/api/agora/notifications/fcm-token';

  // ============ Teams ============
  static const String teams = '/api/agora/teams';
  static String teamById(String id) => '/api/agora/teams/$id';
  static String teamMembers(String id) => '/api/agora/teams/$id/members';
  static String teamMemberRemove(String id, String memberId) =>
      '/api/agora/teams/$id/members/$memberId';
  static String teamMemberRole(String id, String memberId) =>
      '/api/agora/teams/$id/members/$memberId/role';

  // Team Invitations
  static String teamInvitations(String teamId) =>
      '/api/agora/teams/$teamId/invitations';
  static const String teamInvitationsReceived =
      '/api/agora/teams/invitations/received';
  static String teamInvitationAccept(String invitationId) =>
      '/api/agora/teams/invitations/$invitationId/accept';
  static String teamInvitationReject(String invitationId) =>
      '/api/agora/teams/invitations/$invitationId/reject';
  static String teamChat(String teamId) => '/api/agora/teams/$teamId/chat';

  // ============ Team Profile ============
  static const String teamProfile = '/api/agora/team-profile';
  static const String teamProfileImage = '/api/agora/team-profile/image';
  static const String teamProfileExists = '/api/agora/team-profile/exists';
  static String teamProfileByUserId(String userId) =>
      '/api/agora/team-profile/users/$userId';

  // ============ Team Features ============
  // Notices
  static String teamNotices(String teamId) =>
      '/api/agora/teams/$teamId/notices';
  static String teamNoticeById(String teamId, String id) =>
      '/api/agora/teams/$teamId/notices/$id';

  // Todos
  static String teamTodos(String teamId) => '/api/agora/teams/$teamId/todos';
  static String teamTodoById(String teamId, String id) =>
      '/api/agora/teams/$teamId/todos/$id';
  static String teamTodoComplete(String teamId, String id) =>
      '/api/agora/teams/$teamId/todos/$id/complete';

  // Events
  static String teamEvents(String teamId) => '/api/agora/teams/$teamId/events';
  static String teamEventById(String teamId, String id) =>
      '/api/agora/teams/$teamId/events/$id';

  // ============ Settings ============
  static const String settingsNotifications = '/api/agora/settings/notifications';
  static const String settingsPrivacy = '/api/agora/settings/privacy';
  static const String settingsBirthdayReminder =
      '/api/agora/settings/birthday-reminder';

  // ============ WebSocket ============
  static const String wsChat = 'wss://api.hyfata.kr:443/ws/agora/chat/websocket';
  static String wsChatTopic(String chatId) => '/topic/agora/chat/$chatId';
  static String wsChatSend(String chatId) => '/app/agora/chat/$chatId/send';
  static String wsChatRead(String chatId) => '/app/agora/chat/$chatId/read';
  static const String wsUserErrors = '/user/queue/errors';
}

/// OAuth 설정 상수
class OAuthConfig {
  OAuthConfig._();

  static const String clientId = 'client_1765097586523_9812';
  static const String redirectUri = 'com.hyfata.agora://oauth/callback';
  static const String responseType = 'code';
  static const String codeChallengeMethod = 'S256';
  static const List<String> scopes = ['user:email', 'user:profile'];
}
