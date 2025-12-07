# Agora Test Suite

이 디렉토리에는 Agora 프로젝트의 모든 테스트 코드가 포함되어 있습니다.

## 디렉토리 구조

```
test/
├── unit/                          # 단위 테스트
│   ├── utils/                    # 유틸리티 클래스 테스트
│   │   ├── pkce_util_test.dart
│   │   └── secure_storage_manager_test.dart
│   ├── services/                 # 서비스 클래스 테스트
│   │   └── oauth_service_test.dart
│   └── providers/                # Provider 테스트
│       ├── auth_provider_test.dart
│       └── chat_provider_test.dart
└── widget/                        # 위젯 테스트
    ├── auth/
    │   └── login_screen_test.dart
    └── home/
        └── home_screen_test.dart
```

## 테스트 실행

### 모든 테스트 실행
```bash
flutter test
```

### 특정 테스트 파일 실행
```bash
# 단위 테스트
flutter test test/unit/utils/pkce_util_test.dart
flutter test test/unit/services/oauth_service_test.dart
flutter test test/unit/providers/auth_provider_test.dart

# 위젯 테스트
flutter test test/widget/auth/login_screen_test.dart
flutter test test/widget/home/home_screen_test.dart
```

### 특정 디렉토리의 테스트 실행
```bash
# 모든 단위 테스트
flutter test test/unit/

# 모든 위젯 테스트
flutter test test/widget/
```

### 커버리지와 함께 실행
```bash
flutter test --coverage
```

커버리지 리포트 확인:
```bash
# HTML 리포트 생성 (lcov 필요)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## 테스트 파일 설명

### 1. Unit Tests

#### `test/unit/utils/pkce_util_test.dart`
**테스트 대상**: `lib/core/utils/pkce_util.dart`

OAuth 2.0 PKCE (Proof Key for Code Exchange) 유틸리티 테스트

**주요 테스트 케이스**:
- `generateCodeVerifier()`: 128자 랜덤 문자열 생성
- `generateCodeChallenge()`: SHA256 해시 + Base64URL 인코딩
- `generateCodePair()`: verifier와 challenge 쌍 생성
- `isValidCodeVerifier()`: RFC 7636 규격 검증
- `generateState()`: CSRF 방지용 state 생성

**실행**:
```bash
flutter test test/unit/utils/pkce_util_test.dart
```

#### `test/unit/utils/secure_storage_manager_test.dart`
**테스트 대상**: `lib/core/utils/secure_storage_manager.dart`

보안 저장소 관리자 테스트 (FlutterSecureStorage 래퍼)

**주요 테스트 케이스**:
- 토큰 저장/조회/삭제
- 사용자 정보 관리
- FCM 토큰 관리
- OAuth PKCE 코드 관리
- 세션 관리

**참고**: FlutterSecureStorage가 static const로 선언되어 있어 직접 목킹이 어렵습니다. 이 테스트는 인터페이스 문서화에 중점을 둡니다.

**실행**:
```bash
flutter test test/unit/utils/secure_storage_manager_test.dart
```

#### `test/unit/services/oauth_service_test.dart`
**테스트 대상**: `lib/services/oauth_service.dart`

OAuth 2.0 인증 서비스 테스트

**주요 테스트 케이스**:
- PKCE 플로우 검증
- Authorization URL 생성
- Deep Link 처리
- 토큰 교환 (Authorization Code → Access Token)
- State 검증 (CSRF 방지)
- 로그아웃 처리

**실행**:
```bash
flutter test test/unit/services/oauth_service_test.dart
```

#### `test/unit/providers/auth_provider_test.dart`
**테스트 대상**: `lib/shared/providers/auth_provider.dart`

인증 상태 관리 Provider 테스트

**주요 테스트 케이스**:
- AuthState 모델 테스트
  - 초기화, 인증 중, 인증됨, 미인증, 에러 상태
  - `isAuthenticated`, `isLoading`, `isTokenValid` getter
  - `timeUntilExpiration` 계산
  - `copyWith` 메서드
- AuthNotifier 테스트
  - OAuth 로그인 시작
  - 로그아웃
  - 강제 로그아웃
  - 에러 처리
- Derived Providers 테스트

**실행**:
```bash
flutter test test/unit/providers/auth_provider_test.dart
```

#### `test/unit/providers/chat_provider_test.dart`
**테스트 대상**: `lib/shared/providers/chat_provider.dart`

채팅 상태 관리 Provider 테스트

**주요 테스트 케이스**:
- MessageListState 모델 테스트
- MessageListNotifier 테스트
  - 메시지 로드 (페이지네이션 포함)
  - WebSocket을 통한 메시지 전송
  - 읽음 처리
  - WebSocket 구독/구독 해제
- ChatActionNotifier 테스트
  - 1:1 채팅 시작
  - 메시지 삭제
  - 에러 처리

**실행**:
```bash
flutter test test/unit/providers/chat_provider_test.dart
```

### 2. Widget Tests

#### `test/widget/auth/login_screen_test.dart`
**테스트 대상**: `lib/features/auth/login_screen.dart`

로그인 화면 위젯 테스트

**주요 테스트 케이스**:
- UI 요소 렌더링
  - 로고, 앱 이름, 태그라인
  - 로그인 버튼
  - 보안 정보
  - 이용약관 링크
- 사용자 인터랙션
  - 로그인 버튼 클릭
  - 에러 메시지 닫기
- 상태 변화
  - 로딩 상태 표시
  - 에러 상태 표시
  - 버튼 비활성화
- 반응형 디자인
- 접근성

**실행**:
```bash
flutter test test/widget/auth/login_screen_test.dart
```

#### `test/widget/home/home_screen_test.dart`
**테스트 대상**: `lib/features/home/home_screen.dart`

홈 화면 위젯 테스트

**주요 테스트 케이스**:
- AppBar
  - 탭 전환 (친구/팀원)
  - 액션 버튼 (친구 추가, 알림)
  - 메뉴 토글
- Profile Header
  - 사용자 프로필 표시
  - 상태 메시지
- Search Bar
  - 검색 필터링
  - Floating 및 Snap 동작
- Friends Tab
  - 친구 목록 표시
  - 그룹 채팅 섹션
  - 친구 요청 섹션
  - 생일 섹션
  - 즐겨찾기 분리
  - 새로고침
- Teams Tab
  - 팀 목록 표시
  - 멤버 수 표시
- Tab Switching
  - 탭 간 전환
  - 스크롤 위치 유지
- Collapsible Sections
  - 그룹 채팅 섹션 접기/펼치기
- Sorting
  - 정렬 다이얼로그
  - 최신순/이름순 정렬
- Error Handling
  - 로딩 실패 처리
  - 재시도 버튼
- Responsive Design
  - CustomScrollView
  - SliverAppBar

**실행**:
```bash
flutter test test/widget/home/home_screen_test.dart
```

## 테스트 작성 가이드라인

### 단위 테스트 작성 패턴

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock 클래스
class MockService extends Mock implements Service {}

void main() {
  group('MyClass', () {
    late MockService mockService;

    setUp(() {
      mockService = MockService();
    });

    test('should do something', () {
      // Arrange
      when(() => mockService.method()).thenReturn('result');

      // Act
      final result = myClass.doSomething();

      // Assert
      expect(result, equals('expected'));
      verify(() => mockService.method()).called(1);
    });
  });
}
```

