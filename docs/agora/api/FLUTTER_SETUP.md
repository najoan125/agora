# Flutter 프로젝트 초기 설정

## 프로젝트 생성

```bash
flutter create agora_app
cd agora_app
```

---

## pubspec.yaml - 의존성 추가

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP 통신
  dio: ^5.4.0

  # 상태 관리
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  hooks_riverpod: ^2.4.0

  # 라우팅
  go_router: ^13.0.0

  # 안전한 저장소 (토큰)
  flutter_secure_storage: ^9.1.0

  # WebSocket
  stomp: ^1.4.0

  # Firebase (FCM)
  firebase_core: ^26.0.0
  firebase_messaging: ^14.8.0

  # 이미지 처리
  image_picker: ^1.0.0
  image: ^4.1.0

  # 로깅
  logger: ^2.0.0

  # 시간 처리
  intl: ^0.19.0

  # JSON 직렬화
  json_serializable: ^6.7.0

  # HTTP 로깅 (개발용)
  dio_logging_interceptor: ^0.0.7

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  json_serializable: ^6.7.0

flutter:
  uses-material-design: true
```

---

## Firebase 설정 (FCM)

### 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com) 접속
2. 프로젝트 생성
3. iOS/Android 앱 추가

### 2. FlutterFire CLI 설치

```bash
dart pub global activate flutterfire_cli
```

### 3. Flutter 앱에 Firebase 연동

```bash
flutterfire configure
```

**선택 항목:**
- Project: 자신의 Firebase 프로젝트
- iOS: Y
- Android: Y
- macOS: N
- Windows: N
- Web: N

---

## 환경 변수 설정

### .env 파일 생성

```bash
# .env 파일 (프로젝트 루트)
API_BASE_URL=https://api.hyfata.com
API_TIMEOUT=30
LOG_LEVEL=debug
SECURE_STORAGE_GROUP=com.hyfata.agora
```

### .gitignore 추가

```
# 환경 파일
.env
.env.local
.env.*.local

# Firebase
firebase-debug.log

# 테스트
coverage/
.coverage

# IDE
.vscode/
.idea/
*.swp
*.swo
```

---

## 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점
├── core/
│   ├── config/
│   │   ├── api_config.dart            # API 설정
│   │   ├── firebase_config.dart       # Firebase 설정
│   │   └── riverpod_config.dart       # Riverpod 설정
│   ├── constants/
│   │   ├── api_endpoints.dart         # API 경로
│   │   ├── app_strings.dart           # 텍스트 상수
│   │   └── app_colors.dart            # 색상 정의
│   ├── utils/
│   │   ├── logger.dart                # 로깅 유틸
│   │   ├── secure_storage.dart        # 안전 저장소 래퍼
│   │   └── device_info.dart           # 기기 정보
│   └── exception/
│       └── app_exception.dart         # 예외 처리
├── data/
│   ├── datasources/
│   │   ├── remote/
│   │   │   ├── api_client.dart        # HTTP 클라이언트
│   │   │   ├── auth_api.dart          # 인증 API
│   │   │   ├── profile_api.dart       # 프로필 API
│   │   │   └── chat_api.dart          # 채팅 API
│   │   └── local/
│   │       └── secure_storage_ds.dart # 로컬 저장소
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── auth_response.dart
│   │   ├── chat_model.dart
│   │   └── *.g.dart                   # JSON 직렬화 (자동생성)
│   └── repositories/
│       ├── auth_repository.dart
│       ├── profile_repository.dart
│       └── chat_repository.dart
├── domain/
│   ├── entities/
│   │   ├── user.dart
│   │   ├── auth_response.dart
│   │   └── chat.dart
│   └── repositories/
│       ├── auth_repository.dart       # 인터페이스
│       └── profile_repository.dart
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart         # 인증 상태
│   │   ├── user_provider.dart         # 사용자 정보
│   │   └── chat_provider.dart         # 채팅 상태
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── onboarding_screen.dart
│   │   ├── home/
│   │   │   └── home_screen.dart
│   │   ├── chat/
│   │   │   ├── chat_list_screen.dart
│   │   │   └── chat_detail_screen.dart
│   │   └── profile/
│   │       └── profile_screen.dart
│   ├── widgets/
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   └── loading_indicator.dart
│   └── router/
│       └── app_router.dart            # 라우팅 설정
└── services/
    ├── websocket_service.dart         # WebSocket 연결
    ├── fcm_service.dart               # FCM 처리
    └── notification_service.dart      # 로컬 알림
```

---

## Riverpod 기본 설정

### main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/firebase_config.dart';
import 'presentation/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await FirebaseConfig.initialize();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      title: 'Agora',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
    );
  }
}
```

---

## API 클라이언트 초기 설정

### api_config.dart

```dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.hyfata.com',
  );

  static const int timeout = 30000; // 30초

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
```

### api_client.dart (Dio 설정)

```dart
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: ApiConfig.defaultHeaders,
      ),
    );

    // 인터셉터 추가 (토큰 자동 갱신)
    _dio.interceptors.add(TokenInterceptor());

    // 로깅 (개발용)
    _dio.interceptors.add(LoggingInterceptor());
  }

  Dio get dio => _dio;
}

// 싱글톤
final apiClientProvider = Provider((ref) => ApiClient());
```

---

## WebSocket 서비스 초기화

### websocket_service.dart

```dart
import 'package:stomp/stomp.dart';

class WebSocketService {
  static const String wsUrl = 'wss://api.hyfata.com/ws/agora/chat';

  late StompClient _client;

  Future<void> connect(String accessToken) async {
    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        stompConnectHeaders: {
          'Authorization': 'Bearer $accessToken',
        },
      ),
    );

    await _client.connect();
  }

  void _onConnect(StompFrame frame) {
    print('WebSocket 연결됨');
  }

  void _onDisconnect(StompFrame frame) {
    print('WebSocket 연결 해제');
  }

  void disconnect() {
    _client.disconnect();
  }
}
```

---

## 빌드 및 테스트

```bash
# 코드 생성 (JSON 직렬화)
flutter pub run build_runner build

# 앱 실행 (개발)
flutter run

# 앱 빌드 (릴리즈)
flutter build apk      # Android
flutter build ipa      # iOS
```

---

## 주의사항

1. **API_BASE_URL**: 개발/스테이징/프로덕션 환경별로 다르게 설정
2. **Firebase**: 각 플랫폼(iOS/Android)별로 설정 파일 필요
3. **Secure Storage**: 키 저장소는 플랫폼별 암호화 사용
4. **WebSocket**: SSL/TLS 인증서 유효성 확인 필수

---

## 다음 단계

- FLUTTER_AUTH.md - OAuth 2.0 + PKCE 인증 구현
- FLUTTER_API_CLIENT.md - API 클라이언트 고급 설정
