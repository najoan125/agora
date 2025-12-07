import 'dart:async';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uni_links/uni_links.dart';
import '../core/utils/pkce_util.dart';
import '../core/utils/secure_storage_manager.dart';
import '../core/constants/api_endpoints.dart';
import '../core/exception/app_exception.dart';
import '../data/api_client.dart';

/// OAuth 2.0 + PKCE 인증 서비스
class OAuthService {
  final ApiClient _apiClient = ApiClient();
  StreamSubscription? _linkSubscription;

  // OAuth 콜백 컴플리터
  Completer<OAuthResult>? _authCompleter;

  /// Deep Link 리스너 초기화
  Future<void> initializeDeepLinkListener() async {
    // 앱이 종료된 상태에서 딥링크로 실행된 경우
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (e) {
      print('Failed to get initial URI: $e');
    }

    // 앱이 실행 중일 때 딥링크 수신
    _linkSubscription = uriLinkStream.listen(
      (Uri? uri) {
        if (uri != null) {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        print('Deep link error: $err');
        _authCompleter?.completeError(
          AppException.oauth(
            message: 'Deep link error',
            userMessage: '인증 콜백 처리 중 오류가 발생했습니다.',
            error: err,
          ),
        );
      },
    );
  }

  /// Deep Link 리스너 해제
  void dispose() {
    _linkSubscription?.cancel();
    _linkSubscription = null;
  }

  /// OAuth 로그인 취소 (브라우저 닫힘 등)
  void cancelOAuthLogin() {
    if (_authCompleter != null && !_authCompleter!.isCompleted) {
      _authCompleter!.completeError(
        AppException.oauth(
          message: 'OAuth cancelled',
          userMessage: '로그인이 취소되었습니다.',
        ),
      );
    }
    // PKCE 코드 정리
    SecureStorageManager.deleteCodeVerifier();
    SecureStorageManager.deleteOAuthState();
  }

  /// OAuth 진행 중인지 확인
  bool get isOAuthInProgress =>
      _authCompleter != null && !_authCompleter!.isCompleted;

  /// OAuth 로그인 시작
  Future<OAuthResult> startOAuthLogin() async {
    // PKCE 코드 생성
    final codePair = PkceUtil.generateCodePair();
    final state = PkceUtil.generateState();

    // 코드 저장 (토큰 교환 시 사용)
    await SecureStorageManager.saveCodeVerifier(codePair.verifier);
    await SecureStorageManager.saveOAuthState(state);

    // Authorization URL 생성
    final authUrl = _buildAuthorizationUrl(
      codeChallenge: codePair.challenge,
      state: state,
    );

    // 컴플리터 생성
    _authCompleter = Completer<OAuthResult>();

    // 브라우저에서 인증 페이지 열기
    final uri = Uri.parse(authUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
    } else {
      _authCompleter?.completeError(
        AppException.oauth(
          message: 'Cannot launch URL',
          userMessage: '브라우저를 열 수 없습니다.',
        ),
      );
    }

    // 콜백 대기
    return _authCompleter!.future;
  }

  /// Authorization URL 생성
  String _buildAuthorizationUrl({
    required String codeChallenge,
    required String state,
  }) {
    final queryParams = {
      'client_id': OAuthConfig.clientId,
      'response_type': OAuthConfig.responseType,
      'redirect_uri': OAuthConfig.redirectUri,
      'code_challenge': codeChallenge,
      'code_challenge_method': OAuthConfig.codeChallengeMethod,
      'state': state,
      'scope': OAuthConfig.scopes.join(' '),
    };

    final uri = Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.oauthAuthorize}')
        .replace(queryParameters: queryParams);

    return uri.toString();
  }

  /// Deep Link 처리
  Future<void> _handleDeepLink(Uri uri) async {
    // OAuth 콜백인지 확인
    if (uri.scheme != 'com.hyfata.agora' || uri.host != 'oauth') {
      return;
    }

    // 에러 확인
    final error = uri.queryParameters['error'];
    if (error != null) {
      final errorDescription = uri.queryParameters['error_description'] ?? '인증이 취소되었습니다.';
      _authCompleter?.completeError(
        AppException.oauth(
          message: error,
          userMessage: errorDescription,
        ),
      );
      return;
    }

    // Authorization Code 추출
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];