### 위젯 테스트 작성 패턴

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('should display widget', (tester) async {
    // Arrange
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: MyWidget(),
        ),
      ),
    );

    // Act
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Assert
    expect(find.text('Expected Text'), findsOneWidget);
  });
}
```

## 모킹 (Mocking)

### Mocktail 사용

이 프로젝트는 `mocktail` 패키지를 사용합니다.

```dart
// Mock 클래스 정의
class MockApiClient extends Mock implements ApiClient {}

// 사용
final mock = MockApiClient();
when(() => mock.get(any())).thenAnswer((_) async => Response(...));
```

### Riverpod Provider 오버라이딩

```dart
final container = ProviderContainer(
  overrides: [
    myProvider.overrideWithValue(mockValue),
  ],
);
```

## 테스트 커버리지 목표

- **전체 커버리지**: 70% 이상
- **핵심 비즈니스 로직**: 90% 이상
- **Utils/Services**: 80% 이상
- **Providers**: 80% 이상
- **Widgets**: 60% 이상

## CI/CD 통합

테스트는 CI/CD 파이프라인에서 자동으로 실행되어야 합니다.

```yaml
# .github/workflows/test.yml 예시
name: Test
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v2
```

## 주의사항

1. **FlutterSecureStorage Mock 제한**
   - SecureStorageManager는 static const FlutterSecureStorage를 사용하므로 직접 목킹이 어렵습니다
   - 통합 테스트나 인터페이스 테스트로 보완하세요

2. **WebSocket 테스트**
   - WebSocket 이벤트는 Stream으로 목킹합니다
   - 실시간 업데이트는 통합 테스트에서 검증하세요

3. **비동기 처리**
   - `await tester.pumpAndSettle()`을 사용하여 모든 애니메이션과 비동기 작업이 완료될 때까지 대기하세요
   - `Future.delayed()`는 테스트를 느리게 만들 수 있으므로 주의하세요

4. **Provider 테스트**
   - `ProviderContainer`를 사용하여 독립적으로 테스트하세요
   - 테스트 후 `container.dispose()`를 호출하세요

## 문제 해결

### 테스트 실패 시

1. **플랫폼 채널 에러**
   ```dart
   TestWidgetsFlutterBinding.ensureInitialized();
   ```

2. **Provider 에러**
   ```dart
   // ProviderScope로 감싸기
   ProviderScope(child: MyWidget())
   ```

3. **비동기 타이밍 문제**
   ```dart
   await tester.pumpAndSettle();
   // 또는
   await tester.pump(Duration(milliseconds: 100));
   ```

## 추가 리소스

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Riverpod Testing](https://riverpod.dev/docs/cookbooks/testing)
- [Mocktail Documentation](https://pub.dev/packages/mocktail)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
