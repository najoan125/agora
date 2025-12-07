# Flutter 로그인 화면 흐름 및 UX

## 개요

완벽한 로그인 UI 흐름 구현

---

## 로그인 흐름 다이어그램

```
┌─────────────────┐
│   로그인 화면    │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│ OAuth 로그인 버튼 클릭   │
└────────┬────────────────┘
         │
         ▼
┌──────────────────────────────┐
│ 브라우저 열기                 │
│ /oauth/authorize로 리다이렉트 │
└────────┬─────────────────────┘
         │
         ▼
┌──────────────────┐
│ 사용자 로그인    │
│ (이메일/비번)   │
└────────┬─────────┘
         │
         ▼
┌─────────────────────────────┐
│ Authorization Code 발급      │
│ Deep Link로 앱으로 돌아옴   │
└────────┬────────────────────┘
         │
         ▼
┌──────────────────────────────┐
│ Token 교환                    │
│ /oauth/token으로 요청        │
└────────┬─────────────────────┘
         │
         ▼
┌────────────────────────────┐
│ Access/Refresh Token 저장   │
└────────┬───────────────────┘
         │
         ▼
┌──────────────────┐
│  홈 화면으로 이동│
└──────────────────┘
```

---

## 1. 로그인 화면 UI

### lib/presentation/screens/auth/login_screen.dart

```dart
class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    _initializeDeepLink();
  }

  void _initializeDeepLink() {
    // Deep Link 리스너 설정
    // 사용자가 인증 후 돌아올 때 처리
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: _buildBody(authState),
      ),
    );
  }

  Widget _buildBody(AuthState authState) {
    switch (authState.status) {
      case AuthStatus.initial:
      case AuthStatus.unauthenticated:
        return _buildLoginForm();

      case AuthStatus.authenticating:
        return _buildLoadingState();

      case AuthStatus.authenticated:
        return _buildSuccessState();

      case AuthStatus.error:
        return _buildErrorState(authState.errorMessage);

      default:
        return _buildLoginForm();
    }
  }

  Widget _buildLoginForm() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 로고
          Image.asset(
            'assets/logo.png',
            width: 80,
            height: 80,
          ),

          SizedBox(height: 40),

          // 제목
          Text(
            'Agora에 로그인',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 12),

          // 부제
          Text(
            '친구들과 언제 어디서나 연결하세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 40),

          // OAuth 로그인 버튼
          _buildOAuthButton(),

          SizedBox(height: 24),

          // 추가 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '또는',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),

          SizedBox(height: 24),

          // 약관 동의
          _buildTermsCheckbox(),

          SizedBox(height: 24),

          // 정보
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.security, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      '보안',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'OAuth 2.0 + PKCE로 안전하게 인증됩니다',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          Spacer(),

          // 하단 텍스트
          Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
              '로그인하면 약관에 동의한 것으로 간주됩니다',
              style: TextStyle(fontSize: 11, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOAuthButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _handleLogin(),
        icon: Icon(Icons.key),
        label: Text('OAuth로 로그인'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(value: true, onChanged: (_) {}),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '서비스 약관',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // 약관 페이지로 이동
                    },
                ),
                TextSpan(
                  text: '과 ',
                  style: TextStyle(color: Colors.black87),
                ),
                TextSpan(
                  text: '개인정보 보호',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // 개인정보 보호 페이지로 이동
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 24),
        Text('로그인 중...'),
        SizedBox(height: 12),
        Text(
          '브라우저를 통해 인증 중입니다',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSuccessState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 80,
        ),
        SizedBox(height: 24),
        Text(
          '로그인 성공!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String? error) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          color: Colors.red,
          size: 80,
        ),
        SizedBox(height: 24),
        Text(
          '로그인 실패',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.red,
          ),
        ),
        SizedBox(height: 12),
        Text(
          error ?? 'Unknown error',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => _handleLogin(),
          child: Text('다시 시도'),
        ),
      ],
    );
  }

  Future<void> _handleLogin() async {
    try {
      final authNotifier = ref.read(authProvider.notifier);
      await authNotifier.startOAuthLogin(
        loginUrl: 'https://api.hyfata.com/oauth/authorize?...',
        codeVerifier: 'generated_verifier',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('로그인 시작 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
```

