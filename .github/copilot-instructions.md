## Purpose

이 파일은 AI 코딩 에이전트(예: GitHub Copilot/코드 어시스턴트)가 이 저장소에서 즉시 생산적으로 작업할 수 있도록 프로젝트 특화 지침을 제공합니다.

## 한눈에 보는 아키텍처

- Entry: `lib/main.dart` — `MaterialApp`로 앱을 초기화하고 `useMaterial3: true`를 사용합니다.
- 주요 화면: `lib/screens/*.dart` (각 파일은 `*_screen.dart` 명명 규칙을 따름).
- 네비게이션: 하단 네비게이션은 `MainScreen`이 담당하고, `HomeScreen`/`ChatScreen`은 내부에 `TabController`를 사용한 2-탭 구조를 가집니다.
- 상태관리: 현재는 `StatefulWidget` + `setState()`만 사용되고 있습니다. (프로덕션용 상태관리 라이브러리는 아직 없음)
- 데이터: 화면 내의 목록/대화는 모두 하드코딩된 모의 데이터입니다. 백엔드 통합 시 화면 위젯 내 모의 데이터를 상태 변수/서비스로 교체하세요.

## 중요한 파일(바로 열어볼 것)

- `lib/main.dart` — 테마, 앱 진입점
- `lib/screens/login_screen.dart`, `main_screen.dart`, `home_screen.dart`, `chat_screen.dart`, `more_screen.dart` — 주요 UI 패턴 예제
- `lib/screens/conversation_screen.dart` — 대화 화면 라우팅 예시
- `pubspec.yaml` — 의존성: `flutter_svg` 사용, assets 선언
- `run_linux.sh` — Linux 실행 관련 유틸 (GTK_A11Y 관련 환경 설정이 포함되어 있음)

## 코드 작성/수정 규칙 (프로젝트 관례)

- 새 화면은 `lib/screens/feature_screen.dart` 형식으로 추가합니다. 파일명은 소문자와 언더스코어를 사용합니다.
- 탭 뷰 패턴: `TabController`를 `StatefulWidget`의 `initState()`에서 생성하고 `dispose()`에서 해제합니다. (예: `home_screen.dart`, `chat_screen.dart`)
- 네비게이션: `Navigator.push(MaterialPageRoute(...))` 패턴을 사용합니다. 라우트 맵은 사용되지 않음.
- 스타일: Material 위젯과 `useMaterial3: true`를 따릅니다. AppBar와 BottomNavigationBar 테마는 `main.dart`에서 설정됩니다.

## 개발자 워크플로(핵심 커맨드)

- 의존성 설치: `flutter pub get`
- 개발: `flutter run` (특정 디바이스: `-d <device_id>`)
- Linux에서 실행 문제(Atk 경고 등) 대비: `./run_linux.sh` 또는 환경변수 설정 (`GTK_A11Y=none; $env:GDK_DEBUG=""; flutter run -d linux`)
- 포맷/분석: `dart format lib/`  /  `flutter analyze`

## 백엔드/통합 주의사항

- 현재 모든 데이터는 각 스크린 내부의 하드코딩 리스트로 제공됩니다. 예: `home_screen.dart`의 `friends` 리스트, `chat_screen.dart`의 `chats` 리스트.
- 백엔드 통합 시 권장 흐름:
  1. 화면의 하드코딩 리스트를 제거하고 상태 변수를 추가
  2. 네트워크 레이어(services/api.dart 등)를 새로운 파일로 생성
  3. API 호출/로딩/에러 처리를 UI의 상태에 연결
  4. 필요 시 상태관리 라이브러리 도입(추천: GetX for quick integration or Provider/Riverpod for scalability)

## 변경/확장 예시 (간단 가이드)

1. 새 화면 추가
   - 파일 생성: `lib/screens/my_feature_screen.dart`
   - Stateful/Stateless 위젯 작성
   - `MainScreen`의 하단 탭에 추가하려면 `main_screen.dart`를 수정

2. TabController 패턴 복제
   - initState: `_tabController = TabController(length: N, vsync: this);`
   - build: `TabBar(controller: _tabController, ...)` 및 `TabBarView(controller: _tabController, children: [...])`

## 참고: 코드 예제(프로젝트 내 기존 코드 활용)

탭 생성/해제 패턴은 `lib/screens/home_screen.dart`, `lib/screens/chat_screen.dart`를 참고하세요.

## 테스트 및 린트

- 현재 테스트 파일이 없습니다. 빠른 검증은 `flutter analyze`와 `dart format lib/`로 수행하세요.

## 제약 및 알려진 이슈

- 상태관리/아키텍처가 경량화되어 있으며, 대규모 리팩터 또는 동시성/실시간 기능(웹소켓)은 현재 고려되어 있지 않습니다.
- 플랫폼별 네이티브 구성(예: iOS 권한, Android Gradle 설정)은 해당 `ios/`, `android/` 디렉터리에서 관리됩니다.

## 무엇을 묻거나 요청해야 하는가

- 백엔드 API 스펙(엔드포인트, 인증 방식)
- 선호하는 상태관리 솔루션(간단: GetX, 확장성: Riverpod/BLoC)
- UI/UX 변경 시 우선순위(예: 다크 모드, i18n)

---

위 콘텐츠가 충분하지 않거나 누락된 세부 정보가 있으면 알려주세요. 요구에 맞춰 빠르게 업데이트하겠습니다.
