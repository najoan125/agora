/// 앱 전체에서 사용하는 통합 예외 클래스
class AppException implements Exception {
  final String code;
  final String message;
  final String? userMessage;
  final int? statusCode;
  final dynamic originalError;

  const AppException({
    required this.code,
    required this.message,
    this.userMessage,
    this.statusCode,
    this.originalError,
  });

  /// 사용자에게 보여줄 메시지
  String get displayMessage => userMessage ?? message;

  @override
  String toString() =>
      'AppException(code: $code, message: $message, statusCode: $statusCode)';

  /// 네트워크 에러
  factory AppException.network({String? message, dynamic error}) {
    return AppException(
      code: 'NETWORK_ERROR',
      message: message ?? 'Network connection failed',
      userMessage: '네트워크 연결을 확인해주세요.',
      originalError: error,
    );
  }

  /// 인증 에러 (401)
  factory AppException.unauthorized({String? message, dynamic error}) {
    return AppException(
      code: 'UNAUTHORIZED',
      message: message ?? 'Authentication failed',
      userMessage: '인증이 만료되었습니다. 다시 로그인해주세요.',
      statusCode: 401,
      originalError: error,
    );
  }

  /// 권한 에러 (403)
  factory AppException.forbidden({String? message, dynamic error}) {
    return AppException(
      code: 'FORBIDDEN',
      message: message ?? 'Access denied',
      userMessage: '접근 권한이 없습니다.',
      statusCode: 403,
      originalError: error,
    );
  }

  /// 리소스 없음 (404)
  factory AppException.notFound({String? message, dynamic error}) {
    return AppException(
      code: 'NOT_FOUND',
      message: message ?? 'Resource not found',
      userMessage: '요청한 정보를 찾을 수 없습니다.',
      statusCode: 404,
      originalError: error,
    );
  }

  /// 충돌 에러 (409)
  factory AppException.conflict({String? message, String? userMessage, dynamic error}) {
    return AppException(
      code: 'CONFLICT',
      message: message ?? 'Resource conflict',
      userMessage: userMessage ?? '이미 존재하는 리소스입니다.',
      statusCode: 409,
      originalError: error,
    );
  }

  /// 유효성 검사 에러 (400)
  factory AppException.validation({String? message, String? userMessage, dynamic error}) {
    return AppException(
      code: 'VALIDATION_ERROR',
      message: message ?? 'Validation failed',
      userMessage: userMessage ?? '입력 정보를 확인해주세요.',
      statusCode: 400,
      originalError: error,
    );
  }

  /// 서버 에러 (500)
  factory AppException.server({String? message, dynamic error}) {
    return AppException(
      code: 'SERVER_ERROR',
      message: message ?? 'Internal server error',
      userMessage: '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
      statusCode: 500,
      originalError: error,
    );
  }

  /// 토큰 만료
  factory AppException.tokenExpired({dynamic error}) {
    return AppException(
      code: 'TOKEN_EXPIRED',
      message: 'Token has expired',
      userMessage: '세션이 만료되었습니다. 다시 로그인해주세요.',
      statusCode: 401,
      originalError: error,
    );
  }

  /// 토큰 갱신 실패
  factory AppException.tokenRefreshFailed({dynamic error}) {
    return AppException(
      code: 'TOKEN_REFRESH_FAILED',
      message: 'Failed to refresh token',
      userMessage: '세션을 갱신할 수 없습니다. 다시 로그인해주세요.',
      statusCode: 401,
      originalError: error,
    );
  }

  /// OAuth 에러
  factory AppException.oauth({String? message, String? userMessage, dynamic error}) {
    return AppException(
      code: 'OAUTH_ERROR',
      message: message ?? 'OAuth authentication failed',
      userMessage: userMessage ?? '인증에 실패했습니다. 다시 시도해주세요.',
      originalError: error,
    );
  }

  /// 알 수 없는 에러
  factory AppException.unknown({String? message, dynamic error}) {
    return AppException(
      code: 'UNKNOWN_ERROR',
      message: message ?? 'An unknown error occurred',
      userMessage: '알 수 없는 오류가 발생했습니다.',
      originalError: error,
    );
  }

  /// HTTP 상태 코드로부터 생성
  factory AppException.fromStatusCode(
    int statusCode, {
    String? message,
    String? userMessage,
    dynamic error,
  }) {
    switch (statusCode) {
      case 400:
        return AppException.validation(
          message: message,
          userMessage: userMessage,
          error: error,
        );
      case 401:
        return AppException.unauthorized(message: message, error: error);
      case 403:
        return AppException.forbidden(message: message, error: error);
      case 404:
        return AppException.notFound(message: message, error: error);
      case 409:
        return AppException.conflict(
          message: message,
          userMessage: userMessage,
          error: error,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return AppException.server(message: message, error: error);
      default:
        return AppException(
          code: 'HTTP_$statusCode',
          message: message ?? 'HTTP Error $statusCode',
          userMessage: userMessage ?? '요청 처리 중 오류가 발생했습니다.',
          statusCode: statusCode,
          originalError: error,
        );
    }
  }
}

/// 에러 결과를 나타내는 sealed class (Result 패턴)
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
        Success(:final value) => value,
        Failure() => null,
      };

  AppException? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  R when<R>({
    required R Function(T value) success,
    required R Function(AppException error) failure,
  }) {
    return switch (this) {
      Success(:final value) => success(value),
      Failure(:final error) => failure(error),
    };
  }

  Result<R> map<R>(R Function(T value) mapper) {
    return switch (this) {
      Success(:final value) => Success(mapper(value)),
      Failure(:final error) => Failure(error),
    };
  }
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final AppException error;
  const Failure(this.error);
}
