import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/secure_storage_manager.dart';
import '../../core/exception/app_exception.dart';
import '../../services/oauth_service.dart';

/// 인증 상태
enum AuthStatus {
  initial,       // 초기 상태
  checking,      // 저장된 토큰 확인 중
  authenticating, // 로그인 진행 중
  authenticated, // 로그인됨
  unauthenticated, // 로그인 안됨
  error,         // 에러 발생
}

/// 인증 상태 모델
class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? email;
  final String? agoraId;
  final String? accessToken;
  final DateTime? expiresAt;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.email,
    this.agoraId,
    this.accessToken,
    this.expiresAt,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading =>
      status == AuthStatus.checking || status == AuthStatus.authenticating;

  bool get isTokenValid {
    if (expiresAt == null) return accessToken != null;
    return DateTime.now().isBefore(expiresAt!);
  }

  Duration? get timeUntilExpiration {
    if (expiresAt == null) return null;
    final diff = expiresAt!.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? email,
    String? agoraId,
    String? accessToken,
    DateTime? expiresAt,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      agoraId: agoraId ?? this.agoraId,
      accessToken: accessToken ?? this.accessToken,
      expiresAt: expiresAt ?? this.expiresAt,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  factory AuthState.checking() => const AuthState(status: AuthStatus.checking);

  factory AuthState.authenticating() =>
      const AuthState(status: AuthStatus.authenticating);

  factory AuthState.authenticated({
    required String accessToken,
    String? userId,
    String? email,
    String? agoraId,
    DateTime? expiresAt,
  }) {
    return AuthState(
      status: AuthStatus.authenticated,
      accessToken: accessToken,
      userId: userId,
      email: email,
      agoraId: agoraId,
      expiresAt: expiresAt,
    );
  }

  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  factory AuthState.error(String message) => AuthState(
        status: AuthStatus.error,
        errorMessage: message,
      );
}

/// 인증 상태 관리 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final OAuthService _oauthService;

  AuthNotifier(this._oauthService) : super(AuthState.initial()) {
    _initialize();
  }

  /// 앱 시작 시 저장된 토큰 확인
  Future<void> _initialize() async {
    state = AuthState.checking();

    try {
      final isLoggedIn = await SecureStorageManager.isLoggedIn();

      if (isLoggedIn) {
        // 토큰 유효성 검사
        final isValid = await SecureStorageManager.isAccessTokenValid();

        if (isValid) {
          final accessToken = await SecureStorageManager.getAccessToken();
          final userId = await SecureStorageManager.getUserId();
          final email = await SecureStorageManager.getUserEmail();
          final agoraId = await SecureStorageManager.getAgoraId();
          final expiresAt = await SecureStorageManager.getTokenExpiresAt();

          state = AuthState.authenticated(
            accessToken: accessToken!,
            userId: userId,
            email: email,
            agoraId: agoraId,
            expiresAt: expiresAt,
          );
        } else {
          // 토큰 만료됨 - 로그아웃 처리
          await SecureStorageManager.clearSession();
          state = AuthState.unauthenticated();
        }
      } else {
        state = AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error('초기화 중 오류가 발생했습니다.');
    }
  }

  /// OAuth 로그인 시작
  Future<void> startOAuthLogin() async {
    state = AuthState.authenticating();

    try {
      final result = await _oauthService.startOAuthLogin();

      state = AuthState.authenticated(
        accessToken: result.accessToken,
        userId: result.userId,
        email: result.email,
        agoraId: result.agoraId,
        expiresAt: result.expiresAt,
      );
    } on AppException catch (e) {
      state = AuthState.error(e.displayMessage);
    } catch (e) {
      state = AuthState.error('로그인 중 오류가 발생했습니다.');
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      await _oauthService.logout();
    } finally {
      state = AuthState.unauthenticated();
    }
  }

  /// 강제 로그아웃 (토큰 만료 등)
  Future<void> forceLogout() async {
    await SecureStorageManager.clearSession();
    state = AuthState.unauthenticated();
  }

  /// 에러 상태 초기화
  void clearError() {
    if (state.status == AuthStatus.error) {
      state = AuthState.unauthenticated();
    }
  }

  /// 인증 상태 새로고침
  Future<void> refresh() async {
    await _initialize();
  }
}

// ============ Providers ============

/// OAuth 서비스 Provider
final oauthServiceProvider = Provider<OAuthService>((ref) {
  final service = OAuthService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// 인증 상태 Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final oauthService = ref.watch(oauthServiceProvider);
  return AuthNotifier(oauthService);
});

/// 인증 여부 Provider (편의용)
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

/// 로딩 상태 Provider
final isAuthenticatingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

/// 현재 사용자 이메일 Provider
final currentUserEmailProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).email;
});

/// 현재 Agora ID Provider
final currentAgoraIdProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).agoraId;
});

/// 에러 메시지 Provider
final authErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(authProvider);
  return state.status == AuthStatus.error ? state.errorMessage : null;
});

/// 토큰 유효성 Provider
final tokenValidityProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isTokenValid;
});

/// 토큰 만료까지 남은 시간 Provider
final timeUntilTokenExpirationProvider = Provider<Duration?>((ref) {
  return ref.watch(authProvider).timeUntilExpiration;
});