    if (code == null) {
      _authCompleter?.completeError(
        AppException.oauth(
          message: 'No authorization code',
          userMessage: '인증 코드를 받지 못했습니다.',
        ),
      );
      return;
    }

    // State 검증 (CSRF 방지)
    final savedState = await SecureStorageManager.getOAuthState();
    if (state != savedState) {
      _authCompleter?.completeError(
        AppException.oauth(
          message: 'State mismatch',
          userMessage: '보안 검증에 실패했습니다. 다시 시도해주세요.',
        ),
      );
      return;
    }

    // 토큰 교환
    try {
      final result = await exchangeCodeForToken(code);
      _authCompleter?.complete(result);
    } catch (e) {
      _authCompleter?.completeError(e);
    }
  }

  /// Authorization Code를 토큰으로 교환
  Future<OAuthResult> exchangeCodeForToken(String code) async {
    try {
      // 저장된 code_verifier 가져오기
      final codeVerifier = await SecureStorageManager.getCodeVerifier();
      if (codeVerifier == null) {
        throw AppException.oauth(
          message: 'No code verifier found',
          userMessage: '인증 정보가 유실되었습니다. 다시 시도해주세요.',
        );
      }

      // 토큰 교환 요청 (OAuth 표준: application/x-www-form-urlencoded)
      final response = await _apiClient.post(
        ApiEndpoints.oauthToken,
        data: {
          'grant_type': 'authorization_code',
          'code': code,
          'code_verifier': codeVerifier,
          'client_id': OAuthConfig.clientId,
          'redirect_uri': OAuthConfig.redirectUri,
        },
        options: Options(
          contentType: 'application/x-www-form-urlencoded',
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // 토큰 만료 시간 계산
        final expiresIn = data['expires_in'] as int?;
        DateTime? expiresAt;
        if (expiresIn != null) {
          expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
        }

        // 토큰 저장
        await _apiClient.saveTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          expiresAt: expiresAt,
        );

        // 사용자 정보 저장 (있는 경우)
        if (data['user'] != null) {
          await SecureStorageManager.saveUserInfo(
            userId: data['user']['id']?.toString(),
            email: data['user']['email'],
            agoraId: data['user']['agoraId'],
          );
        }

        // PKCE 코드 정리
        await SecureStorageManager.deleteCodeVerifier();
        await SecureStorageManager.deleteOAuthState();

        return OAuthResult(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          expiresAt: expiresAt,
          userId: data['user']?['id']?.toString(),
          email: data['user']?['email'],
          agoraId: data['user']?['agoraId'],
        );
      } else {
        throw AppException.oauth(
          message: 'Token exchange failed: ${response.statusCode}',
          userMessage: '토큰 교환에 실패했습니다.',
        );
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.oauth(
        message: 'Token exchange error: $e',
        userMessage: '인증 처리 중 오류가 발생했습니다.',
        error: e,
      );
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      // 저장된 refresh_token 가져오기
      final refreshToken = await SecureStorageManager.getRefreshToken();

      if (refreshToken != null) {
        // 서버에 로그아웃 요청 (JSON body)
        await _apiClient.post(
          ApiEndpoints.authLogout,
          data: {
            'refreshToken': refreshToken,
            'logoutAll': false,
          },
        );
      }
    } catch (e) {
      // 서버 에러는 무시하고 로컬 정리 진행
      print('Server logout failed: $e');
    } finally {
      // 로컬 세션 정리
      await SecureStorageManager.clearSession();
    }
  }
}

/// OAuth 인증 결과
class OAuthResult {
  final String accessToken;
  final String refreshToken;
  final DateTime? expiresAt;
  final String? userId;
  final String? email;
  final String? agoraId;

  const OAuthResult({
    required this.accessToken,
    required this.refreshToken,
    this.expiresAt,
    this.userId,
    this.email,
    this.agoraId,
  });

  @override
  String toString() =>
      'OAuthResult(userId: $userId, email: $email, agoraId: $agoraId)';
}
