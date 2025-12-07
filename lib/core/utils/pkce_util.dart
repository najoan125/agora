import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// PKCE (Proof Key for Code Exchange) 유틸리티
/// OAuth 2.0 인증에서 Authorization Code 가로채기 공격을 방지
class PkceUtil {
  PkceUtil._();

  /// code_verifier 생성 (43-128자의 랜덤 문자열)
  /// RFC 7636 권장: 43-128 문자
  static String generateCodeVerifier({int length = 128}) {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// code_challenge 생성 (code_verifier의 SHA256 해시 → Base64URL 인코딩)
  static String generateCodeChallenge(String codeVerifier) {
    // SHA256 해시
    final bytes = utf8.encode(codeVerifier);
    final digest = sha256.convert(bytes);

    // Base64URL 인코딩 (패딩 제거)
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// PKCE 코드 쌍 생성
  static PkceCodePair generateCodePair() {
    final verifier = generateCodeVerifier();
    final challenge = generateCodeChallenge(verifier);
    return PkceCodePair(verifier: verifier, challenge: challenge);
  }

  /// code_verifier 유효성 검증
  static bool isValidCodeVerifier(String verifier) {
    if (verifier.length < 43 || verifier.length > 128) {
      return false;
    }
    // RFC 7636 허용 문자: [A-Z] / [a-z] / [0-9] / "-" / "." / "_" / "~"
    final validPattern = RegExp(r'^[A-Za-z0-9\-._~]+$');
    return validPattern.hasMatch(verifier);
  }

  /// state 파라미터 생성 (CSRF 방지)
  static String generateState({int length = 32}) {
    const charset =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}

/// PKCE 코드 쌍 (verifier + challenge)
class PkceCodePair {
  final String verifier;
  final String challenge;

  const PkceCodePair({
    required this.verifier,
    required this.challenge,
  });

  @override
  String toString() =>
      'PkceCodePair(verifier: ${verifier.substring(0, 10)}..., challenge: $challenge)';
}