---

## 2. 로그인 완료 화면

### lib/presentation/screens/auth/login_success_screen.dart

```dart
class LoginSuccessScreen extends StatefulWidget {
  @override
  State<LoginSuccessScreen> createState() => _LoginSuccessScreenState();
}

class _LoginSuccessScreenState extends State<LoginSuccessScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(Duration(seconds: 2));

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(seconds: 1),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 80,
                  ),
                );
              },
            ),
            SizedBox(height: 24),
            Text(
              '로그인 성공!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.green,
              ),
            ),
            SizedBox(height: 12),
            Text('잠시 후 앱으로 이동합니다...'),
          ],
        ),
      ),
    );
  }
}
```

---

## 3. Deep Link 처리

### lib/services/deep_link_handler.dart

```dart
class DeepLinkHandler {
  final AuthNotifier authNotifier;

  void handleDeepLink(String link) {
    try {
      final uri = Uri.parse(link);

      // OAuth 콜백 처리
      if (uri.host == 'oauth' && uri.path.contains('callback')) {
        _handleOAuthCallback(uri);
      }

      // 프로필 공유 링크
      if (uri.path.contains('profile')) {
        _handleProfileLink(uri);
      }

      // 채팅 링크
      if (uri.path.contains('chat')) {
        _handleChatLink(uri);
      }
    } catch (e) {
      AppLogger.error('Failed to handle deep link', error: e);
    }
  }

  Future<void> _handleOAuthCallback(Uri uri) async {
    final authCode = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];
    final error = uri.queryParameters['error'];

    if (error != null) {
      AppLogger.error('OAuth error: $error');
      return;
    }

    if (authCode != null) {
      // authCode → token 교환
      // authNotifier.exchangeCodeForToken(authCode, codeVerifier)
    }
  }

  void _handleProfileLink(Uri uri) {
    final agoraId = uri.pathSegments.last;
    // 프로필 화면으로 이동
  }

  void _handleChatLink(Uri uri) {
    final chatId = uri.queryParameters['chatId'];
    // 채팅 화면으로 이동
  }
}
```

---

## 4. 회원가입 화면 (선택)

### lib/presentation/screens/auth/signup_screen.dart

```dart
class SignupScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _agoraIdController;
  late TextEditingController _displayNameController;

  @override
  void initState() {
    super.initState();
    _agoraIdController = TextEditingController();
    _displayNameController = TextEditingController();
  }

  @override
  void dispose() {
    _agoraIdController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('프로필 설정')),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _agoraIdController,
                decoration: InputDecoration(
                  labelText: 'Agora ID',
                  hintText: '3-20자, 영문/숫자/언더스코어',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Agora ID를 입력하세요';
                  }
                  if (value.length < 3 || value.length > 20) {
                    return '3-20자여야 합니다';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(labelText: '표시 이름'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이름을 입력하세요';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _handleSignup(),
                child: Text('프로필 생성'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // 프로필 생성 API 호출
      // ...

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 생성 실패: $e')),
      );
    }
  }
}
```

---

## 5. 라우팅 설정

### lib/presentation/router/app_router.dart

```dart
final appRouterProvider = GoRouter(
  redirect: (context, state) {
    final auth = _authStateNotifier.state;

    // 로그인되지 않은 사용자 → 로그인 화면
    if (!auth.isAuthenticated && state.uri.path != '/login') {
      return '/login';
    }

    // 로그인된 사용자 → 로그인 화면 제외
    if (auth.isAuthenticated && state.uri.path == '/login') {
      return '/home';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
      routes: [
        GoRoute(
          path: 'signup',
          builder: (context, state) => SignupScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),
  ],
);
```

---

## UX 권장사항

1. **로딩 상태**: 명확한 로딩 표시
2. **에러 메시지**: 사용자 친화적인 설명
3. **브라우저 열기**: 시스템 브라우저 사용 (인앱 WebView 아님)
4. **Deep Link**: 명확한 콜백 처리
5. **보안 정보**: 최소한의 정보만 표시
6. **약관 동의**: 명확한 동의 표시
7. **로딩 시간**: 타임아웃 처리

---

## 완료!

모든 Flutter 인증 가이드 작성이 완료되었습니다!
